import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qr_app/helper/theme/admin_theme.dart';
import 'package:qr_app/helper/widgets/my_container.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/helper/widgets/my_text.dart';
import 'package:qr_app/models/discrete_model.dart';
import 'package:qr_app/services/produce_service.dart';
import 'package:qr_app/widgets/my_banner_notification.dart';
import 'package:qr_app/widgets/my_input.dart';
import 'package:qr_app/widgets/my_modal.dart';
import 'package:remixicon/remixicon.dart';

class LineModalProduce extends StatefulWidget {
  final ProduceLineModel? initialLine;
  final String? objectCode;
  final String? baseUnit;
  final Function(ProduceLineModel line)? Save;

  const LineModalProduce({
    super.key,
    this.initialLine,
    this.objectCode,
    this.baseUnit,
    this.Save,
  });

  static Future<ProduceLineModel?> show(
    BuildContext context, {
    ProduceLineModel? line,
    String? objectCode,
    String? baseUnit,
  }) {
    return showDialog<ProduceLineModel>(
      context: context,
      barrierDismissible: true,
      builder: (context) => LineModalProduce(
        initialLine: line,
        objectCode: objectCode,
        baseUnit: baseUnit,
      ),
    );
  }

  @override
  State<LineModalProduce> createState() => _LineModalProduceState();
}

class _LineModalProduceState extends State<LineModalProduce> {
  final TextEditingController _addWeightController = TextEditingController();
  final TextEditingController _slkkController = TextEditingController();
  final TextEditingController _ghiChuController = TextEditingController();

  double _grossWeight = 0;
  double _baseQty = 0;
  String _baseUnit = 'KG';
  String? _lotNbr;

  DateTime? _nsxDate;
  DateTime? _hsdDate;
  bool _isGetWeightLoading = false;

  bool get isEditMode => widget.initialLine != null;

  @override
  void initState() {
    super.initState();
    _initData();
    _addWeightController.addListener(_recalculateBaseQty);
  }

  void _initData() {
    if (isEditMode) {
      final line = widget.initialLine!;
      _lotNbr = line.lot_nbr;
      _grossWeight = (line.gross_weight ?? 0).toDouble();
      _baseUnit = line.base_unit ?? widget.baseUnit ?? 'KG';

      _addWeightController.text = (line.add_weight ?? 0).toString();
      // SLKK lấy theo line nếu có, không có thì mặc định là 1
      _slkkController.text = (line.physical_qty ?? 1).toString();
      _ghiChuController.text = line.line_descr ?? '';

      if (line.lot_manufacture_date != null) {
        _nsxDate = DateTime.tryParse(line.lot_manufacture_date!);
      }
      if (line.lot_expire_date != null) {
        _hsdDate = DateTime.tryParse(line.lot_expire_date!);
      }
    } else {
      _baseUnit = widget.baseUnit ?? 'KG';
      _grossWeight = 0;
      _addWeightController.text = '0';
      _slkkController.text = '1'; // Mặc định SLKK bằng 1 khi tạo mới
    }
    _recalculateBaseQty();
  }

  /// SL Gốc = Gross Weight - Add Weight
  void _recalculateBaseQty() {
    final double addWeight = double.tryParse(_addWeightController.text) ?? 0;
    final double calculatedBaseQty = _grossWeight - addWeight;

    setState(() {
      _baseQty = calculatedBaseQty < 0 ? 0 : calculatedBaseQty;
    });
  }

  @override
  void dispose() {
    _addWeightController.dispose();
    _slkkController.dispose();
    _ghiChuController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isNsx) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isNsx ? _nsxDate : _hsdDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isNsx) {
          _nsxDate = picked;
        } else {
          _hsdDate = picked;
        }
      });
    }
  }

  /// Gọi API lấy dữ liệu cân trực tiếp từ mã trạm cân (`widget.objectCode`)
  Future<void> _handleGetWeight() async {
    if (widget.objectCode == null || widget.objectCode!.trim().isEmpty) {
      MyBannerNotification.show(
        context,
        title: "Thông báo",
        message: "Vui lòng chọn trạm cân trước!",
        type: BannerType.error,
        duration: const Duration(seconds: 1),
      );
      return;
    }

    setState(() => _isGetWeightLoading = true);

    try {
      final response = await ProduceService.getLatestWeighingByID(
        widget.objectCode!,
      );

      if (response != null &&
          response['status'] == true &&
          response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final num? trongLuong = data['trong_luong'];

        if (trongLuong != null) {
          setState(() {
            _grossWeight = trongLuong.toDouble();
            _recalculateBaseQty(); // Tính lại SL Gốc theo Gross weight mới
          });
          MyBannerNotification.show(
            context,
            title: "Thành công",
            message: "Đã lấy trọng lượng cân: $trongLuong",
            type: BannerType.success,
            duration: const Duration(seconds: 1),
          );
        }
      } else {
        MyBannerNotification.show(
          context,
          title: "Thông báo",
          message: "Không lấy được dữ liệu cân từ trạm cân!",
          type: BannerType.error,
          duration: const Duration(seconds: 1),
        );
      }
    } catch (e) {
      debugPrint("❌ Lỗi khi lấy cân: $e");
      MyBannerNotification.show(
        context,
        title: "Lỗi",
        message: "Đã xảy ra lỗi trong quá trình kết nối trạm cân!",
        type: BannerType.error,
        duration: const Duration(seconds: 1),
      );
    } finally {
      if (mounted) setState(() => _isGetWeightLoading = false);
    }
  }

  void _handleSave() {
    final double addWeight = double.tryParse(_addWeightController.text) ?? 0;
    final double slkk = double.tryParse(_slkkController.text) ?? 1;

    final resultLine = (widget.initialLine ?? ProduceLineModel()).copyWith(
      gross_weight: _grossWeight,
      base_qty: _baseQty,
      base_unit: _baseUnit,
      add_weight: addWeight,
      physical_qty: slkk,
      line_descr: _ghiChuController.text,
      lot_manufacture_date: _nsxDate?.toIso8601String(),
      lot_expire_date: _hsdDate?.toIso8601String(),
    );

    if (widget.Save != null) {
      widget.Save!(resultLine);
    }

    Get.back(result: resultLine);
  }

  @override
  Widget build(BuildContext context) {
    final contentTheme = AdminTheme.theme.contentTheme;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return MyModal(
      title: "THÔNG TIN SẢN PHẨM",
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 0: Số lô (Ẩn nếu ở trạng thái New hoặc rỗng)
            if (isEditMode &&
                _lotNbr != null &&
                _lotNbr!.trim().isNotEmpty) ...[
              _buildLabel("Số Lô", contentTheme),
              MySpacing.height(6),
              MyText.bodyMedium(
                _lotNbr!,
                fontWeight: 700,
                color: contentTheme.primary,
              ),
              MySpacing.height(14),
            ],

            // Row 1: Gross Weight - ĐVT - Nút Lấy Cân
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gross weight (Text)
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Gross weight", contentTheme),
                      MySpacing.height(8),
                      MyText.bodyMedium(
                        '$_grossWeight',
                        fontWeight: 700,
                        color: contentTheme.primary,
                      ),
                    ],
                  ),
                ),
                MySpacing.width(8),

                // ĐVT (Text)
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("ĐVT", contentTheme),
                      MySpacing.height(8),
                      MyText.bodyMedium(
                        _baseUnit,
                        fontWeight: 700,
                        color: contentTheme.primary,
                      ),
                    ],
                  ),
                ),
                MySpacing.width(8),

                // Nút "Lấy cân" (Disable nếu ở chế độ chỉnh sửa)
                ElevatedButton(
                  onPressed: (isEditMode || _isGetWeightLoading)
                      ? null
                      : _handleGetWeight,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E2838),
                    disabledBackgroundColor: Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isGetWeightLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Lấy cân",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                ),
              ],
            ),
            MySpacing.height(14),

            // Row 2: Add weight (Input)
            _buildLabel("Add weight", contentTheme),
            MySpacing.height(6),
            MyInput(
              controller: _addWeightController,
              keyboardType: TextInputType.number,
              borderRadius: 8,
            ),
            MySpacing.height(14),

            // Row 3: SL Gốc (Cùng hàng)
            Row(
              children: [
                _buildLabel("SL Gốc: ", contentTheme),
                MyText.bodyMedium(
                  _baseQty.toStringAsFixed(2),
                  fontWeight: 700,
                  color: contentTheme.primary,
                ),
              ],
            ),
            MySpacing.height(14),

            // Row 4: SLKK (Số lượng KK)
            _buildLabel("SLKK", contentTheme),
            MySpacing.height(6),
            MyInput(
              controller: _slkkController,
              keyboardType: TextInputType.number,
              borderRadius: 8,
            ),
            MySpacing.height(14),

            // Row 5: NSX & HSD
            Row(
              children: [
                // NSX
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("NSX", contentTheme),
                      MySpacing.height(6),
                      InkWell(
                        onTap: () => _selectDate(context, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: contentTheme.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _nsxDate != null
                                    ? dateFormat.format(_nsxDate!)
                                    : "Chọn ngày",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _nsxDate != null
                                      ? contentTheme.onBackground
                                      : contentTheme.cardTextMuted,
                                ),
                              ),
                              Icon(
                                RemixIcons.calendar_event_line,
                                size: 18,
                                color: contentTheme.cardTextMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                MySpacing.width(12),

                // HSD
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("HSD", contentTheme),
                      MySpacing.height(6),
                      InkWell(
                        onTap: () => _selectDate(context, false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: contentTheme.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _hsdDate != null
                                    ? dateFormat.format(_hsdDate!)
                                    : "Chọn ngày",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _hsdDate != null
                                      ? contentTheme.onBackground
                                      : contentTheme.cardTextMuted,
                                ),
                              ),
                              Icon(
                                RemixIcons.calendar_event_line,
                                size: 18,
                                color: contentTheme.cardTextMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            MySpacing.height(14),

            // Row 6: Diễn giải / Ghi chú
            _buildLabel("Diễn giải / Ghi chú", contentTheme),
            MySpacing.height(6),
            MyInput(
              controller: _ghiChuController,
              hintText: "Ghi chú...",
              maxLines: 3,
              borderRadius: 8,
            ),
          ],
        ),
      ),

      // Footer Nút Hủy và Lưu lại
      customActions: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: MyContainer(
                  onTap: () => Get.back(),
                  color: const Color(0xFFFF4D4F),
                  padding: MySpacing.y(12),
                  borderRadiusAll: 10,
                  alignment: Alignment.center,
                  child: MyText.bodyMedium(
                    "Hủy",
                    fontWeight: 700,
                    color: Colors.white,
                  ),
                ),
              ),
              MySpacing.width(12),
              Expanded(
                child: MyContainer(
                  onTap: _handleSave,
                  color: const Color(0xFF00A86B),
                  padding: MySpacing.y(12),
                  borderRadiusAll: 10,
                  alignment: Alignment.center,
                  child: MyText.bodyMedium(
                    "Lưu lại",
                    fontWeight: 700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildValueBox(String text, dynamic contentTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: contentTheme.background,
        border: Border.all(color: contentTheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: MyText.bodyMedium(
        text,
        fontWeight: 600,
        color: contentTheme.onBackground,
      ),
    );
  }

  Widget _buildLabel(String text, dynamic contentTheme) {
    return MyText.bodySmall(
      text,
      fontWeight: 600,
      color: contentTheme.cardTextMuted,
      fontSize: 12,
    );
  }
}

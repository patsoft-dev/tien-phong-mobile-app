import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_app/helper/theme/admin_theme.dart';
import 'package:qr_app/helper/widgets/my_container.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/helper/widgets/my_text.dart';
import 'package:qr_app/models/stocktake_model.dart';
import 'package:qr_app/services/inventory_service.dart';
import 'package:qr_app/views/screen/qr_scanner_screen.dart';
import 'package:qr_app/views/screen/stocktake/modal/select_location_modal.dart';
import 'package:qr_app/widgets/my_banner_notification.dart';
import 'package:qr_app/widgets/my_input.dart';
import 'package:qr_app/widgets/my_modal.dart';
import 'package:qr_app/widgets/select_input_box.dart';

class StockTakeLineModal extends StatefulWidget {
  final Map<String, dynamic> initialLine;
  final String siteId;
  final Function(Map<String, dynamic> updatedLine)? onSave;

  const StockTakeLineModal({
    super.key,
    required this.initialLine,
    required this.siteId,
    this.onSave,
  });

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required Map<String, dynamic> initialLine,
    required String siteId,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          StockTakeLineModal(initialLine: initialLine, siteId: siteId),
    );
  }

  @override
  State<StockTakeLineModal> createState() => _StockTakeLineModalState();
}

class _StockTakeLineModalState extends State<StockTakeLineModal> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _qrScanController = TextEditingController();
  final TextEditingController _soLuongController = TextEditingController();

  String _idLocation = '';
  String _locationName = '';
  String _tenVatTu = '';
  String _maVatTu = '';
  String _soLo = '';
  String _dvtGoc = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    final line = widget.initialLine;
    // Bỏ dữ liệu giả lập, lấy trực tiếp từ initialLine
    _tenVatTu = line['tenVatTu']?.toString() ?? '';
    _dvtGoc = line['dvtGoc']?.toString() ?? '';

    _idLocation = line['idLocation']?.toString() ?? '';
    _locationName = line['locationName']?.toString() ?? '';

    // Hiển thị tên/mã vị trí lên ô input
    if (_locationName.isNotEmpty) {
      _locationController.text = _idLocation.isNotEmpty
          ? "$_idLocation - $_locationName"
          : _locationName;
    } else {
      _locationController.text = _idLocation;
    }

    _maVatTu = line['maVatTu']?.toString() ?? '';
    _soLo = line['soLo']?.toString() ?? '';

    // Nếu đã có thông tin mã VT và Số Lô thì hiển thị dạng Mã||Lô lên ô scan
    if (_maVatTu.isNotEmpty || _soLo.isNotEmpty) {
      _qrScanController.text = "$_maVatTu||$_soLo";
    }

    _soLuongController.text = (line['soLuong'] ?? 0).toString();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _qrScanController.dispose();
    _soLuongController.dispose();
    super.dispose();
  }

  Future<void> _fetchInventoryData(String qrCode) async {
    final cleanCode = qrCode.trim();
    if (cleanCode.isEmpty) return;

    final parts = cleanCode.split("||");
    if (parts.length < 2) {
      MyBannerNotification.show(
        context,
        title: "Lỗi định dạng",
        message: "Mã QR không hợp lệ (Cần dạng: Mã VT||Số Lot)",
        type: BannerType.error,
      );
      return;
    }

    final inventoryCd = parts[0].trim();
    final lotSerialNbr = parts[1].trim();

    setState(() {
      _maVatTu = inventoryCd;
      _soLo = lotSerialNbr;
      _isLoading = true;
    });

    try {
      final response = await InventoryService.getLotSerialDetail(
        inventory_cd: _maVatTu,
        lot_serial_nbr: _soLo,
      );

      if (mounted) {
        final rawData = response?['data'];
        final isDataValid = rawData is List && rawData.isNotEmpty;

        if (response != null && response['status'] == true && isDataValid) {
          // Lấy item đầu tiên từ mảng dữ liệu trả về
          final firstItem = Map<String, dynamic>.from(rawData.first);

          final String inventoryName =
              firstItem['inventory_name']?.toString().trim() ?? '';
          final String baseUnit =
              firstItem['base_unit']?.toString().trim() ?? '';
          final String locCd =
              firstItem['location_cd']?.toString().trim() ?? '';
          final String locName =
              firstItem['location_name']?.toString().trim() ?? '';

          setState(() {
            // Gán thông tin Vật tư thu được từ API
            if (inventoryName.isNotEmpty) _tenVatTu = inventoryName;
            if (baseUnit.isNotEmpty) _dvtGoc = baseUnit;

            // Cập nhật vị trí nếu có thông tin từ API
            if (locCd.isNotEmpty) {
              _idLocation = locCd;
              _locationName = locName;
              _locationController.text = locName.isNotEmpty
                  ? "$locCd - $locName"
                  : locCd;
            }
          });

          MyBannerNotification.show(
            context,
            title: "Thành công",
            message:
                response['message']?.toString() ?? 'Lấy dữ liệu thành công',
            type: BannerType.success,
          );
        } else {
          MyBannerNotification.show(
            context,
            title: "Thất bại",
            message:
                response?['message']?.toString() ??
                "Không tìm thấy dữ liệu Lot/Serial",
            type: BannerType.error,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        MyBannerNotification.show(
          context,
          title: "Lỗi kết nối",
          message: e.toString(),
          type: BannerType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- Parse mã QR Vật Tư / Số Lô ---
  void _parseAndApplyQrCode(String rawCode) {
    if (rawCode.trim().isEmpty) return;

    _qrScanController.text = rawCode;

    // Tự động gọi API lấy thông tin chi tiết vật tư
    _fetchInventoryData(rawCode);
  }

  Future<void> _handleScanVatTuQR() async {
    final String? scannedCode = await Get.to(() => const QrScannerScreen());
    if (scannedCode != null && scannedCode.trim().isNotEmpty) {
      _parseAndApplyQrCode(scannedCode.trim());
    }
  }

  // --- Xử lý chọn & Quét Vị trí ---
  Future<void> _handleSelectLocation() async {
    final location = await SelectLocationModal.show(
      context,
      siteId: widget.siteId,
    );

    if (location != null) {
      _applySelectedLocation(location);
    }
  }

  void _applySelectedLocation(LocationModel location) {
    final locCd = location.LocationCD?.trim() ?? '';
    final descr = location.LocationDescr?.trim() ?? '';
    final locId = location.LocationID?.toString() ?? '';

    setState(() {
      _idLocation = locId;
      _locationName = descr;
      _locationController.text = descr.isNotEmpty ? "$locCd - $descr" : locCd;
    });
  }

  Future<void> _handleScanLocationQR() async {
    final String? scannedCode = await Get.to(() => const QrScannerScreen());
    if (scannedCode == null || scannedCode.trim().isEmpty) return;

    final String locationCdFromQr = scannedCode.trim();
    setState(() => _isLoading = true);
    debugPrint("QRcode Location Scanned (Modal): $locationCdFromQr");

    try {
      final response = await InventoryService.getLocation(
        params: {'siteid': widget.siteId, 'search': locationCdFromQr},
      );

      if (response != null && response['data'] != null) {
        final rawList = response['data'] as List? ?? [];
        final locationList = rawList
            .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // Tìm Location theo LocationCD
        final matchedLocation = locationList.firstWhereOrNull(
          (l) =>
              l.LocationCD?.toString().trim().toLowerCase() ==
              locationCdFromQr.toLowerCase(),
        );

        if (matchedLocation != null) {
          _applySelectedLocation(matchedLocation);
        } else {
          _showError(
            "Không tìm thấy Vị trí có mã (LocationCD): $locationCdFromQr trong Kho này",
          );
        }
      } else {
        _showError("Không tìm thấy thông tin Vị trí từ QR");
      }
    } catch (e) {
      debugPrint("❌ Lỗi quét QR Vị trí trong Modal: $e");
      _showError("Lỗi tra cứu thông tin Vị trí");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      MyBannerNotification.show(
        context,
        title: "Thông báo",
        message: message,
        type: BannerType.error,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // --- Lưu dữ liệu ---
  void _handleSave() {
    final num soLuong = num.tryParse(_soLuongController.text.trim()) ?? 0;

    final updatedLine = Map<String, dynamic>.from(widget.initialLine);
    updatedLine['idLocation'] = _idLocation;
    updatedLine['locationName'] = _locationName;
    updatedLine['maVatTu'] = _maVatTu;
    updatedLine['tenVatTu'] = _tenVatTu; // Cập nhật tên vật tư ra line detail
    updatedLine['dvtGoc'] = _dvtGoc; // Cập nhật ĐVT gốc ra line detail
    updatedLine['soLo'] = _soLo;
    updatedLine['soLuong'] = soLuong;

    if (widget.onSave != null) {
      widget.onSave!(updatedLine);
    }

    Get.back(result: updatedLine);
  }

  @override
  Widget build(BuildContext context) {
    final contentTheme = AdminTheme.theme.contentTheme;

    return MyModal(
      title: "Chỉnh sửa",
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Tên vật tư
            _buildInfoRow(
              "Tên vật tư:",
              _tenVatTu.isNotEmpty ? _tenVatTu : "---",
              contentTheme,
            ),
            MySpacing.height(8),

            // 2. Mã vật tư (Tự động hiển thị khi quét QR)
            _buildInfoRow(
              "Mã vật tư:",
              _maVatTu.isNotEmpty ? _maVatTu : "---",
              contentTheme,
            ),
            MySpacing.height(8),

            // 3. Số Lô (Tự động hiển thị khi quét QR)
            _buildInfoRow(
              "Số Lô:",
              _soLo.isNotEmpty ? _soLo : "---",
              contentTheme,
            ),
            MySpacing.height(8),

            // 4. ĐVT gốc
            _buildInfoRow(
              "ĐVT gốc:",
              _dvtGoc.isNotEmpty ? _dvtGoc : "---",
              contentTheme,
            ),
            MySpacing.height(16),

            // 5. Chọn / Quét Vị trí (SelectInputBox)
            _buildLabel("Vị trí", contentTheme),
            MySpacing.height(6),
            SelectInputBox(
              hintText: "Chọn hoặc quét mã Vị trí",
              contentTheme: contentTheme,
              value: _locationController.text.isNotEmpty
                  ? _locationController.text
                  : null,
              onTap: _handleSelectLocation,
              onClear: () {
                setState(() {
                  _locationController.clear();
                  _idLocation = '';
                  _locationName = '';
                });
              },
              onScanQr: _handleScanLocationQR,
            ),
            MySpacing.height(14),

            // 6. Quét Mã QR Vật Tư (Mã VT + Số Lô)
            _buildLabel("Quét Mã QR Vật Tư", contentTheme),
            MySpacing.height(6),
            MyInput(
              controller: _qrScanController,
              hintText: "Quét hoặc nhập mã dạng MãVT||SốLô",
              borderRadius: 12,
              onChanged: _parseAndApplyQrCode,
              onScanTap: _handleScanVatTuQR,
            ),
            MySpacing.height(14),

            // 7. Số lượng kiểm kê (Input)
            _buildLabel("Số lượng kiểm kê", contentTheme),
            MySpacing.height(6),
            MyInput(
              controller: _soLuongController,
              keyboardType: TextInputType.number,
              borderRadius: 12,
            ),
          ],
        ),
      ),

      // Footer Nút Hủy và Lưu dữ liệu
      customActions: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: MyContainer(
                  onTap: () => Get.back(),
                  color: const Color(0xFFEAEAEA),
                  padding: MySpacing.y(14),
                  borderRadiusAll: 12,
                  alignment: Alignment.center,
                  child: MyText.bodyMedium(
                    "Hủy",
                    fontWeight: 700,
                    color: const Color(0xFF333333),
                  ),
                ),
              ),
              MySpacing.width(12),
              Expanded(
                child: MyContainer(
                  onTap: _handleSave,
                  color: const Color(0xFF00A86B),
                  padding: MySpacing.y(14),
                  borderRadiusAll: 12,
                  alignment: Alignment.center,
                  child: MyText.bodyMedium(
                    "Lưu dữ liệu",
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

  Widget _buildInfoRow(String label, String value, dynamic contentTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MyText.bodyMedium(
          label,
          fontWeight: 600,
          color: contentTheme.cardTextMuted,
          fontSize: 14,
        ),
        Expanded(
          child: MyText.bodyMedium(
            value,
            textAlign: TextAlign.end,
            fontWeight: 700,
            color: contentTheme.onBackground,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text, dynamic contentTheme) {
    return MyText.bodyMedium(
      text,
      fontWeight: 600,
      color: contentTheme.onBackground,
      fontSize: 14,
    );
  }
}

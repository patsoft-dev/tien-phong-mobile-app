import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qr_app/helper/theme/admin_theme.dart';
import 'package:qr_app/helper/theme/app_notifier.dart';
import 'package:qr_app/helper/widgets/my_container.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/helper/widgets/my_text.dart';
import 'package:qr_app/models/stocktake_model.dart';
import 'package:qr_app/services/inventory_service.dart';
import 'package:qr_app/views/layout/app_scaffold.dart';
import 'package:qr_app/views/layout/top_bar.dart';
import 'package:qr_app/views/screen/qr_scanner_screen.dart';
import 'package:qr_app/views/screen/stocktake/modal/select_location_modal.dart';
import 'package:qr_app/views/screen/stocktake/modal/select_site_modal.dart';
import 'package:qr_app/views/screen/stocktake/modal/stocktake_line_modal.dart';
import 'package:qr_app/widgets/modal/my_alert_modal.dart';
import 'package:qr_app/widgets/modal/my_combodate.dart';
import 'package:qr_app/widgets/my_banner_notification.dart';
import 'package:qr_app/widgets/my_table.dart';
import 'package:qr_app/widgets/select_input_box.dart';
import 'package:remixicon/remixicon.dart';

enum StockTakeDetailMode { create, edit }

class StockTakeDetailScreen extends StatefulWidget {
  final dynamic headerId;
  final StockTakeDetailMode mode;

  const StockTakeDetailScreen({
    super.key,
    this.headerId,
    this.mode = StockTakeDetailMode.create,
  });

  @override
  State<StockTakeDetailScreen> createState() => _StockTakeDetailScreenState();
}

class _StockTakeDetailScreenState extends State<StockTakeDetailScreen> {
  final TextEditingController _siteController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _ghiChuController = TextEditingController();

  bool _isLoading = false;
  DateTime? _selectedDate;
  String _idSite = '';
  String _siteName = '';
  String _idLocation = '';
  String _locationName = '';

  List<Map<String, dynamic>> _linesList = [];

  bool get isEditMode => widget.mode == StockTakeDetailMode.edit;

  final List<TableColumn> _lineColumns = [
    TableColumn(name: "STT", label: "STT", width: 45),
    TableColumn(name: "locationName", label: "Vị trí", width: 110),
    TableColumn(name: "maVatTu", label: "Mã VT", width: 100),
    TableColumn(name: "tenVatTu", label: "Tên vật tư", width: 140),
    TableColumn(name: "soLo", label: "Số lô", width: 100),
    TableColumn(name: "soLuong", label: "Số lượng", width: 80),
    TableColumn(name: "action", label: "Xóa", width: 50),
  ];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    if (isEditMode && widget.headerId != null) {
      _fetchOneStockTake(widget.headerId);
    } else {
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _siteController.dispose();
    _locationController.dispose();
    _ghiChuController.dispose();
    super.dispose();
  }

  /// Tải chi tiết phiếu kiểm kê theo ID
  Future<void> _fetchOneStockTake(dynamic headerId) async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 400));

      final responseData = {
        "date": "2026-09-18",
        "idSite": "",
        "siteName": "",
        "lines": <Map<String, dynamic>>[],
      };

      setState(() {
        _idSite = responseData['idSite']?.toString() ?? '';
        _siteName = responseData['siteName']?.toString() ?? '';
        _siteController.text = _siteName.isNotEmpty ? _siteName : _idSite;
        if (responseData['date'] != null &&
            responseData['date'].toString().isNotEmpty) {
          _selectedDate = DateTime.tryParse(responseData['date'].toString());
        }
        _linesList = List<Map<String, dynamic>>.from(
          responseData['lines'] as List? ?? [],
        );
      });
    } catch (e, stack) {
      debugPrint("❌ Lỗi lấy chi tiết phiếu kiểm kê: $e\n$stack");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorNotification(String message) {
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

  void _handleDeleteLine(int index) {
    final item = _linesList[index];
    final maVatTu = item['maVatTu'] ?? '';

    showDialog(
      context: context,
      builder: (context) => MyAlertModal(
        title: "Xác nhận xóa",
        message: maVatTu.toString().isNotEmpty
            ? "Bạn có chắc chắn muốn xóa vật tư $maVatTu không?"
            : "Bạn có chắc chắn muốn xóa dòng này không?",
        cancelText: "Hủy",
        confirmText: "Đồng ý",
        confirmButtonColor: AdminTheme.theme.contentTheme.danger,
        onConfirm: () {
          Get.back();
          setState(() => _linesList.removeAt(index));

          if (mounted) {
            MyBannerNotification.show(
              context,
              title: "Thành công",
              message: "Đã xóa dòng vật tư",
              type: BannerType.success,
              duration: const Duration(seconds: 1),
            );
          }
        },
      ),
    );
  }

  // --- Xử lý Chọn & Quét Kho ---
  Future<void> _handleSelectSite() async {
    final site = await SelectSiteModal.show(context);
    if (site != null) _applySelectedSite(site);
  }

  void _applySelectedSite(SiteModel site) {
    final siteCd = site.SiteCD?.trim() ?? '';
    final descr = site.Descr?.trim() ?? '';

    setState(() {
      _idSite = site.SiteID?.toString() ?? '';
      _siteName = descr;
      _siteController.text = descr.isNotEmpty ? "$siteCd - $descr" : siteCd;

      // Reset Vị trí khi chọn Kho mới
      _idLocation = '';
      _locationName = '';
      _locationController.clear();
    });
  }

  Future<void> _handleScanSiteQR() async {
    final String? scannedCode = await Get.to(() => const QrScannerScreen());
    if (scannedCode == null || scannedCode.trim().isEmpty) return;

    final String siteCdFromQr = scannedCode.trim();
    setState(() => _isLoading = true);

    try {
      final response = await InventoryService.getSite(
        params: {'page': "1", 'limit': 50},
      );

      if (response != null && response['data'] != null) {
        final siteList = (response['data'] as List)
            .map((e) => SiteModel.fromJson(e as Map<String, dynamic>))
            .toList();

        final matchedSite = siteList.firstWhereOrNull(
          (s) =>
              s.SiteCD?.toString().trim().toLowerCase() ==
              siteCdFromQr.toLowerCase(),
        );

        if (matchedSite != null) {
          _applySelectedSite(matchedSite);
        } else {
          _showErrorNotification(
            "Không tìm thấy Kho có mã (SiteCD): $siteCdFromQr",
          );
        }
      } else {
        _showErrorNotification("Không tìm thấy thông tin Kho từ QR");
      }
    } catch (e) {
      _showErrorNotification("Lỗi tra cứu thông tin Kho");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Xử lý Chọn & Quét Vị Trí ---
  Future<void> _handleSelectLocation() async {
    if (_idSite.isEmpty) {
      _showErrorNotification("Vui lòng chọn Kho trước!");
      return;
    }

    final location = await SelectLocationModal.show(context, siteId: _idSite);
    if (location != null) _applySelectedLocation(location);
  }

  void _applySelectedLocation(LocationModel location) {
    final locCd = location.LocationCD?.trim() ?? '';
    final descr = location.LocationDescr?.trim() ?? '';

    setState(() {
      _idLocation = location.LocationID?.toString() ?? '';
      _locationName = descr;
      _locationController.text = descr.isNotEmpty ? "$locCd - $descr" : locCd;
    });
  }

  Future<void> _handleScanLocationQR() async {
    if (_idSite.isEmpty) {
      _showErrorNotification("Vui lòng chọn Kho trước!");
      return;
    }

    final String? scannedCode = await Get.to(() => const QrScannerScreen());
    if (scannedCode == null || scannedCode.trim().isEmpty) return;

    final String locationCdFromQr = scannedCode.trim();
    setState(() => _isLoading = true);

    try {
      final response = await InventoryService.getLocation(
        params: {'siteid': _idSite, 'search': locationCdFromQr},
      );

      if (response != null && response['data'] != null) {
        final locationList = (response['data'] as List)
            .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
            .toList();

        final matchedLocation = locationList.firstWhereOrNull(
          (l) =>
              l.LocationCD?.toString().trim().toLowerCase() ==
              locationCdFromQr.toLowerCase(),
        );

        if (matchedLocation != null) {
          _applySelectedLocation(matchedLocation);
        } else {
          _showErrorNotification(
            "Không tìm thấy Vị trí có mã: $locationCdFromQr trong Kho này",
          );
        }
      } else {
        _showErrorNotification("Không tìm thấy thông tin Vị trí từ QR");
      }
    } catch (e) {
      _showErrorNotification("Lỗi tra cứu thông tin Vị trí");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Thêm & Sửa Line kiểm kê ---
  void _handleAddStockTakeLine() async {
    if (_idSite.isEmpty) {
      _showErrorNotification("Vui lòng chọn Kho trước khi thêm vật tư!");
      return;
    }

    // Không dùng dữ liệu giả lập, mặc định chuỗi rỗng
    final initialLine = {
      "idLocation": _idLocation,
      "locationName": _locationName,
      "maVatTu": "",
      "tenVatTu": "",
      "soLo": "",
      "soLuong": 1,
      "dvtGoc": "",
    };

    final newLine = await StockTakeLineModal.show(
      context,
      initialLine: initialLine,
      siteId: _idSite,
    );

    if (newLine != null) {
      setState(() => _linesList.add(newLine));
    }
  }

  void _handleEditStockTakeLine(Map<String, dynamic> item, int index) async {
    if (_idSite.isEmpty) {
      _showErrorNotification("Vui lòng chọn Kho trước!");
      return;
    }

    final updatedLine = await StockTakeLineModal.show(
      context,
      initialLine: item,
      siteId: _idSite,
    );

    if (updatedLine != null) {
      setState(() => _linesList[index] = updatedLine);
    }
  }

  // --- Lưu dữ liệu ---
  Future<void> _handleSave() async {
    if (_idSite.isEmpty) {
      _showErrorNotification("Vui lòng chọn Kho/Site");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final payload = {
        "date": _selectedDate?.toIso8601String() ?? '',
        "idSite": _idSite,
        "siteName": _siteName,
        "lines": _linesList,
      };

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        MyBannerNotification.show(
          context,
          title: "Thành công",
          message: isEditMode
              ? "Cập nhật phiếu kiểm kê thành công"
              : "Tạo mới phiếu kiểm kê thành công",
          type: BannerType.success,
          duration: const Duration(seconds: 1),
        );
        Get.back(result: true);
      }
    } catch (e) {
      _showErrorNotification("Đã xảy ra lỗi trong quá trình lưu dữ liệu");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Custom Render Cell Table ---
  Widget _renderCustomCell(
    String columnName,
    Map<String, dynamic> item,
    int index,
  ) {
    switch (columnName) {
      case "action":
        return InkWell(
          onTap: () => _handleDeleteLine(index),
          child: const Padding(
            padding: EdgeInsets.all(4.0),
            child: Icon(Icons.delete_outline, color: Colors.red, size: 20),
          ),
        );
      case "STT":
        return MyText.bodySmall(
          '${index + 1}',
          fontWeight: 600,
          fontSize: 13,
          textAlign: TextAlign.center,
        );
      case "soLuong":
        return MyText.bodySmall(
          '${item['soLuong'] ?? 0}',
          fontSize: 13,
          textAlign: TextAlign.center,
          fontWeight: 600,
        );
      default:
        final rawValue = item[columnName];
        return MyText.bodySmall(
          rawValue?.toString() ?? '',
          fontSize: 13,
          textAlign: columnName == "tenVatTu"
              ? TextAlign.start
              : TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
    }
  }

  // Component phụ dùng chung hiển thị / chọn Kho - Vị trí
  Widget _buildSelectableOrStaticField({
    required String label,
    required String valueText,
    required TextEditingController controller,
    required VoidCallback onTap,
    required VoidCallback onClear,
    required VoidCallback onScanQr,
    required dynamic contentTheme,
    required String hintText,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: MyText.bodySmall(
            label,
            fontWeight: 600,
            fontSize: 14,
            color: contentTheme.onBackground,
          ),
        ),
        Expanded(
          child: isEditMode
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  alignment: Alignment.centerLeft,
                  child: MyText.bodyMedium(
                    valueText.isNotEmpty ? valueText : "---",
                    fontWeight: 700,
                    color: contentTheme.onBackground,
                  ),
                )
              : SelectInputBox(
                  hintText: hintText,
                  contentTheme: contentTheme,
                  value: controller.text.isNotEmpty ? controller.text : null,
                  onTap: onTap,
                  onClear: onClear,
                  onScanQr: onScanQr,
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleText = isEditMode
        ? "Chi tiết phiếu Kiểm kê"
        : "Tạo mới phiếu Kiểm kê";

    return Consumer<AppNotifier>(
      builder: (context, notifier, child) {
        final contentTheme = AdminTheme.theme.contentTheme;

        return AppScaffold(
          isScrollable: true,
          bodyBuilder: (context, openDrawer) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TopBar(
                  title: titleText,
                  showBackButton: true,
                  actions: [
                    IconButton(
                      icon: Icon(
                        RemixIcons.save_3_line,
                        color: contentTheme.onBackground,
                        size: 22,
                      ),
                      tooltip: "Lưu",
                      onPressed: _handleSave,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      MyContainer(
                        paddingAll: 16,
                        borderRadiusAll: 12,
                        color: contentTheme.cardBackground,
                        bordered: true,
                        borderColor: contentTheme.border,
                        child: Column(
                          children: [
                            // 1. Ngày kiểm kê
                            Row(
                              children: [
                                SizedBox(
                                  width: 90,
                                  child: MyText.bodySmall(
                                    "Ngày kiểm:",
                                    fontWeight: 600,
                                    fontSize: 14,
                                    color: contentTheme.onBackground,
                                  ),
                                ),
                                Expanded(
                                  child: MyCombodate(
                                    value: _selectedDate,
                                    hintText: "Chọn ngày kiểm kê",
                                    onChanged: (date) {
                                      setState(() => _selectedDate = date);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            MySpacing.height(12),

                            // 2. Chọn / hiển thị Kho
                            _buildSelectableOrStaticField(
                              label: "Kho:",
                              valueText: _siteName.isNotEmpty
                                  ? _siteName
                                  : _idSite,
                              controller: _siteController,
                              hintText: "Chọn hoặc quét mã Kho",
                              contentTheme: contentTheme,
                              onTap: _handleSelectSite,
                              onClear: () {
                                setState(() {
                                  _siteController.clear();
                                  _idSite = '';
                                  _siteName = '';
                                  _locationController.clear();
                                  _idLocation = '';
                                  _locationName = '';
                                });
                              },
                              onScanQr: _handleScanSiteQR,
                            ),
                            MySpacing.height(12),

                            // 3. Chọn / hiển thị Vị trí
                            _buildSelectableOrStaticField(
                              label: "Vị trí:",
                              valueText: _locationName.isNotEmpty
                                  ? _locationName
                                  : _idLocation,
                              controller: _locationController,
                              hintText: "Chọn hoặc quét mã Vị trí",
                              contentTheme: contentTheme,
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
                          ],
                        ),
                      ),
                      MySpacing.height(16),

                      // Header Danh sách vật tư
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyText.bodyMedium(
                            "Danh sách chi tiết vật tư",
                            fontWeight: 700,
                            fontSize: 16,
                            color: contentTheme.onBackground,
                          ),
                          InkWell(
                            onTap: _handleAddStockTakeLine,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: contentTheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                RemixIcons.add_line,
                                color: contentTheme.onPrimary,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                      MySpacing.height(8),

                      // Bảng chi tiết dòng vật tư
                      _isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(),
                            )
                          : MyTable<Map<String, dynamic>>(
                              data: _linesList,
                              columns: _lineColumns,
                              renderCell: _renderCustomCell,
                              borderRadius: 8,
                              emptyText: "Chưa có dữ liệu vật tư kiểm kê",
                              onRowPress: (item, index) =>
                                  _handleEditStockTakeLine(item, index),
                            ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

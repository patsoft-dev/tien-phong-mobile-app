import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_app/helper/theme/admin_theme.dart';
import 'package:qr_app/helper/theme/app_notifier.dart';
import 'package:qr_app/helper/utils/utils.dart';
import 'package:qr_app/helper/widgets/my_container.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/helper/widgets/my_text.dart';
import 'package:qr_app/services/inventory_service.dart';
import 'package:qr_app/views/layout/app_scaffold.dart';
import 'package:qr_app/views/layout/top_bar.dart';
import 'package:qr_app/views/screen/qr_scanner_screen.dart';
import 'package:qr_app/widgets/my_banner_notification.dart';
import 'package:qr_app/widgets/my_input.dart';
import 'package:remixicon/remixicon.dart';

class InventoryCheckScreen extends StatefulWidget {
  const InventoryCheckScreen({super.key});

  @override
  State<InventoryCheckScreen> createState() => _InventoryCheckScreenState();
}

class _InventoryCheckScreenState extends State<InventoryCheckScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  bool _isScanned = false;
  String _inventoryID = "";
  String _lotNbr = "";
  List<Map<String, dynamic>> _inventoryList = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Mở màn hình quét QR Camera và xử lý kết quả nhận về
  Future<void> _openQRScanner() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerScreen()),
    );

    if (result != null && result.isNotEmpty) {
      _searchController.text = result;
      _fetchInventoryData(result);
    }
  }

  /// Gọi API lấy dữ liệu tồn kho dựa trên mã QR
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
      _inventoryID = inventoryCd;
      _lotNbr = lotSerialNbr;
      _isLoading = true;
    });

    try {
      final response = await InventoryService.getLotSerialDetail(
        inventory_cd: _inventoryID,
        lot_serial_nbr: _lotNbr,
      );

      if (mounted) {
        final rawData = response?['data'];
        final isDataValid = rawData is List && rawData.isNotEmpty;

        if (response != null && response['status'] == true && isDataValid) {
          setState(() {
            _inventoryList = List<Map<String, dynamic>>.from(rawData);
            _isScanned = true;
          });

          MyBannerNotification.show(
            context,
            title: "Thành công",
            message:
                response['message']?.toString() ?? 'Lấy dữ liệu thành công',
            type: BannerType.success,
          );
        } else {
          setState(() {
            _inventoryList = [];
            _isScanned = false;
          });

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

  void _handleSearchSubmit() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      MyBannerNotification.show(
        context,
        title: "Thông báo",
        message: "Vui lòng nhập mã để tìm kiếm",
        type: BannerType.error,
      );
      return;
    }
    _fetchInventoryData(query);
  }

  Widget _buildSearchBar(dynamic contentTheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: contentTheme.background,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: MyInput(
                  controller: _searchController,
                  hintText: "QR Code...",
                  borderRadius: 12,
                  fillColor: contentTheme.background,
                  borderColor: contentTheme.border,
                  prefixIcon: RemixIcons.search_line,
                  textInputAction: TextInputAction.search,
                  onFieldSubmitted: (_) => _handleSearchSubmit(),
                ),
              ),
              MySpacing.width(8),
              InkWell(
                onTap: _openQRScanner,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: contentTheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        RemixIcons.qr_code_line,
                        size: 20,
                        color: contentTheme.onPrimary,
                      ),
                      MySpacing.width(6),
                      MyText.bodyMedium(
                        "SCAN",
                        fontWeight: 700,
                        color: contentTheme.onPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_inventoryID.isNotEmpty || _lotNbr.isNotEmpty) ...[
            MySpacing.height(10),
            if (_inventoryID.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText.bodySmall(
                    "Inventory ID:",
                    fontWeight: 600,
                    color: contentTheme.cardTextMuted,
                  ),
                  MyText.bodySmall(
                    _inventoryID,
                    fontWeight: 700,
                    fontSize: 15,
                    color: contentTheme.onBackground,
                  ),
                ],
              ),
            if (_lotNbr.isNotEmpty) ...[
              MySpacing.height(4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText.bodySmall(
                    "Lot/Serial Number:",
                    fontWeight: 600,
                    color: contentTheme.cardTextMuted,
                  ),
                  MyText.bodySmall(
                    _lotNbr,
                    fontWeight: 700,
                    fontSize: 15,
                    color: contentTheme.onBackground,
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  /// Widget Trạng thái rỗng khi chưa có kết quả quét
  Widget _buildEmptyState(dynamic contentTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            RemixIcons.qr_code_line,
            size: 100,
            color: contentTheme.onBackground.withOpacity(0.5),
          ),
          MySpacing.height(24),
          InkWell(
            onTap: _openQRScanner,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color: contentTheme.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: contentTheme.primary.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    RemixIcons.qr_code_line,
                    size: 20,
                    color: contentTheme.onPrimary,
                  ),
                  MySpacing.width(8),
                  MyText.bodyMedium(
                    "SCAN",
                    fontWeight: 700,
                    color: contentTheme.onPrimary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget Card chi tiết từng sản phẩm tồn kho
  Widget _buildItemCard(
    Map<String, dynamic> item,
    int index,
    dynamic contentTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: MyText.bodyMedium(
            "Item ${index + 1}",
            fontWeight: 700,
            color: contentTheme.primary,
          ),
        ),
        MyContainer(
          borderRadiusAll: 16,
          paddingAll: 16,
          color: contentTheme.cardBackground,
          bordered: true,
          borderColor: contentTheme.border,
          child: Column(
            children: [
              _buildInfoRow(
                "Inventory ID",
                item['inventory_cd']?.toString().trim() ?? "---",
                contentTheme,
              ),
              Divider(height: 16, thickness: 1, color: contentTheme.border),
              _buildInfoRow(
                "Inventory Name",
                item['inventory_name'] ?? "---",
                contentTheme,
              ),
              Divider(height: 16, thickness: 1, color: contentTheme.border),
              _buildInfoRow(
                "Warehouse",
                item['warehouse_name'] ?? "---",
                contentTheme,
              ),
              Divider(height: 16, thickness: 1, color: contentTheme.border),
              _buildInfoRow(
                "Location",
                item['location_name'] ?? "---",
                contentTheme,
              ),
              Divider(height: 16, thickness: 1, color: contentTheme.border),
              _buildInfoRow(
                "Lot/Serial Nbr",
                item['lot_serial_nbr'] ?? "---",
                contentTheme,
              ),
              Divider(height: 16, thickness: 1, color: contentTheme.border),
              _buildInfoRow(
                "Qty",
                "${item['qty_on_hand'] ?? 0} ${item['base_unit'] ?? ''}",
                contentTheme,
                isBoldValue: true,
              ),
              Divider(height: 16, thickness: 1, color: contentTheme.border),
              _buildInfoRow(
                "Receipt Date",
                item['receipt_date'] != null
                    ? Utils.formatDate(
                        item['receipt_date'],
                        pattern: 'dd/MM/yyyy',
                      )
                    : "---",
                contentTheme,
              ),
              Divider(height: 16, thickness: 1, color: contentTheme.border),
              _buildInfoRow(
                "Expiration Date",
                item['expire_date'] != null
                    ? Utils.formatDate(
                        item['expire_date'],
                        pattern: 'dd/MM/yyyy',
                      )
                    : "---",
                contentTheme,
              ),
              Divider(height: 16, thickness: 1, color: contentTheme.border),
              _buildInfoRow(
                "Manufactured Date",
                item['mf_date'] ?? "---",
                contentTheme,
              ),
            ],
          ),
        ),
        MySpacing.height(16),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    dynamic contentTheme, {
    bool isBoldValue = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MyText.bodySmall(
          label,
          fontWeight: 600,
          color: contentTheme.cardTextMuted,
          fontSize: 13,
        ),
        MySpacing.width(16),
        Expanded(
          child: MyText.bodySmall(
            value,
            fontWeight: isBoldValue ? 700 : 600,
            color: contentTheme.onBackground,
            fontSize: 13,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
      builder: (context, notifier, child) {
        final contentTheme = AdminTheme.theme.contentTheme;

        return AppScaffold(
          isScrollable: false,
          bodyBuilder: (context, openDrawer) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TopBar(
                  title: "Kiểm tồn kho",
                  showBackButton: false,
                  actions: [
                    IconButton(
                      icon: Icon(
                        RemixIcons.refresh_line,
                        color: contentTheme.onBackground,
                        size: 26,
                      ),
                      tooltip: "Tải lại",
                      onPressed: () {
                        if (_searchController.text.isNotEmpty) {
                          _fetchInventoryData(_searchController.text);
                        }
                      },
                    ),
                  ],
                ),
                _buildSearchBar(contentTheme),
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: contentTheme.primary,
                          ),
                        )
                      : !_isScanned || _inventoryList.isEmpty
                      ? _buildEmptyState(contentTheme)
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _inventoryList.length,
                          itemBuilder: (context, index) {
                            return _buildItemCard(
                              _inventoryList[index],
                              index,
                              contentTheme,
                            );
                          },
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

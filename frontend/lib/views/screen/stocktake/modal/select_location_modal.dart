import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_app/helper/theme/admin_theme.dart';
import 'package:qr_app/helper/widgets/my_container.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/helper/widgets/my_text.dart';
import 'package:qr_app/models/stocktake_model.dart';
import 'package:qr_app/services/inventory_service.dart';
import 'package:qr_app/widgets/my_modal.dart';
import 'package:qr_app/widgets/my_pagination.dart';

class SelectLocationModal extends StatefulWidget {
  final dynamic siteId; // Nhận siteId từ trang Detail
  final Function(LocationModel location)? onSelect;

  const SelectLocationModal({super.key, required this.siteId, this.onSelect});

  /// Static helper mở modal chọn Location (yêu cầu truyền siteId)
  static Future<LocationModel?> show(
    BuildContext context, {
    required dynamic siteId,
  }) {
    return showDialog<LocationModel>(
      context: context,
      barrierDismissible: true,
      builder: (context) => SelectLocationModal(siteId: siteId),
    );
  }

  @override
  State<SelectLocationModal> createState() => _SelectLocationModalState();
}

class _SelectLocationModalState extends State<SelectLocationModal> {
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;
  final int _limit = 10;
  List<LocationModel> _locationList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLocationData();
    });
  }

  Future<void> _fetchLocationData() async {
    setState(() => _isLoading = true);

    try {
      final params = {
        'siteid': widget.siteId, // Tự động đưa siteid vào param API
        'page': _currentPage,
        'limit': _limit,
        if (_searchController.text.trim().isNotEmpty)
          'search': _searchController.text.trim(),
      };

      final response = await InventoryService.getLocation(params: params);

      if (mounted) {
        if (response != null &&
            (response['status'] == true || response['data'] != null)) {
          final total = response['total'] ?? 0;
          final rawData = response['data'] as List? ?? [];

          setState(() {
            _locationList = rawData
                .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
                .toList();
            _totalPages = (total / _limit).ceil();
            if (_totalPages < 1) _totalPages = 1;
          });
        } else {
          setState(() {
            _locationList = [];
            _totalPages = 1;
          });
        }
      }
    } catch (e) {
      debugPrint("❌ [SelectLocationModal] Lỗi fetch data: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onPageChange(int page) {
    if (page != _currentPage) {
      setState(() => _currentPage = page);
      _fetchLocationData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentTheme = AdminTheme.theme.contentTheme;

    return MyModal(
      title: "CHỌN VỊ TRÍ / LOCATION",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Danh sách Location
          SizedBox(
            height: 320,
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: contentTheme.primary,
                    ),
                  )
                : _locationList.isEmpty
                ? Center(
                    child: Text(
                      "Không có dữ liệu vị trí",
                      style: TextStyle(color: contentTheme.cardTextMuted),
                    ),
                  )
                : ListView.separated(
                    itemCount: _locationList.length,
                    separatorBuilder: (context, index) => MySpacing.height(8),
                    itemBuilder: (context, index) {
                      final item = _locationList[index];
                      final String locCode = item.LocationCD?.trim() ?? '';
                      final String descr = item.LocationDescr?.trim() ?? '';

                      return MyContainer.bordered(
                        onTap: () {
                          if (widget.onSelect != null) {
                            widget.onSelect!(item);
                          }
                          Get.back(result: item);
                        },
                        borderRadiusAll: 4,
                        padding: MySpacing.xy(16, 12),
                        color: contentTheme.cardBackground,
                        borderColor: contentTheme.border,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                MyText.bodySmall(
                                  "Mã Vị trí:",
                                  fontWeight: 700,
                                  color: contentTheme.cardTextMuted,
                                  fontSize: 12,
                                ),
                                MySpacing.width(8),
                                MyText.bodyMedium(
                                  locCode,
                                  fontWeight: 700,
                                  color: contentTheme.primary,
                                ),
                              ],
                            ),
                            if (descr.isNotEmpty) ...[
                              MySpacing.height(4),
                              MyText.bodySmall(
                                descr,
                                fontWeight: 600,
                                color: contentTheme.onBackground,
                                fontSize: 14,
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),

          MySpacing.height(12),

          // 2. Phân trang
          if (_totalPages > 1)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: MyPagination(
                  currentPage: _currentPage,
                  totalPage: _totalPages,
                  onPageChange: _onPageChange,
                ),
              ),
            ),
        ],
      ),

      // 3. Custom Footer Nút Hủy
      customActions: [
        Expanded(
          child: Center(
            child: MyContainer(
              onTap: () => Get.back(),
              color: contentTheme.danger,
              padding: MySpacing.xy(32, 12),
              borderRadiusAll: 12,
              child: MyText.bodyMedium(
                "Cancel",
                fontWeight: 600,
                color: contentTheme.onDanger,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

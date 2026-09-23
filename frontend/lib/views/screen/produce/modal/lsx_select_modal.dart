import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_app/helper/theme/admin_theme.dart';
import 'package:qr_app/helper/widgets/my_container.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/helper/widgets/my_text.dart';
import 'package:qr_app/models/discrete_model.dart';
import 'package:qr_app/services/produce_service.dart';
import 'package:qr_app/widgets/my_input.dart';
import 'package:qr_app/widgets/my_modal.dart';
import 'package:qr_app/widgets/my_pagination.dart';
import 'package:remixicon/remixicon.dart';

class SelectLsxModal extends StatefulWidget {
  final Function(DiscreteModel lsx)? onSelect;

  const SelectLsxModal({super.key, this.onSelect});

  /// Static helper để mở modal chọn LSX
  static Future<DiscreteModel?> show(BuildContext context) {
    return showDialog<DiscreteModel>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const SelectLsxModal(),
    );
  }

  @override
  State<SelectLsxModal> createState() => _SelectLsxModalState();
}

class _SelectLsxModalState extends State<SelectLsxModal> {
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;
  final int _limit = 10;
  List<DiscreteModel> _lsxList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLsxData();
    });
  }

  Future<void> _fetchLsxData() async {
    setState(() => _isLoading = true);

    try {
      final params = {
        'page': _currentPage,
        'limit': _limit,
        'filter': _searchController.text.trim(),
      };

      final response = await ProduceService.getDiscreteByLSX(params);

      if (mounted) {
        if (response != null &&
            (response['status'] == true || response['data'] != null)) {
          final total = response['total'] ?? 0;
          final rawData = response['data'] as List? ?? [];

          setState(() {
            // 💡 Dùng DiscreteModel.fromJson để map từng phần tử từ JSON
            _lsxList = rawData
                .map((e) => DiscreteModel.fromJson(e as Map<String, dynamic>))
                .toList();
            _totalPages = (total / _limit).ceil();
            if (_totalPages < 1) _totalPages = 1;
          });
        } else {
          setState(() {
            _lsxList = [];
            _totalPages = 1;
          });
        }
      }
    } catch (e) {
      debugPrint("❌ [SelectLsxModal] Lỗi fetch data: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onPageChange(int page) {
    if (page != _currentPage) {
      setState(() => _currentPage = page);
      _fetchLsxData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentTheme = AdminTheme.theme.contentTheme;

    return MyModal(
      title: "CHỌN LỆNH SẢN XUẤT",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Search Bar
          MyInput(
            controller: _searchController,
            hintText: "Nhập mã LSX để tìm kiếm...",
            borderRadius: 4,
            prefixIcon: RemixIcons.search_line,
            textInputAction: TextInputAction.search,
            suffixIcon: _searchController.text.isNotEmpty
                ? RemixIcons.close_circle_fill
                : null,
            onSuffixTap: () {
              _searchController.clear();
              setState(() => _currentPage = 1);
              _fetchLsxData();
            },
            onFieldSubmitted: (_) {
              setState(() => _currentPage = 1);
              _fetchLsxData();
            },
          ),

          MySpacing.height(12),

          // 2. Danh sách LSX Items
          SizedBox(
            height: 320,
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: contentTheme.primary,
                    ),
                  )
                : _lsxList.isEmpty
                ? Center(
                    child: Text(
                      "Không có dữ liệu",
                      style: TextStyle(color: contentTheme.cardTextMuted),
                    ),
                  )
                : ListView.separated(
                    itemCount: _lsxList.length,
                    separatorBuilder: (context, index) => MySpacing.height(8),
                    itemBuilder: (context, index) {
                      // 💡 Đã sửa: Thêm index để lấy đúng item trong danh sách
                      final item = _lsxList[index];
                      final discreteNbr = item.discrete_nbr ?? '';

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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                MyText.bodySmall(
                                  "LSX:",
                                  fontWeight: 700,
                                  color: contentTheme.cardTextMuted,
                                  fontSize: 12,
                                ),
                                MySpacing.width(12),
                                MyText.bodyMedium(
                                  discreteNbr,
                                  fontWeight: 700,
                                  color: contentTheme.onBackground,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          MySpacing.height(12),

          // 3. Phân trang
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

      // 4. Custom Footer Nút Hủy
      customActions: [
        Expanded(
          child: Center(
            child: MyContainer(
              onTap: () => Get.back(),
              color: contentTheme.danger,
              padding: MySpacing.xy(32, 10),
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

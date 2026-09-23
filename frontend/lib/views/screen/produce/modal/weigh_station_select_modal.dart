import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_app/helper/theme/admin_theme.dart';
import 'package:qr_app/helper/widgets/my_container.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/helper/widgets/my_text.dart';
import 'package:qr_app/models/discrete_model.dart';
import 'package:qr_app/widgets/my_input.dart';
import 'package:qr_app/widgets/my_modal.dart';
import 'package:qr_app/widgets/my_pagination.dart';
import 'package:remixicon/remixicon.dart';

class SelectWeighStationModal extends StatefulWidget {
  final List<WeighStationModel> weighStationList;
  final Function(WeighStationModel weighStation)? onSelect;

  const SelectWeighStationModal({
    super.key,
    required this.weighStationList,
    this.onSelect,
  });

  /// Static helper để mở modal chọn Trạm Cân
  static Future<WeighStationModel?> show(
    BuildContext context, {
    required List<WeighStationModel> weighStationList,
  }) {
    return showDialog<WeighStationModel>(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          SelectWeighStationModal(weighStationList: weighStationList),
    );
  }

  @override
  State<SelectWeighStationModal> createState() =>
      _SelectWeighStationModalState();
}

class _SelectWeighStationModalState extends State<SelectWeighStationModal> {
  final TextEditingController _searchController = TextEditingController();

  int _currentPage = 1;
  final int _limit = 10;
  List<WeighStationModel> _filteredList = [];

  @override
  void initState() {
    super.initState();
    _filteredList = widget.weighStationList;
  }

  void _filterData(String keyword) {
    final query = keyword.trim().toLowerCase();
    setState(() {
      _currentPage = 1;
      if (query.isEmpty) {
        _filteredList = widget.weighStationList;
      } else {
        _filteredList = widget.weighStationList.where((item) {
          final code = (item.ObjectCode ?? '').toLowerCase();
          final name = (item.ObjectName ?? '').toLowerCase();
          return code.contains(query) || name.contains(query);
        }).toList();
      }
    });
  }

  void _onPageChange(int page) {
    setState(() => _currentPage = page);
  }

  @override
  Widget build(BuildContext context) {
    final contentTheme = AdminTheme.theme.contentTheme;

    // Tính toán phân trang client
    final totalPages = (_filteredList.length / _limit).ceil().clamp(1, 999);
    final startIndex = (_currentPage - 1) * _limit;
    final endIndex = (startIndex + _limit < _filteredList.length)
        ? startIndex + _limit
        : _filteredList.length;

    final currentPageItems = (startIndex < _filteredList.length)
        ? _filteredList.sublist(startIndex, endIndex)
        : <WeighStationModel>[];

    return MyModal(
      title: "CHỌN TRẠM CÂN",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Search Bar
          MyInput(
            controller: _searchController,
            hintText: "Nhập mã hoặc tên trạm cân...",
            borderRadius: 4,
            prefixIcon: RemixIcons.search_line,
            textInputAction: TextInputAction.search,
            suffixIcon: _searchController.text.isNotEmpty
                ? RemixIcons.close_circle_fill
                : null,
            onChanged: _filterData,
            onSuffixTap: () {
              _searchController.clear();
              _filterData('');
            },
          ),

          MySpacing.height(12),

          // 2. Danh sách Trạm cân Items
          SizedBox(
            height: 320,
            child: currentPageItems.isEmpty
                ? Center(
                    child: Text(
                      "Không có dữ liệu",
                      style: TextStyle(color: contentTheme.cardTextMuted),
                    ),
                  )
                : ListView.separated(
                    itemCount: currentPageItems.length,
                    separatorBuilder: (context, index) => MySpacing.height(8),
                    itemBuilder: (context, index) {
                      final item = currentPageItems[index];
                      final objectCode = item.ObjectCode ?? '';
                      final objectName = item.ObjectName ?? '';

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
                          children: [
                            MyText.bodySmall(
                              objectCode,
                              fontWeight: 700,
                              color: contentTheme.primary,
                              fontSize: 12,
                            ),
                            MySpacing.width(16),
                            Expanded(
                              child: MyText.bodyMedium(
                                objectName,
                                fontWeight: 600,
                                color: contentTheme.onBackground,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          MySpacing.height(12),

          // 3. Phân trang
          if (totalPages > 1)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: MyPagination(
                  currentPage: _currentPage,
                  totalPage: totalPages,
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
                "Hủy",
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

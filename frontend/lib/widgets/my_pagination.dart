import 'package:flutter/material.dart';
import 'package:qr_app/helper/theme/admin_theme.dart';
import 'package:qr_app/helper/widgets/my_button.dart';
import 'package:qr_app/helper/widgets/my_container.dart';
import 'package:qr_app/helper/widgets/my_text.dart';
import 'package:remixicon/remixicon.dart';

class MyPagination extends StatelessWidget {
  final int currentPage;
  final int totalPage;
  final ValueChanged<int> onPageChange;
  final int maxVisiblePages;

  const MyPagination({
    super.key,
    required this.currentPage,
    required this.totalPage,
    required this.onPageChange,
    this.maxVisiblePages = 5,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPage <= 0) return const SizedBox.shrink();

    final contentTheme = AdminTheme.theme.contentTheme;
    final List<int> pageNumbers = _getPageNumbers();

    return Center(
      child: MyContainer.bordered(
        paddingAll: 4, // Bán kính viền thu gọn lại
        borderRadiusAll: 8,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Nút Previous
            SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  RemixIcons.arrow_left_s_line,
                  size: 25,
                  color: currentPage > 1
                      ? contentTheme.onBackground
                      : contentTheme.disabled,
                ),
                onPressed: currentPage > 1
                    ? () => onPageChange(currentPage - 1)
                    : null,
              ),
            ),

            // Danh sách các nút số trang
            for (int page in pageNumbers)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: MyButton(
                    backgroundColor: page == currentPage
                        ? contentTheme.primary
                        : Colors.transparent,
                    elevation: 0,
                    padding: EdgeInsets
                        .zero, // Bỏ padding cố định để không bị phình to
                    borderRadiusAll: 6,
                    onPressed: () {
                      if (page != currentPage) {
                        onPageChange(page);
                      }
                    },
                    child: Center(
                      child: MyText.bodyMedium(
                        '$page',
                        fontWeight: page == currentPage ? 700 : 500,
                        color: page == currentPage
                            ? contentTheme.onPrimary
                            : contentTheme.onBackground,
                      ),
                    ),
                  ),
                ),
              ),

            // Nút Next
            SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  RemixIcons.arrow_right_s_line,
                  size: 25,
                  color: currentPage < totalPage
                      ? contentTheme.onBackground
                      : contentTheme.disabled,
                ),
                onPressed: currentPage < totalPage
                    ? () => onPageChange(currentPage + 1)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Thuật toán hiển thị dải trang thông minh xung quanh currentPage
  List<int> _getPageNumbers() {
    if (totalPage <= maxVisiblePages) {
      return List.generate(totalPage, (index) => index + 1);
    }

    int start = currentPage - (maxVisiblePages ~/ 2);
    int end = currentPage + (maxVisiblePages ~/ 2);

    if (start < 1) {
      start = 1;
      end = maxVisiblePages;
    }

    if (end > totalPage) {
      end = totalPage;
      start = totalPage - maxVisiblePages + 1;
    }

    return List.generate(end - start + 1, (index) => start + index);
  }
}

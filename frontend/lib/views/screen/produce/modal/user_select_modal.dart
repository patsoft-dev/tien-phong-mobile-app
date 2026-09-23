import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_app/helper/theme/admin_theme.dart';
import 'package:qr_app/helper/widgets/my_container.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/helper/widgets/my_text.dart';
import 'package:qr_app/services/user_service.dart';
import 'package:qr_app/widgets/my_input.dart';
import 'package:qr_app/widgets/my_modal.dart';
import 'package:qr_app/widgets/my_pagination.dart';
import 'package:remixicon/remixicon.dart';

class SelectUserModal extends StatefulWidget {
  final Function(Map<String, dynamic> user)? onSelect;

  const SelectUserModal({super.key, this.onSelect});

  /// Static helper để mở modal
  static Future<Map<String, dynamic>?> show(BuildContext context) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const SelectUserModal(),
    );
  }

  @override
  State<SelectUserModal> createState() => _SelectUserModalState();
}

class _SelectUserModalState extends State<SelectUserModal> {
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;
  final int _limit = 10;
  List<Map<String, dynamic>> _userList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUsers();
    });
  }

  Future<void> _fetchUsers() async {
    debugPrint("🚀 [SelectUserModal] Bắt đầu gọi _fetchUsers()");

    setState(() => _isLoading = true);

    try {
      final response = await UserService.getUsersByCompany(
        page: _currentPage,
        limit: _limit,
        keyword: _searchController.text.trim(),
      );

      debugPrint("📦 [SelectUserModal] Response API: $response");

      if (mounted) {
        if (response != null &&
            (response['status'] == true || response['data'] != null)) {
          final total = response['total'] ?? 0;
          final rawData = response['data'] as List? ?? [];

          setState(() {
            _userList = List<Map<String, dynamic>>.from(rawData);
            _totalPages = (total / _limit).ceil();
            if (_totalPages < 1) _totalPages = 1;
          });
        } else {
          setState(() {
            _userList = [];
            _totalPages = 1;
          });
        }
      }
    } catch (e) {
      debugPrint("❌ [SelectUserModal] Lỗi fetch data: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onPageChange(int page) {
    if (page != _currentPage) {
      setState(() => _currentPage = page);
      _fetchUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentTheme = AdminTheme.theme.contentTheme;

    return MyModal(
      title: "CHỌN NHÂN VIÊN",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Search Bar
          MyInput(
            controller: _searchController,
            hintText: "Tìm theo mã, tên nhân viên...",
            borderRadius: 4,
            prefixIcon: RemixIcons.search_line,
            textInputAction: TextInputAction.search,
            suffixIcon: _searchController.text.isNotEmpty
                ? RemixIcons.close_circle_fill
                : null,
            onSuffixTap: () {
              _searchController.clear();
              setState(() => _currentPage = 1);
              _fetchUsers();
            },
            onFieldSubmitted: (_) {
              setState(() => _currentPage = 1);
              _fetchUsers();
            },
          ),

          MySpacing.height(12),

          // 2. Danh sách User Items
          SizedBox(
            height: 320,
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: contentTheme.primary,
                    ),
                  )
                : _userList.isEmpty
                ? Center(
                    child: Text(
                      "Không có dữ liệu",
                      style: TextStyle(color: contentTheme.cardTextMuted),
                    ),
                  )
                : ListView.separated(
                    itemCount: _userList.length,
                    separatorBuilder: (context, index) => MySpacing.height(8),
                    itemBuilder: (context, index) {
                      final user = _userList[index];
                      final fullname = (user['fullname'] ?? '')
                          .toString()
                          .trim();
                      final username = user['username'] ?? '';
                      final displayName = fullname.isNotEmpty
                          ? fullname
                          : username;

                      return MyContainer.bordered(
                        onTap: () {
                          if (widget.onSelect != null) {
                            widget.onSelect!(user);
                          }
                          Get.back(result: user);
                        },
                        borderRadiusAll: 4,
                        padding: MySpacing.xy(16, 12),
                        color: contentTheme.cardBackground,
                        borderColor: contentTheme.border,
                        child: Row(
                          children: [
                            MyText.bodySmall(
                              "USER:",
                              fontWeight: 700,
                              color: contentTheme.cardTextMuted,
                              fontSize: 12,
                            ),
                            MySpacing.width(20),
                            Expanded(
                              child: MyText.bodyMedium(
                                displayName,
                                fontWeight: 700,
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

      // 4. Custom Footer Nút Cancel
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qr_app/helper/theme/admin_theme.dart';
import 'package:qr_app/helper/theme/app_notifier.dart';
import 'package:qr_app/helper/utils/utils.dart';
import 'package:qr_app/helper/widgets/my_text.dart';
import 'package:qr_app/models/discrete_model.dart';
import 'package:qr_app/services/produce_service.dart';
import 'package:qr_app/views/layout/app_scaffold.dart';
import 'package:qr_app/views/layout/top_bar.dart';
import 'package:qr_app/views/screen/produce/detail.dart';
import 'package:qr_app/views/screen/produce/modal/user_select_modal.dart';
import 'package:qr_app/widgets/modal/my_alert_modal.dart';
import 'package:qr_app/widgets/modal/my_combodate.dart';
import 'package:qr_app/widgets/my_banner_notification.dart';
import 'package:qr_app/widgets/my_input.dart';
import 'package:qr_app/widgets/my_pagination.dart';
import 'package:qr_app/widgets/my_table.dart';
import 'package:remixicon/remixicon.dart';

class ProduceListScreen extends StatefulWidget {
  const ProduceListScreen({super.key});

  @override
  State<ProduceListScreen> createState() => _ProduceListScreenState();
}

class _ProduceListScreenState extends State<ProduceListScreen> {
  bool isLoading = false;
  int currentPage = 1;
  int totalPages = 1;
  List<ProduceModel> produceList = [];
  Map<String, dynamic>? _selectedUser;

  // Controllers cho UI Filter
  final TextEditingController _refNbrController = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;

  final Map<String, dynamic> searchParams = {
    'page': 1,
    'limit': 20,
    'ref_nbr': '',
    'RefNbr': '',
    'user_id': '',
    'from_date': '',
    'to_date': '',
  };

  final List<TableColumn> columns = [
    TableColumn(name: "STT", label: "STT", width: 50),
    TableColumn(name: "ref_nbr", label: "Số phiếu", width: 140),
    TableColumn(name: "date", label: "Ngày", width: 110),
    TableColumn(name: "object_name_lookup", label: "Thiết bị", width: 130),
    TableColumn(name: "discrete_nbr", label: "Lệnh SX", width: 120),
    TableColumn(name: "doc_descr", label: "Ghi chú", width: 200),
    TableColumn(name: "Actions_Right", label: "Xóa", width: 60),
  ];

  @override
  void initState() {
    super.initState();
    fetchListProduce();
  }

  @override
  void dispose() {
    _refNbrController.dispose();
    super.dispose();
  }

  /// Tải danh sách phiếu từ API
  Future<void> fetchListProduce() async {
    setState(() => isLoading = true);

    try {
      final params = {...searchParams, 'page': currentPage};
      final response = await ProduceService.getListProduce(params);

      if (mounted) {
        if (response != null && response['data'] != null) {
          setState(() {
            produceList = (response['data'] as List)
                .map((e) => ProduceModel.fromJson(e as Map<String, dynamic>))
                .toList();
            totalPages = response['pagination']?['totalPages'] ?? 1;
          });
        } else {
          setState(() {
            produceList = [];
            totalPages = 1;
          });
        }
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Lỗi tại fetchListProduce: $e");
      debugPrint("Stacktrace: $stackTrace");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  /// Reset toàn bộ bộ lọc về mặc định
  void _handleResetFilter() {
    // Ẩn bàn phím an toàn
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _refNbrController.clear();
      _selectedUser = null;
      _fromDate = null;
      _toDate = null;

      currentPage = 1;
      searchParams['ref_nbr'] = '';
      searchParams['RefNbr'] = '';
      searchParams['user_id'] = '';
      searchParams['from_date'] = '';
      searchParams['to_date'] = '';
    });

    fetchListProduce();
  }

  /// Thực thi tìm kiếm theo bộ lọc
  void _handleSearch() {
    // Dùng FocusManager thay vì FocusScope.of(context) để tránh lỗi FocusScopeNode disposed
    FocusManager.instance.primaryFocus?.unfocus();

    final keyword = _refNbrController.text.trim();

    setState(() {
      currentPage = 1;
      searchParams['ref_nbr'] = keyword;
      searchParams['RefNbr'] = keyword;
      searchParams['user_id'] = _selectedUser?['pkid'] ?? '';
      searchParams['from_date'] = _fromDate != null
          ? "${_fromDate!.year}-${_fromDate!.month.toString().padLeft(2, '0')}-${_fromDate!.day.toString().padLeft(2, '0')}"
          : '';
      searchParams['to_date'] = _toDate != null
          ? "${_toDate!.year}-${_toDate!.month.toString().padLeft(2, '0')}-${_toDate!.day.toString().padLeft(2, '0')}"
          : '';
    });
    fetchListProduce();
  }

  /// Xử lý xóa item theo header_id
  void handleDeleteItem(ProduceModel item) {
    final headerId = item.header_id;
    final refNbr = item.ref_nbr ?? '';

    if (headerId == null) {
      MyBannerNotification.show(
        context,
        title: "Lỗi",
        message: 'Không tìm thấy ID của bản ghi',
        type: BannerType.error,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return MyAlertModal(
          title: "Xác nhận xóa",
          message: "Bạn có chắc chắn muốn xóa phiếu $refNbr không?",
          cancelText: "Hủy",
          confirmText: "Đồng ý",
          confirmButtonColor: AdminTheme.theme.contentTheme.danger,
          onConfirm: () async {
            Get.back();
            setState(() => isLoading = true);

            final success = await ProduceService.deleteProduce(headerId);

            if (mounted) {
              if (success) {
                MyBannerNotification.show(
                  context,
                  title: "Thành công",
                  message: 'Đã xóa phiếu $refNbr thành công',
                  type: BannerType.success,
                );
                fetchListProduce();
              } else {
                MyBannerNotification.show(
                  context,
                  title: "Lỗi",
                  message: 'Xóa thất bại, vui lòng thử lại',
                  type: BannerType.error,
                );
                setState(() => isLoading = false);
              }
            }
          },
        );
      },
    );
  }

  void handlePageChange(int newPage) {
    if (newPage != currentPage) {
      setState(() {
        currentPage = newPage;
      });
      fetchListProduce();
    }
  }

  void handleEditItem(ProduceModel item, int index) {
    Get.to(
      () => ProduceDetailScreen(
        headerId: item.header_id,
        mode: ProduceDetailMode.edit,
      ),
    )?.then((_) => fetchListProduce());
  }

  void handleCreateNew() {
    Get.to(
      () => const ProduceDetailScreen(mode: ProduceDetailMode.create),
    )?.then((_) => fetchListProduce());
  }

  Widget renderCustomCell(String columnName, ProduceModel item, int index) {
    if (columnName == "STT") {
      final stt =
          (currentPage - 1) * (searchParams['limit'] as int) + index + 1;
      return MyText.bodySmall(
        '$stt',
        fontWeight: 600,
        fontSize: 15,
        textAlign: TextAlign.center,
      );
    }

    if (columnName == "date") {
      final formattedDate = Utils.formatDate(
        item.date,
        pattern: 'dd/MM/yyyy',
        fallback: '-',
      );

      return MyText.bodySmall(
        formattedDate,
        fontWeight: 500,
        fontSize: 15,
        textAlign: TextAlign.center,
      );
    }

    if (columnName == "ref_nbr") {
      return MyText.bodySmall(
        item.ref_nbr ?? '',
        fontWeight: 700,
        fontSize: 15,
        textAlign: TextAlign.center,
      );
    }

    if (columnName == "object_name_lookup") {
      return MyText.bodySmall(
        item.object_name_lookup ?? '',
        fontSize: 15,
        textAlign: TextAlign.center,
      );
    }

    if (columnName == "discrete_nbr") {
      return MyText.bodySmall(
        item.discrete_nbr ?? '',
        fontSize: 15,
        textAlign: TextAlign.center,
      );
    }

    if (columnName == "doc_descr") {
      return MyText.bodySmall(
        item.doc_descr ?? '',
        maxLines: 1,
        fontSize: 15,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      );
    }

    if (columnName == "Actions_Right") {
      return IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: Icon(
          RemixIcons.delete_bin_line,
          color: AdminTheme.theme.contentTheme.danger,
          size: 22,
        ),
        onPressed: () => handleDeleteItem(item),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildFilterSection(dynamic contentTheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: contentTheme.background,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: MyInput(
                  hintText: "Số phiếu",
                  borderRadius: 8,
                  controller: _refNbrController,
                  textInputAction: TextInputAction.search,
                  onFieldSubmitted: (_) => _handleSearch(),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _handleSearch,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: contentTheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    RemixIcons.search_line,
                    size: 18,
                    color: contentTheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              FocusManager.instance.primaryFocus?.unfocus();
              final user = await SelectUserModal.show(context);
              if (user != null) {
                setState(() {
                  _selectedUser = user;
                });
                _handleSearch();
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: contentTheme.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedUser != null
                        ? ((_selectedUser!['fullname'] ?? '')
                                  .toString()
                                  .isNotEmpty
                              ? _selectedUser!['fullname']
                              : _selectedUser!['username'] ??
                                    'Đã chọn người dùng')
                        : 'Chọn người dùng',
                    style: TextStyle(
                      color: _selectedUser != null
                          ? contentTheme.onBackground
                          : contentTheme.onBackground.withOpacity(0.4),
                      fontSize: 13,
                      fontWeight: _selectedUser != null
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      if (_selectedUser != null)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedUser = null;
                            });
                            _handleSearch();
                          },
                          child: Icon(
                            RemixIcons.close_circle_fill,
                            size: 18,
                            color: contentTheme.onBackground.withOpacity(0.4),
                          ),
                        ),
                      if (_selectedUser != null) const SizedBox(width: 6),
                      Icon(
                        RemixIcons.user_3_fill,
                        size: 16,
                        color: contentTheme.onBackground.withOpacity(0.6),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: MyCombodate(
                  value: _fromDate,
                  hintText: "Từ ngày",
                  onChanged: (date) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() => _fromDate = date);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MyCombodate(
                  value: _toDate,
                  hintText: "Đến ngày",
                  onChanged: (date) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() => _toDate = date);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
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
                  title: "Phiếu cân sản xuất",
                  showBackButton: false,
                  actions: [
                    IconButton(
                      icon: Icon(
                        RemixIcons.refresh_line,
                        color: contentTheme.onBackground,
                        size: 26,
                      ),
                      tooltip: "Tải lại & Làm mới filter",
                      onPressed:
                          _handleResetFilter, // 💡 Đã đổi sang hàm clear toàn bộ filter & reset user
                    ),
                    IconButton(
                      icon: Icon(
                        RemixIcons.add_line,
                        color: contentTheme.onBackground,
                        size: 28,
                      ),
                      tooltip: "Tạo mới phiếu",
                      onPressed: handleCreateNew,
                    ),
                  ],
                ),

                _buildFilterSection(contentTheme),

                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : MyTable<ProduceModel>(
                          data: produceList,
                          columns: columns,
                          onRowPress: (item, index) =>
                              handleEditItem(item, index),
                          renderCell: renderCustomCell,
                          borderRadius: 0,
                          emptyText: "Không tìm thấy dữ liệu",
                        ),
                ),

                if (!isLoading && totalPages > 1)
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: MyPagination(
                        currentPage: currentPage,
                        totalPage: totalPages,
                        onPageChange: handlePageChange,
                      ),
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qr_app/helper/theme/admin_theme.dart';
import 'package:qr_app/helper/theme/app_notifier.dart';
import 'package:qr_app/helper/utils/utils.dart';
import 'package:qr_app/helper/widgets/my_text.dart';
import 'package:qr_app/views/layout/app_scaffold.dart';
import 'package:qr_app/views/layout/top_bar.dart';
import 'package:qr_app/views/screen/produce/modal/user_select_modal.dart';
import 'package:qr_app/views/screen/stocktake/detail.dart';
import 'package:qr_app/widgets/modal/my_alert_modal.dart';
import 'package:qr_app/widgets/modal/my_combodate.dart';
import 'package:qr_app/widgets/my_banner_notification.dart';
import 'package:qr_app/widgets/my_input.dart';
import 'package:qr_app/widgets/my_pagination.dart';
import 'package:qr_app/widgets/my_table.dart';
import 'package:remixicon/remixicon.dart';

class StockTakeListScreen extends StatefulWidget {
  const StockTakeListScreen({super.key});

  @override
  State<StockTakeListScreen> createState() => _StockTakeListScreenState();
}

class _StockTakeListScreenState extends State<StockTakeListScreen> {
  bool isLoading = false;
  int currentPage = 1;
  int totalPages = 1;
  Map<String, dynamic>? _selectedUser;

  // Controllers cho UI Filter
  final TextEditingController _soKiemKeController = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;

  final Map<String, dynamic> searchParams = {
    'page': 1,
    'limit': 20,
    'so_kiem_ke': '',
    'user_id': '',
    'from_date': '',
    'to_date': '',
  };

  // Mock data dữ liệu giả
  List<Map<String, dynamic>> rawMockList = [
    {
      "id": 1,
      "soKiemKe": "KK202608001",
      "tinhTrang": "draft",
      "ngayKK": DateTime(2026, 8, 20),
      "maKho": "KHO-HN",
      "tenKho": "Kho Hà Nội",
      "maLocator": "LOC-A1",
      "lines": [],
    },
    {
      "id": 2,
      "soKiemKe": "KK202608002",
      "tinhTrang": "complete",
      "ngayKK": DateTime(2026, 8, 21),
      "maKho": "KHO-HCM",
      "tenKho": "Kho Hồ Chí Minh",
      "maLocator": "LOC-B2",
      "lines": [],
    },
    {
      "id": 3,
      "soKiemKe": "KK202608003",
      "tinhTrang": "draft",
      "ngayKK": DateTime(2026, 8, 22),
      "maKho": "KHO-DN",
      "tenKho": "Kho Đà Nẵng",
      "maLocator": "LOC-C3",
      "lines": [],
    },
    {
      "id": 4,
      "soKiemKe": "KK202608004",
      "tinhTrang": "complete",
      "ngayKK": DateTime(2026, 8, 23),
      "maKho": "KHO-BD",
      "tenKho": "Kho Bình Dương",
      "maLocator": "LOC-D4",
      "lines": [],
    },
  ];

  List<Map<String, dynamic>> stockTakeList = [];

  final List<TableColumn> columns = [
    TableColumn(name: "STT", label: "STT", width: 50),
    TableColumn(name: "SoKiemKe", label: "Số phiếu", width: 130),
    TableColumn(name: "NgayKiemKe", label: "Ngày kiểm kê", width: 120),
    TableColumn(name: "maKho", label: "Mã Kho", width: 100),
    TableColumn(name: "tenKho", label: "Tên Kho", width: 140),
    TableColumn(name: "Actions_Right", label: "Xóa", width: 60),
  ];

  @override
  void initState() {
    super.initState();
    fetchListStockTake();
  }

  @override
  void dispose() {
    _soKiemKeController.dispose();
    super.dispose();
  }

  /// Tải danh sách kiểm kê kho (Xử lý filter trên dữ liệu mock)
  Future<void> fetchListStockTake() async {
    setState(() => isLoading = true);

    try {
      // Giả lập delay API
      await Future.delayed(const Duration(milliseconds: 300));

      final keyword = (searchParams['so_kiem_ke'] as String).toLowerCase();

      List<Map<String, dynamic>> filteredList = rawMockList.where((item) {
        final matchSoPhieu =
            keyword.isEmpty ||
            (item['soKiemKe'] ?? '').toString().toLowerCase().contains(keyword);

        DateTime? ngayKK = item['ngayKK'] as DateTime?;
        bool matchFromDate = true;
        bool matchToDate = true;

        if (ngayKK != null) {
          if (_fromDate != null) {
            matchFromDate = ngayKK.isAfter(
              _fromDate!.add(const Duration(days: -1)),
            );
          }
          if (_toDate != null) {
            matchToDate = ngayKK.isBefore(
              _toDate!.add(const Duration(days: 1)),
            );
          }
        }

        return matchSoPhieu && matchFromDate && matchToDate;
      }).toList();

      if (mounted) {
        setState(() {
          stockTakeList = filteredList;
          totalPages = 1;
        });
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Lỗi tại fetchListStockTake: $e");
      debugPrint("Stacktrace: $stackTrace");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  /// Reset toàn bộ bộ lọc về mặc định
  void _handleResetFilter() {
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _soKiemKeController.clear();
      _selectedUser = null;
      _fromDate = null;
      _toDate = null;

      currentPage = 1;
      searchParams['so_kiem_ke'] = '';
      searchParams['user_id'] = '';
      searchParams['from_date'] = '';
      searchParams['to_date'] = '';
    });

    fetchListStockTake();
  }

  /// Thực thi tìm kiếm theo bộ lọc
  void _handleSearch() {
    FocusManager.instance.primaryFocus?.unfocus();

    final keyword = _soKiemKeController.text.trim();

    setState(() {
      currentPage = 1;
      searchParams['so_kiem_ke'] = keyword;
      searchParams['user_id'] = _selectedUser?['pkid'] ?? '';
      searchParams['from_date'] = _fromDate != null
          ? "${_fromDate!.year}-${_fromDate!.month.toString().padLeft(2, '0')}-${_fromDate!.day.toString().padLeft(2, '0')}"
          : '';
      searchParams['to_date'] = _toDate != null
          ? "${_toDate!.year}-${_toDate!.month.toString().padLeft(2, '0')}-${_toDate!.day.toString().padLeft(2, '0')}"
          : '';
    });
    fetchListStockTake();
  }

  /// Xử lý xóa item kiểm kê
  void handleDeleteItem(Map<String, dynamic> item) {
    final id = item['id'];
    final soKiemKe = item['soKiemKe'] ?? '';

    if (id == null) {
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
          message: "Bạn có chắc chắn muốn xóa phiếu kiểm kê $soKiemKe không?",
          cancelText: "Hủy",
          confirmText: "Đồng ý",
          confirmButtonColor: AdminTheme.theme.contentTheme.danger,
          onConfirm: () async {
            Get.back();
            setState(() {
              rawMockList.removeWhere((element) => element['id'] == id);
            });

            MyBannerNotification.show(
              context,
              title: "Thành công",
              message: 'Đã xóa phiếu $soKiemKe thành công',
              type: BannerType.success,
            );

            fetchListStockTake();
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
      fetchListStockTake();
    }
  }

  void handleEditItem(Map<String, dynamic> item, int index) {
    debugPrint("Chuyển sang màn hình Edit kiểm kê: ${item['soKiemKe']}");
    Get.to(
      () => StockTakeDetailScreen(
        headerId: item['id'],
        mode: StockTakeDetailMode.edit,
      ),
    )?.then((_) => fetchListStockTake());
  }

  void handleCreateNew() {
    debugPrint("Chuyển sang màn hình Tạo mới kiểm kê");
    Get.to(
      () => const StockTakeDetailScreen(mode: StockTakeDetailMode.create),
    )?.then((_) => fetchListStockTake());
  }

  Widget renderCustomCell(
    String columnName,
    Map<String, dynamic> item,
    int index,
  ) {
    if (columnName == "STT") {
      final stt =
          (currentPage - 1) * (searchParams['limit'] as int) + index + 1;
      return MyText.bodySmall(
        '$stt',
        fontWeight: 600,
        fontSize: 14,
        textAlign: TextAlign.center,
      );
    }

    if (columnName == "SoKiemKe") {
      return MyText.bodySmall(
        item['soKiemKe'] ?? '',
        fontWeight: 700,
        fontSize: 14,
        textAlign: TextAlign.center,
      );
    }

    if (columnName == "NgayKiemKe") {
      final date = item['ngayKK'];
      final formattedDate = Utils.formatDate(
        date,
        pattern: 'dd/MM/yyyy',
        fallback: '-',
      );

      return MyText.bodySmall(
        formattedDate,
        fontWeight: 500,
        fontSize: 14,
        textAlign: TextAlign.center,
      );
    }

    if (columnName == "maKho") {
      return MyText.bodySmall(
        item['maKho'] ?? '',
        fontSize: 14,
        textAlign: TextAlign.center,
      );
    }

    if (columnName == "tenKho") {
      return MyText.bodySmall(
        item['tenKho'] ?? '',
        fontSize: 14,
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
          size: 20,
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
                  hintText: "Số phiếu kiểm kê",
                  borderRadius: 8,
                  controller: _soKiemKeController,
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
                  title: "Phiếu kiểm kê kho",
                  showBackButton: false,
                  actions: [
                    IconButton(
                      icon: Icon(
                        RemixIcons.refresh_line,
                        color: contentTheme.onBackground,
                        size: 26,
                      ),
                      tooltip: "Tải lại & Làm mới filter",
                      onPressed: _handleResetFilter,
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

                // _buildFilterSection(contentTheme),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : MyTable<Map<String, dynamic>>(
                          data: stockTakeList,
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

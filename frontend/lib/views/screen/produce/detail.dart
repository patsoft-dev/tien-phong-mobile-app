import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:provider/provider.dart';
import 'package:qr_app/helper/theme/admin_theme.dart';
import 'package:qr_app/helper/theme/app_notifier.dart';
import 'package:qr_app/helper/widgets/my_container.dart';
import 'package:qr_app/helper/widgets/my_spacing.dart';
import 'package:qr_app/helper/widgets/my_text.dart';
import 'package:qr_app/models/discrete_model.dart';
import 'package:qr_app/services/produce_service.dart';
import 'package:qr_app/views/layout/app_scaffold.dart';
import 'package:qr_app/views/layout/top_bar.dart';
import 'package:qr_app/views/screen/produce/modal/line_modal_produce.dart';
import 'package:qr_app/views/screen/produce/modal/lsx_select_modal.dart';
import 'package:qr_app/views/screen/produce/modal/printer_select_modal.dart';
import 'package:qr_app/views/screen/produce/modal/weigh_station_select_modal.dart';
import 'package:qr_app/views/screen/qr_scanner_screen.dart';
import 'package:qr_app/widgets/modal/my_alert_modal.dart';
import 'package:qr_app/widgets/my_banner_notification.dart';
import 'package:qr_app/widgets/my_input.dart';
import 'package:qr_app/widgets/my_pre_widget.dart';
import 'package:qr_app/widgets/my_table.dart';
import 'package:qr_app/widgets/select_input_box.dart';
import 'package:remixicon/remixicon.dart';

// Khai báo Enum quản lý Mode cho màn hình Detail
enum ProduceDetailMode { create, edit }

class ProduceDetailScreen extends StatefulWidget {
  final dynamic headerId; // Nhận header_id từ List sang
  final ProduceDetailMode mode; // Nhận mode từ bên ngoài truyền vào

  const ProduceDetailScreen({
    super.key,
    this.headerId,
    this.mode = ProduceDetailMode.create, // Mặc định là Create
  });

  @override
  State<ProduceDetailScreen> createState() => _ProduceDetailScreenState();
}

class _ProduceDetailScreenState extends State<ProduceDetailScreen> {
  final TextEditingController _lsxController = TextEditingController();
  final TextEditingController _tramCanController = TextEditingController();
  final TextEditingController _ghiChuController = TextEditingController();

  late final ValueNotifier<ProduceModel?> _produceNotifier = ValueNotifier(
    _currentProduceData,
  );

  bool _isExpandedDetail = true;
  bool _isLoading = false;
  ProduceModel? _currentProduceData;

  DiscreteModel? _selectedLSX;
  WeighStationModel? _selectedWeighStation;
  List<ProduceLineModel> _productList = [];
  List<WeighStationModel> _weighStationList = [];
  bool get isEditMode =>
      widget.mode ==
      ProduceDetailMode.edit; // Getter kiểm tra nhanh trạng thái Edit

  final List<TableColumn> _productColumns = [
    TableColumn(name: "STT", label: "STT", width: 45),
    TableColumn(name: "lot_nbr", label: "Số Lô", width: 130),
    TableColumn(name: "base_qty", label: "SL Gốc", width: 85),
    TableColumn(name: "base_unit", label: "ĐVT", width: 60),
    TableColumn(name: "physical_qty", label: "SLKK", width: 70),
    TableColumn(name: "gross_weight", label: "T Gross", width: 75),
    TableColumn(name: "add_weight", label: "T Add", width: 75),
    TableColumn(name: "line_descr", label: "Descr", width: 150),
    TableColumn(name: "action", label: "Xóa", width: 50),
  ];

  Widget _renderCustomCell(
    String columnName,
    ProduceLineModel item,
    int index,
  ) {
    if (columnName == "action") {
      return InkWell(
        onTap: () => _handleDeleteProduct(index),
        child: const Padding(
          padding: EdgeInsets.all(4.0),
          child: Icon(Icons.delete_outline, color: Colors.red, size: 20),
        ),
      );
    }
    // Cột STT
    if (columnName == "STT") {
      return MyText.bodySmall(
        '${index + 1}',
        fontWeight: 600,
        fontSize: 13,
        textAlign: TextAlign.center,
      );
    }

    // Cột dạng số (căn giữa)
    if (columnName == "base_qty" ||
        columnName == "physical_qty" ||
        columnName == "gross_weight" ||
        columnName == "add_weight") {
      final numValue = item.toJson()[columnName] ?? 0;
      return MyText.bodySmall(
        '$numValue',
        fontSize: 13,
        textAlign: TextAlign.center,
      );
    }

    // Cột ghi chú (line_descr) và các chuỗi văn bản
    final rawValue = item.toJson()[columnName];

    // Riêng cột line_descr căn trái cho dễ đọc khi xuống dòng
    final isDescr = columnName == "line_descr";

    return MyText.bodySmall(
      rawValue?.toString() ?? '',
      fontSize: 13,
      textAlign: isDescr ? TextAlign.start : TextAlign.center,
      maxLines: 2, // Cho phép tối đa 2 dòng
      overflow: TextOverflow.ellipsis, // Quá 2 dòng sẽ hiển thị dấu ...
    );
  }

  void _handleDeleteProduct(int index) {
    final item = _productList[index];
    // Lấy tên/số lô hoặc mã để hiển thị trong thông báo (nếu có)
    final lotNbr = item.lot_nbr ?? '';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return MyAlertModal(
          title: "Xác nhận xóa",
          message: lotNbr.isNotEmpty
              ? "Bạn có chắc chắn muốn xóa dòng lô $lotNbr không?"
              : "Bạn có chắc chắn muốn xóa dòng sản phẩm này không?",
          cancelText: "Hủy",
          confirmText: "Đồng ý",
          confirmButtonColor: AdminTheme.theme.contentTheme.danger,
          onConfirm: () {
            Get.back(); // Đóng modal

            // Cập nhật lại UI client
            setState(() {
              _productList.removeAt(index);
            });

            // Hiển thị thông báo thành công
            if (mounted) {
              MyBannerNotification.show(
                context,
                title: "Thành công",
                message: "Đã xóa dòng sản phẩm",
                type: BannerType.success,
                duration: const Duration(seconds: 1),
              );
            }
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _ghiChuController.addListener(() {
      if (_currentProduceData != null) {
        _currentProduceData = _currentProduceData!.copyWith(
          doc_descr: _ghiChuController.text,
        );
      }
    });
    _initData();
  }

  void _initData() {
    // Nếu ở chế độ Edit và có truyền headerId thì ưu tiên gọi API getOneProduce
    if (isEditMode && widget.headerId != null) {
      _fetchOneProduce(widget.headerId);
    }
  }

  /// Gán dữ liệu ProduceModel vào UI/Controllers
  void _applyProduceData(ProduceModel item) {
    setState(() {
      _currentProduceData = item;
      _lsxController.text = item.discrete_nbr ?? '';
      _tramCanController.text = item.object_name_lookup ?? '';
      _ghiChuController.text = item.doc_descr ?? '';
      _productList = item.lines;
    });
    _produceNotifier.value = item;
  }

  Future<void> _fetchOneProduce(dynamic headerId) async {
    setState(() => _isLoading = true);
    try {
      final res = await ProduceService.getOneProduce({'id': headerId});

      if (res != null) {
        Map<String, dynamic>? rawData;
        if (res['data'] is Map) {
          rawData = res['data'] as Map<String, dynamic>;
        } else if (res['data'] is List && (res['data'] as List).isNotEmpty) {
          rawData = res['data'][0] as Map<String, dynamic>;
        } else {
          rawData = res;
        }

        if (rawData != null) {
          final model = ProduceModel.fromJson(
            rawData,
          ); // Parse trực tiếp thành ProduceModel
          _applyProduceData(model);
        }
      }
    } catch (e, stack) {
      debugPrint("❌ Lỗi lấy chi tiết phiếu sản xuất: $e");
      debugPrint("Stacktrace: $stack");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchDiscreteData(String lsxId) async {
    if (lsxId.trim().isEmpty) {
      MyBannerNotification.show(
        context,
        title: "Thông báo",
        message: "Vui lòng nhập lệnh sản xuất!",
        type: BannerType.error,
        duration: const Duration(seconds: 1),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final lsxRes = await ProduceService.getDiscreteByLSX({'filter': lsxId});

      if (lsxRes != null) {
        Map<String, dynamic>? rawLsx;
        if (lsxRes['data'] is List) {
          final list = lsxRes['data'] as List;
          // Nếu danh sách rỗng -> Gọi hàm báo không tìm thấy
          if (list.isEmpty) {
            _handleNotFoundData();
            return;
          }
          rawLsx = list[0] as Map<String, dynamic>;
        }
        // ✅ Kiểm tra nếu data là Map
        else if (lsxRes['data'] is Map) {
          rawLsx = lsxRes['data'] as Map<String, dynamic>;
        }
        // ✅ Trường hợp response trả thẳng Object
        else {
          rawLsx = lsxRes;
        }

        // Nếu không lấy được rawLsx
        if (rawLsx == null) {
          _handleNotFoundData();
          return;
        }

        ProduceModel produceData = ProduceModel.fromJson(rawLsx);
        _lsxController.text = produceData.discrete_nbr ?? _lsxController.text;
        _tramCanController.text = produceData.object_name_lookup ?? '';
        _ghiChuController.text = produceData.doc_descr ?? '';

        if (produceData.inventory_id != null) {
          final invRes = await ProduceService.getInventoryByID({
            'inventoryid': produceData.inventory_id,
          });

          if (invRes != null) {
            Map<String, dynamic>? invItem;
            if (invRes['data'] is List && (invRes['data'] as List).isNotEmpty) {
              invItem = invRes['data'][0] as Map<String, dynamic>;
            } else if (invRes['data'] is Map) {
              invItem = invRes['data'] as Map<String, dynamic>;
            }

            if (invItem != null) {
              final inventory = InventoryModel.fromJson(invItem);
              produceData = produceData.copyWith(
                inventory_cd: inventory.inventoryCd,
                inventory_name: inventory.descr,
              );
            }
          }
        }

        // Cập nhật State
        setState(() {
          _currentProduceData = produceData;
          _productList = produceData.lines;
        });
        _produceNotifier.value = _currentProduceData;

        // Thông báo thành công
        if (mounted) {
          MyBannerNotification.show(
            context,
            title: "Thành công",
            message: "Tải dữ liệu lệnh sản xuất thành công!",
            type: BannerType.success,
            duration: const Duration(seconds: 1),
          );
        }
      } else {
        _handleNotFoundData();
      }
    } catch (e, stack) {
      debugPrint("❌ Lỗi tải dữ liệu: $e");
      debugPrint("Stacktrace: $stack");

      if (mounted) {
        MyBannerNotification.show(
          context,
          title: "Lỗi",
          message: "Đã xảy ra lỗi trong quá trình tải dữ liệu!",
          type: BannerType.error,
          duration: const Duration(seconds: 1),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<List<WeighStationModel>> _fetchWeighStations() async {
    try {
      final response = await ProduceService.getWeighStation({
        'page': 1,
        'limit': 100, // Lấy toàn bộ danh sách trạm cân
      });

      if (response != null &&
          (response['status'] == true || response['data'] != null)) {
        final rawData = response['data'] as List? ?? [];
        final list = rawData
            .map((e) => WeighStationModel.fromJson(e as Map<String, dynamic>))
            .toList();

        setState(() {
          _weighStationList = list;
        });
        return list;
      }
    } catch (e) {
      debugPrint("❌ Lỗi lấy dữ liệu trạm cân: $e");
      if (mounted) {
        MyBannerNotification.show(
          context,
          title: "Lỗi",
          message: "Không tải được danh sách trạm cân!",
          type: BannerType.error,
          duration: const Duration(seconds: 1),
        );
      }
    }
    return [];
  }

  /// Xử lý quét QRCode Trạm Cân
  Future<void> _handleScanWeighStation() async {
    await _handleScanQR(_tramCanController);
    final scannedCode = _tramCanController.text.trim();

    if (scannedCode.isEmpty) return;

    // Lấy dữ liệu nếu danh sách trống
    List<WeighStationModel> currentList = _weighStationList;
    if (currentList.isEmpty) {
      currentList = await _fetchWeighStations();
    }

    // Tìm kiếm theo ObjectCode
    final matchedStation = currentList.firstWhereOrNull(
      (item) => item.ObjectCode?.toLowerCase() == scannedCode.toLowerCase(),
    );

    if (matchedStation != null) {
      setState(() {
        _selectedWeighStation = matchedStation;
        _tramCanController.text =
            matchedStation.ObjectName ?? matchedStation.ObjectCode ?? '';
      });

      if (mounted) {
        MyBannerNotification.show(
          context,
          title: "Thành công",
          message: "Đã chọn trạm cân: ${_tramCanController.text}",
          type: BannerType.success,
          duration: const Duration(seconds: 1),
        );
      }
    } else {
      setState(() {
        _selectedWeighStation = null;
        _tramCanController.clear();
      });

      if (mounted) {
        MyBannerNotification.show(
          context,
          title: "Thông báo",
          message: "Không tìm thấy trạm cân với mã $scannedCode!",
          type: BannerType.error,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  /// Hàm hỗ trợ xử lý khi không tìm thấy LSX
  void _handleNotFoundData() {
    setState(() {
      _productList = [];
      _currentProduceData = null;
    });
    _produceNotifier.value = null;

    if (mounted) {
      MyBannerNotification.show(
        context,
        title: "Thông báo",
        message: "Không tìm thấy dữ liệu lệnh sản xuất!",
        type: BannerType.error,
        duration: const Duration(seconds: 1),
      );
    }
  }

  @override
  void dispose() {
    _produceNotifier.dispose();
    _lsxController.dispose();
    _tramCanController.dispose();
    _ghiChuController.dispose();
    super.dispose();
  }

  num _calculateTotalBaseQty() {
    return _productList.fold<num>(0, (sum, item) => sum + (item.base_qty ?? 0));
  }

  Future<void> _handleScanQR(TextEditingController controller) async {
    final String? scannedCode = await Get.to(() => const QrScannerScreen());

    if (scannedCode != null && scannedCode.isNotEmpty) {
      controller.text = scannedCode;
      if (controller == _lsxController) {
        _fetchDiscreteData(scannedCode);
      }
    }
  }

  Future<void> _handleSave() async {
    if (!isEditMode &&
        _selectedLSX == null &&
        _lsxController.text.trim().isEmpty) {
      MyBannerNotification.show(
        context,
        title: "Thông báo",
        message: "Vui lòng chọn hoặc quét mã LSX",
        type: BannerType.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final produceToSave = ProduceModel(
        header_id: _currentProduceData?.header_id ?? widget.headerId,
        ref_nbr: _currentProduceData?.ref_nbr,
        date: _currentProduceData?.date ?? DateTime.now().toIso8601String(),
        company_id: _currentProduceData?.company_id,
        branch_id: _currentProduceData?.branch_id,
        discrete_id:
            _selectedLSX?.discrete_id ?? _currentProduceData?.discrete_id,
        discrete_nbr: _lsxController.text.isNotEmpty
            ? _lsxController.text
            : _currentProduceData?.discrete_nbr,
        inventory_id: _currentProduceData?.inventory_id,
        inventory_cd: _currentProduceData?.inventory_cd,
        inventory_name: _currentProduceData?.inventory_name,
        object_code_lookup:
            _selectedWeighStation?.ObjectCode ??
            _currentProduceData?.object_code_lookup,
        object_name_lookup: _tramCanController.text.isNotEmpty
            ? _tramCanController.text
            : _currentProduceData?.object_name_lookup,
        doc_descr: _ghiChuController.text,
        created_by_id: _currentProduceData?.created_by_id,
        last_modified_by_id: _currentProduceData?.last_modified_by_id,
        is_upload: _currentProduceData?.is_upload,
        lines: _productList,
      );

      final payloadJson = produceToSave.toJson();
      // 🚀 Log dữ liệu produceToSave dạng Pretty JSON trước khi gọi API
      // debugPrint("--------------------------------------------------");
      // debugPrint("📤 [REQUEST PAYLOAD] produceToSave:");
      // debugPrint(const JsonEncoder.withIndent('  ').convert(payloadJson));
      // debugPrint("--------------------------------------------------");

      Map<String, dynamic>? res;

      if (isEditMode) {
        final headerId = widget.headerId ?? produceToSave.header_id;
        if (headerId == null) {
          MyBannerNotification.show(
            context,
            title: "Lỗi",
            message: "Không tìm thấy ID phiếu để cập nhật",
            type: BannerType.error,
          );
          return;
        }

        res = await ProduceService.updateProduce({'id': headerId}, payloadJson);
      } else {
        res = await ProduceService.createProduce(payloadJson);
      }

      if (mounted) {
        if (res != null && res['status'] == true) {
          // Cập nhật lại UI với data mới trả về từ Server (có đầy đủ header_id, ref_nbr mới)
          if (res['data'] != null && res['data'] is Map<String, dynamic>) {
            final updatedModel = ProduceModel.fromJson(
              res['data'] as Map<String, dynamic>,
            );
            _applyProduceData(updatedModel);
          }

          MyBannerNotification.show(
            context,
            title: "Thành công",
            message:
                res['message']?.toString() ??
                (isEditMode ? "Cập nhật thành công" : "Thêm mới thành công"),
            type: BannerType.success,
            duration: const Duration(seconds: 1),
          );

          // Trả về true khi back về màn danh sách để reload lại list
          Get.back(result: true);
        } else {
          MyBannerNotification.show(
            context,
            title: "Thất bại",
            message:
                res?['message']?.toString() ?? "Lưu thất bại, vui lòng thử lại",
            type: BannerType.error,
            duration: const Duration(seconds: 1),
          );
        }
      }
    } catch (e, stack) {
      debugPrint("❌ Lỗi khi lưu dữ liệu: $e");
      debugPrint("Stacktrace: $stack");
      if (mounted) {
        MyBannerNotification.show(
          context,
          title: "Lỗi hệ thống",
          message: "Đã xảy ra lỗi trong quá trình lưu dữ liệu",
          type: BannerType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleUpload() async {
    final headerId = _currentProduceData?.header_id;
    final isUploaded = _currentProduceData?.is_upload ?? false;

    // Điều kiện chặn: Không có header_id HOẶC phiếu đã upload rồi
    if (headerId == null || isUploaded) {
      MyBannerNotification.show(
        context,
        title: "Thông báo",
        message: isUploaded
            ? "Phiếu này đã được upload trước đó!"
            : "Không tìm thấy mã phiếu để upload!",
        type: BannerType.error,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await ProduceService.uploadProduce({
        'id': headerId,
        'is_upload': true,
      });

      if (mounted) {
        if (res != null && res['status'] == true) {
          // Cập nhật lại state dữ liệu hiện tại với status is_upload = true
          if (_currentProduceData != null) {
            final updatedModel = _currentProduceData!.copyWith(is_upload: true);
            _applyProduceData(updatedModel);
          }

          MyBannerNotification.show(
            context,
            title: "Thành công",
            message: "Upload phiếu thành công!",
            type: BannerType.success,
            duration: const Duration(seconds: 1),
          );

          Get.back(result: true);
        } else {
          final errorMsg =
              res?['message'] ?? "Upload thất bại, vui lòng thử lại!";
          MyBannerNotification.show(
            context,
            title: "Thất bại",
            message: errorMsg,
            type: BannerType.error,
            duration: const Duration(seconds: 2),
          );
        }
      }
    } catch (e, stack) {
      debugPrint("❌ Lỗi khi upload phiếu: $e");
      debugPrint("Stacktrace: $stack");
      if (mounted) {
        MyBannerNotification.show(
          context,
          title: "Lỗi hệ thống",
          message: "Đã xảy ra lỗi trong quá trình upload dữ liệu",
          type: BannerType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleOpenPrintModal() {
    SelectPrinterModal.show(context);
  }

  void _handleAddProduct() async {
    // Lấy mã trạm cân hiện tại
    final objectCode =
        _selectedWeighStation?.ObjectCode ??
        _currentProduceData?.object_code_lookup;

    final newLine = await LineModalProduce.show(
      context,
      objectCode: objectCode, // Truyền mã cân vào modal
    );

    if (newLine != null) {
      setState(() {
        _productList.add(newLine);
      });
    }
  }

  void _handleEditProduct(ProduceLineModel item, int index) async {
    final objectCode =
        _selectedWeighStation?.ObjectCode ??
        _currentProduceData?.object_code_lookup;

    final updatedLine = await LineModalProduce.show(
      context,
      line: item, // Truyền item hiện tại để Edit
      objectCode: objectCode,
    );

    if (updatedLine != null) {
      setState(() {
        _productList[index] = updatedLine;
      });
    }
  }

  Widget _buildInfoRow(
    String label,
    String value,
    dynamic contentTheme, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MyText.bodySmall(
            label,
            fontWeight: 500,
            color: contentTheme.onBackground,
            fontSize: 13,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AutoSizeText(
              value,
              textAlign: TextAlign.end,
              maxLines: 2,
              minFontSize: 9,
              maxFontSize: 13,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: contentTheme.onBackground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleText = isEditMode
        ? "Chi tiết phiếu Sản xuất"
        : "Tạo mới phiếu Sản xuất";

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
                        RemixIcons.printer_line,
                        color: contentTheme.onBackground,
                        size: 22,
                      ),
                      tooltip: "In phiếu",
                      onPressed: _handleOpenPrintModal,
                    ),
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
                      // MyPreWidget(
                      //   data: _currentProduceData?.toJson(),
                      //   onRefresh: () {
                      //     setState(() {});
                      //   },
                      // ),
                      MyContainer(
                        paddingAll: 16,
                        borderRadiusAll: 12,
                        color: contentTheme.cardBackground,
                        bordered: true,
                        borderColor: contentTheme.border,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: MyText.bodySmall(
                                    isEditMode ? "Số phiếu:" : "LSX",
                                    fontWeight: 600,
                                    fontSize: 14,
                                    color: contentTheme.onBackground,
                                  ),
                                ),
                                Expanded(
                                  child: isEditMode
                                      ? Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: isEditMode ? 8 : 12,
                                            horizontal: 4,
                                          ),
                                          alignment: Alignment.centerLeft,
                                          child: MyText.bodyMedium(
                                            _currentProduceData?.ref_nbr ??
                                                "---",
                                            fontWeight: 700,
                                            color: contentTheme.onBackground,
                                          ),
                                        )
                                      : SelectInputBox(
                                          hintText: "Chọn LSX hoặc quét QRCode",
                                          contentTheme: contentTheme,
                                          // Ưu tiên hiển thị từ _selectedLSX, nếu không có thì lấy giá trị từ _lsxController
                                          value:
                                              _selectedLSX?.discrete_nbr ??
                                              (_lsxController.text.isNotEmpty
                                                  ? _lsxController.text
                                                  : null),
                                          onTap: () async {
                                            final lsx =
                                                await SelectLsxModal.show(
                                                  context,
                                                );
                                            if (lsx != null) {
                                              setState(() {
                                                _selectedLSX = lsx;
                                                final discreteNbr =
                                                    lsx.discrete_nbr ?? '';
                                                _lsxController.text =
                                                    discreteNbr;
                                                if (discreteNbr.isNotEmpty) {
                                                  _fetchDiscreteData(
                                                    discreteNbr,
                                                  );
                                                }
                                              });
                                            }
                                          },
                                          onClear: () {
                                            setState(() {
                                              _selectedLSX = null;
                                              _productList.clear();
                                              _currentProduceData = null;
                                              _lsxController.clear();
                                            });
                                          },
                                          onScanQr: () async {
                                            await _handleScanQR(_lsxController);
                                            final scannedCode = _lsxController
                                                .text
                                                .trim();
                                            if (scannedCode.isNotEmpty) {
                                              setState(() {
                                                _selectedLSX =
                                                    null; // Reset object chọn tay
                                              });
                                              _fetchDiscreteData(scannedCode);
                                            }
                                          },
                                        ),
                                ),
                              ],
                            ),
                            MySpacing.height(12),
                            Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: MyText.bodySmall(
                                    "Trạm cân:",
                                    fontWeight: 600,
                                    fontSize: 14,
                                    color: contentTheme.onBackground,
                                  ),
                                ),
                                Expanded(
                                  child: isEditMode
                                      ? Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: isEditMode ? 8 : 12,
                                            horizontal: 4,
                                          ),
                                          alignment: Alignment.centerLeft,
                                          child: MyText.bodyMedium(
                                            _tramCanController.text.isNotEmpty
                                                ? _tramCanController.text
                                                : (_currentProduceData
                                                          ?.object_code_lookup ??
                                                      "---"),
                                            fontWeight: 700,
                                            color: contentTheme.onBackground,
                                          ),
                                        )
                                      : SelectInputBox(
                                          hintText:
                                              "Chọn trạm cân hoặc quét QR",
                                          contentTheme: contentTheme,
                                          value: _selectedWeighStation != null
                                              ? (_selectedWeighStation!
                                                            .ObjectName
                                                            ?.isNotEmpty ==
                                                        true
                                                    ? _selectedWeighStation!
                                                          .ObjectName
                                                    : _selectedWeighStation!
                                                          .ObjectCode)
                                              : (_tramCanController
                                                        .text
                                                        .isNotEmpty
                                                    ? _tramCanController.text
                                                    : null),
                                          onTap: () async {
                                            // Tải danh sách nếu rỗng trước khi mở modal
                                            if (_weighStationList.isEmpty) {
                                              await _fetchWeighStations();
                                            }

                                            if (!context.mounted) return;

                                            final wStation =
                                                await SelectWeighStationModal.show(
                                                  context,
                                                  weighStationList:
                                                      _weighStationList,
                                                );

                                            if (wStation != null) {
                                              setState(() {
                                                _selectedWeighStation =
                                                    wStation;
                                                _tramCanController.text =
                                                    wStation.ObjectName ??
                                                    wStation.ObjectCode ??
                                                    '';
                                              });
                                            }
                                          },
                                          onClear: () {
                                            setState(() {
                                              _selectedWeighStation = null;
                                              _tramCanController.clear();
                                            });
                                          },
                                          onScanQr: _handleScanWeighStation,
                                        ),
                                ),
                              ],
                            ),
                            MySpacing.height(12),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _isExpandedDetail = !_isExpandedDetail;
                                });
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  MyText.bodySmall(
                                    "Thông tin chi tiết & Ghi chú:",
                                    fontWeight: 700,
                                    fontSize: 14,
                                    color: contentTheme.onBackground,
                                  ),
                                  Icon(
                                    _isExpandedDetail
                                        ? RemixIcons.arrow_up_s_line
                                        : RemixIcons.arrow_down_s_line,
                                    size: 20,
                                    color: contentTheme.onBackground,
                                  ),
                                ],
                              ),
                            ),
                            if (_isExpandedDetail) ...[
                              Divider(
                                height: 16,
                                thickness: 1,
                                color: contentTheme.border,
                              ),
                              _buildInfoRow(
                                "Mã TP:",
                                _currentProduceData?.inventory_cd ?? "---",
                                contentTheme,
                                isBold: true,
                              ),
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: contentTheme.border,
                              ),
                              _buildInfoRow(
                                "ID TP:",
                                _currentProduceData?.inventory_id?.toString() ??
                                    "---",
                                contentTheme,
                              ),
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: contentTheme.border,
                              ),
                              _buildInfoRow(
                                "Tên TP:",
                                _currentProduceData?.inventory_name ?? "---",
                                contentTheme,
                              ),
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: contentTheme.border,
                              ),
                              _buildInfoRow(
                                "Tổng SL:",
                                "${_calculateTotalBaseQty()}",
                                contentTheme,
                                isBold: true,
                              ),
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: contentTheme.border,
                              ),
                              _buildInfoRow(
                                "Tổng SL lô:",
                                "${_productList.length}",
                                contentTheme,
                                isBold: true,
                              ),
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: contentTheme.border,
                              ),
                              MySpacing.height(8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MySpacing.height(2),
                                  MyText.bodySmall(
                                    "Ghi chú:",
                                    fontWeight: 500,
                                    fontSize: 13,
                                    color: contentTheme.onBackground,
                                  ),
                                  const SizedBox(height: 8),
                                  MyInput(
                                    controller: _ghiChuController,
                                    maxLines: 3,
                                    borderRadius: 8,
                                    onChanged: (value) {
                                      _currentProduceData =
                                          (_currentProduceData ??
                                                  ProduceModel())
                                              .copyWith(doc_descr: value);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      MySpacing.height(16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyText.bodyMedium(
                            "Danh sách sản phẩm",
                            fontWeight: 700,
                            fontSize: 16,
                            color: contentTheme.onBackground,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (isEditMode) ...[
                                Builder(
                                  builder: (context) {
                                    final rawData = _currentProduceData;
                                    final bool canUpload =
                                        rawData?.header_id != null &&
                                        rawData?.is_upload != null &&
                                        rawData?.is_upload == false;

                                    return InkWell(
                                      onTap: canUpload ? _handleUpload : null,
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: canUpload
                                              ? contentTheme.primary
                                                    .withOpacity(0.15)
                                              : contentTheme.disabled
                                                    .withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          RemixIcons.upload_2_fill,
                                          color: canUpload
                                              ? contentTheme.primary
                                              : contentTheme.disabled,
                                          size: 22,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                MySpacing.width(10),
                              ],
                              InkWell(
                                onTap: _handleAddProduct,
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
                        ],
                      ),
                      MySpacing.height(8),
                      _isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(),
                            )
                          : MyTable<ProduceLineModel>(
                              data: _productList,
                              columns: _productColumns,
                              renderCell: _renderCustomCell,
                              borderRadius: 8,
                              emptyText: "Chưa có dòng sản phẩm",
                              onRowPress: (item, index) =>
                                  _handleEditProduct(item, index),
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

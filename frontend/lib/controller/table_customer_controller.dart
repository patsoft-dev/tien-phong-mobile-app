import 'package:get/get.dart';
import 'package:qr_app/models/table_customer_model.dart';

class TableCustomerController extends GetxController {
  final String tableTitle;
  final List<TableCustomerData> dataSource;

  TableCustomerController({required this.tableTitle, required this.dataSource});
}

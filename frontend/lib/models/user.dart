import 'package:qr_app/models/identifier_model.dart';

class User extends IdentifierModel {
  final String username, firstName, lastName;

  User(super.id, this.username, this.firstName, this.lastName);

  String get name => "$firstName $lastName";
}

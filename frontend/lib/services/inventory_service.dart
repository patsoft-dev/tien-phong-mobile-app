import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:qr_app/services/api/api_service.dart';

class InventoryService {
  static Future<Map<String, dynamic>?> getLotSerialDetail({
    String lot_serial_nbr = '',
    String inventory_cd = '',
  }) async {
    try {
      final response = await ApiService.get(
        '/api/Inventory/getLotSerialDetail',
        params: {
          'inventory_cd': inventory_cd,
          'lot_serial_nbr': lot_serial_nbr,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      }

      return null;
    } catch (e) {
      debugPrint('❌ Lỗi tại InventoryService.getLotSerialDetail: $e');
      return null;
    }
  }

  static Future<bool> deleteProduce(dynamic id) async {
    try {
      final response = await ApiService.delete(
        '/api/ScaleProduct/delete?id=$id',
      );
      debugPrint("Response status code: ${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Lỗi tại InventoryService.deleteProduce: $e');
      return false;
    }
  }

  /// Lấy danh sách kho (Sites)
  static Future<Map<String, dynamic>?> getSite({
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await ApiService.get('/api/IN/Sites', params: params);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      }

      return null;
    } catch (e) {
      debugPrint('❌ Lỗi tại InventoryService.getSite: $e');
      return null;
    }
  }

  /// Lấy danh sách vị trí kho (Locations) theo siteid
  static Future<Map<String, dynamic>?> getLocation({
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await ApiService.get(
        '/api/IN/Locations',
        params: params,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      }

      return null;
    } catch (e) {
      debugPrint('❌ Lỗi tại InventoryService.getLocation: $e');
      return null;
    }
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:qr_app/services/api/api_service.dart';

class ProduceService {
  static Future<Map<String, dynamic>?> getListProduce(
    Map<String, dynamic> params,
  ) async {
    try {
      final response = await ApiService.get(
        '/api/ScaleProduct/list',
        params: params,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Lỗi tại ProduceService.getListProduce: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getOneProduce(
    Map<String, dynamic> params,
  ) async {
    try {
      final response = await ApiService.get(
        '/api/ScaleProduct',
        params: params,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Lỗi tại ProduceService.getOneProduce: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateProduce(
    Map<String, dynamic> params,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await ApiService.post(
        '/api/ScaleProduct/update',
        params: params,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Lỗi tại ProduceService.updateProduce: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> createProduce(
    Map<String, dynamic> data, {
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await ApiService.post(
        '/api/ScaleProduct/create',
        params: params,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Lỗi tại ProduceService.createProduce: $e');
      return null;
    }
  }

  static Future<bool> deleteProduce(dynamic id) async {
    try {
      final response = await ApiService.delete(
        '/api/ScaleProduct/delete?id=$id',
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('❌ Lỗi tại ProduceService.deleteProduce: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getDiscreteByLSX(
    Map<String, dynamic> params,
  ) async {
    try {
      final response = await ApiService.get(
        '/api/Discrete/getDiscrete',
        params: params,
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Lỗi tại ProduceService.getDiscreteByLSX: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getInventoryByID(
    Map<String, dynamic> params,
  ) async {
    try {
      final response = await ApiService.get(
        '/api/Inventory/getInventory',
        params: params,
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Lỗi tại ProduceService.getInventoryByID: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getWeighStation(
    Map<String, dynamic> params,
  ) async {
    try {
      final response = await ApiService.get(
        '/api/TramCan/getTramCan',
        params: params,
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Lỗi tại ProduceService.getWeighStation: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getLatestWeighingByID(
    String maCan,
  ) async {
    try {
      final response = await ApiService.post(
        '/api/SIAM/getLatestWeighingByMaCan',
        data: {'ma_can': maCan},
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Lỗi tại ProduceService.getLatestWeighingByID: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> uploadProduce(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await ApiService.post(
        '/api/ScaleProduct/updateIsUpload',
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Lỗi tại ProduceService.uploadProduce: $e');
      return null;
    }
  }
}

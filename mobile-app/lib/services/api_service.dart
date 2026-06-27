import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../models/api_response.dart';
import '../models/auth_response_model.dart';
import '../models/cart_item_model.dart';
import '../models/chatbot_response_model.dart';
import '../models/map_place_model.dart';
import '../models/product_model_api.dart';
import '../models/scan_analyze_model.dart';
import '../models/scan_result_model.dart';
import '../models/skin_test_question_model.dart';
import '../models/skin_test_result_model.dart';
import '../models/user_model.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl =
      'https://dermamind-api-production-3393.up.railway.app';

  static String? _token;

  static void setToken(String token) => _token = token;
  static void clearToken() => _token = null;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  static Map<String, String> get _authHeaders => {
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // ── AUTH ───────────────────────────────────────────────────────────────────

  static Future<ApiResponse<AuthResponseModel>> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/Auth/register'),
      );
      request.fields['FullName'] = fullName;
      request.fields['Email'] = email;
      request.fields['Password'] = password;
      request.fields['ConfirmPassword'] = confirmPassword;

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      return _handleResponse(
        response,
            (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.error(_exceptionMessage(e));
    }
  }

  static Future<ApiResponse<AuthResponseModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/Auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      return _handleResponse(
        response,
            (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.error(_exceptionMessage(e));
    }
  }

  static Future<ApiResponse<bool>> forgetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/Auth/forget-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      return _handleResponse(response, (_) => true);
    } catch (e) {
      return ApiResponse.error(_exceptionMessage(e));
    }
  }

  static Future<ApiResponse<bool>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/Auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );
      return _handleResponse(response, (_) => true);
    } catch (e) {
      return ApiResponse.error(_exceptionMessage(e));
    }
  }

  static Future<ApiResponse<bool>> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/Auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
      );
      return _handleResponse(response, (_) => true);
    } catch (e) {
      return ApiResponse.error(_exceptionMessage(e));
    }
  }

  static Future<ApiResponse<AuthResponseModel>> googleLogin({
    required String idToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/Auth/google-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );
      return _handleResponse(
        response,
            (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.error(_exceptionMessage(e));
    }
  }

  // ── SCAN ───────────────────────────────────────────────────────────────────

  static Future<ApiResponse<ScanAnalyzeModel>> analyzeSkin({
    required String imagePath,
    String? skinType,
    String? medicalHistory,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/DermaScan/analyze'),
      );
      request.headers.addAll(_authHeaders);
      request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imagePath,
            contentType: MediaType('image', 'jpeg')));

      if (skinType != null) request.fields['skin_type'] = skinType;
      if (medicalHistory != null) {
        request.fields['medical_history'] = medicalHistory;
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      debugPrint("STATUS => ${response.statusCode}");
      debugPrint("BODY => ${response.body}");
      return _handleResponse(
        response,
            (json) => ScanAnalyzeModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.error(_exceptionMessage(e));
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> analyzeSkinRaw({
    required String imagePath,
    String? skinType,
    String? medicalHistory,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/DermaScan/analyze'),
      );
      request.headers.addAll(_authHeaders);
      request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imagePath,
            contentType: MediaType('image', 'jpeg')));

      if (skinType != null) request.fields['skin_type'] = skinType;
      if (medicalHistory != null) {
        request.fields['medical_history'] = medicalHistory;
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      debugPrint("STATUS => ${response.statusCode}");
      debugPrint("========== RAW RESPONSE ==========");
      debugPrint(response.body);
      return _handleResponse(
        response,
            (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      return ApiResponse.error(_exceptionMessage(e));
    }
  }

  static Future<ApiResponse<ScanAnalyzeModel>> diagnoseStart({
    required String imagePath,
    String lang = 'ar',
    String? medicalHistory,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/DermaScan/diagnose/start'),
      );
      request.headers.addAll(_authHeaders);
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imagePath,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
      request.fields['lang'] = lang;
      if (medicalHistory != null && medicalHistory.isNotEmpty) {
        request.fields['medical_history'] = medicalHistory;
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      debugPrint('diagnose/start STATUS => ${response.statusCode}');
      debugPrint('diagnose/start BODY => ${response.body}');
      return _handleResponse(
        response,
        (json) => ScanAnalyzeModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.error(_exceptionMessage(e));
    }
  }

  static Future<ApiResponse<ScanResultModel>> diagnoseComplete({
    required Map<String, dynamic> modelResult,
    required List<Map<String, dynamic>> answers,
    required String skinType,
    String? medicalHistory,
    String lang = 'ar',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/DermaScan/diagnose/complete'),
        headers: _headers,
        body: jsonEncode({
          'model_result': modelResult,
          'answers': answers,
          'skin_type': skinType,
          'medical_history': medicalHistory ?? '',
          'lang': lang,
        }),
      );
      debugPrint('diagnose/complete STATUS => ${response.statusCode}');
      debugPrint('diagnose/complete BODY => ${response.body}');
      return _handleResponse(
        response,
        (json) => ScanResultModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.error(_exceptionMessage(e));
    }
  }

  // GET /api/DermaScan/history
  static Future<ApiResponse<List<dynamic>>> getScanHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/DermaScan/history'),
        headers: _authHeaders,
      );
      return _handleResponse(
        response,
            (json) => json is List ? json : (json as Map)['data'] as List? ?? [],
      );
    } catch (e) {
      return ApiResponse.error(_exceptionMessage(e));
    }
  }

// GET /api/DermaScan/history/{id}
  static Future<ApiResponse<Map<String, dynamic>>> getScanById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/DermaScan/history/$id'),
        headers: _authHeaders,
      );
      return _handleResponse(
        response,
            (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      return ApiResponse.error(_exceptionMessage(e));
    }
  }

  // ── CHATBOT ────────────────────────────────────────────────────────────────

  static Future<ApiResponse<ChatbotResponseModel>> sendChatMessage({
    required String message,
    List<dynamic>? history,
    String? diagnosisContext,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/Chatbot/send'),
        headers: _headers,
        body: jsonEncode({
          'message': message,
          'history': history ?? [],
          'diagnosisContext': diagnosisContext,
        }),
      ).timeout(const Duration(seconds: 15));
      return _handleResponse(
        response,
            (json) =>
            ChatbotResponseModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.error(_exceptionMessage(e));
    }
  }

  // ── SKIN TEST ──────────────────────────────────────────────────────────────

  static Future<ApiResponse<List<SkinTestQuestionModel>>>
  getSkinTestQuestions({String lang = 'en'}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/SkinTest/questions?lang=$lang'),
        headers: _authHeaders,
      );
      return _handleResponse(
        response,
            (json) {
          final list = json is List ? json : (json as Map)['data'] as List;
          return list
              .map((q) => SkinTestQuestionModel.fromJson(
              q as Map<String, dynamic>))
              .toList();
        },
      );
    } catch (e) {
      return ApiResponse.error(_exceptionMessage(e));
    }
  }

  static Future<ApiResponse<SkinTestResultModel>> submitSkinTest({
    required List<int> selectedOptionIds,
    String lang = 'en',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/SkinTest/submit?lang=$lang'),
        headers: _headers,
        body: jsonEncode({'selectedOptionIds': selectedOptionIds}),
      );
      return _handleResponse(
        response,
            (json) =>
            SkinTestResultModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.error(_exceptionMessage(e));
    }
  }

  static Future<ApiResponse<SkinTestResultModel>> getSkinTestResult({
    String lang = 'en',
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/SkinTest/my-result?lang=$lang'),
        headers: _authHeaders);

      return _handleResponse(
        response,
            (json) =>
            SkinTestResultModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.error(_exceptionMessage(e));
    }
  }

  // ── PRODUCTS ───────────────────────────────────────────────────────────────

  static Future<ApiResponse<List<ProductModelApi>>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/Product'),
        headers: _authHeaders,
      );
      return _handleResponse(
        response,
            (json) {
          final list = json is List ? json : (json as Map)['data'] as List;
          return list
              .map((p) =>
              ProductModelApi.fromJson(p as Map<String, dynamic>))
              .toList();
        },
      );
    } catch (e) {
      return ApiResponse.error(_exceptionMessage(e));
    }
  }

  static Future<ApiResponse<List<ProductModelApi>>> searchProducts(
      String query) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/Product/search?query=${Uri.encodeComponent(query)}'),
        headers: _authHeaders,
      );
      return _handleResponse(
        response,
            (json) {
          final list = json is List ? json : (json as Map)['data'] as List;
          return list
              .map((p) =>
              ProductModelApi.fromJson(p as Map<String, dynamic>))
              .toList();
        },
      );
    } catch (e) {
      return ApiResponse.error(_exceptionMessage(e));
    }
  }

  // ── CART ───────────────────────────────────────────────────────────────────

  static Future<ApiResponse<List<CartItemModel>>> getCart() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/Cart'),
        headers: _authHeaders,
      );
      return _handleResponse(
        response,
            (json) {
          final list = json is List ? json : (json as Map)['data'] as List;
          return list
              .map((c) =>
              CartItemModel.fromJson(c as Map<String, dynamic>))
              .toList();
        },
      );
    } catch (e) {
      return ApiResponse.error(_exceptionMessage(e));
    }
  }

  static Future<ApiResponse<bool>> addToCart({
    required int productId,
    int quantity = 1,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
            '$baseUrl/api/Cart/add?productId=$productId&quantity=$quantity'),
        headers: _authHeaders,
      );
      return _handleResponse(response, (_) => true);
    } catch (e) {
      return ApiResponse.error(_exceptionMessage(e));
    }
  }

  static Future<ApiResponse<bool>> removeFromCart(int cartItemId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/Cart/remove/$cartItemId'),
        headers: _authHeaders,
      );
      return _handleResponse(response, (_) => true);
    } catch (e) {
      return ApiResponse.error(_exceptionMessage(e));
    }
  }

  static Future<ApiResponse<bool>> checkout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/Cart/checkout'),
        headers: _authHeaders,
      );
      return _handleResponse(response, (_) => true);
    } catch (e) {
      return ApiResponse.error(_exceptionMessage(e));
    }
  }

  // ── WISHLIST ───────────────────────────────────────────────────────────────

  static Future<ApiResponse<bool>> addToWishlist(int productId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/Wishlist/add/$productId'),
        headers: _authHeaders,
      );
      return _handleResponse(response, (_) => true);
    } catch (e) {
      return ApiResponse.error(_exceptionMessage(e));
    }
  }

  static Future<ApiResponse<List<ProductModelApi>>> getWishlist() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/Wishlist'),
        headers: _authHeaders,
      );
      return _handleResponse(
        response,
            (json) {
          final list = json is List ? json : (json as Map)['data'] as List;
          return list
              .map((p) =>
              ProductModelApi.fromJson(p as Map<String, dynamic>))
              .toList();
        },
      );
    } catch (e) {
      return ApiResponse.error(_exceptionMessage(e));
    }
  }

  static Future<ApiResponse<bool>> removeFromWishlist(
      int wishlistItemId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/Wishlist/remove/$wishlistItemId'),
        headers: _authHeaders,
      );
      return _handleResponse(response, (_) => true);
    } catch (e) {
      return ApiResponse.error(_exceptionMessage(e));
    }
  }

  // ── MAP ────────────────────────────────────────────────────────────────────

  static Future<ApiResponse<List<MapPlaceModel>>> getClinics({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/Map/clinics?latitude=$latitude&longitude=$longitude'),
        headers: _authHeaders,
      );
      return _handleResponse(
        response,
            (json) {
          final list = json is List ? json : (json as Map)['data'] as List;
          return list
              .map((c) => MapPlaceModel.fromJson(c as Map<String, dynamic>))
              .toList();
        },
      );
    } catch (e) {
      return ApiResponse.error(_exceptionMessage(e));
    }
  }

  static Future<ApiResponse<List<MapPlaceModel>>> getPharmacies({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/Map/pharmacies?latitude=$latitude&longitude=$longitude'),
        headers: _authHeaders,
      );
      return _handleResponse(
        response,
            (json) {
          final list = json is List ? json : (json as Map)['data'] as List;
          return list
              .map((p) => MapPlaceModel.fromJson(p as Map<String, dynamic>))
              .toList();
        },
      );
    } catch (e) {
      return ApiResponse.error(_exceptionMessage(e));
    }
  }

  // ── PROFILE ────────────────────────────────────────────────────────────────

  static Future<ApiResponse<UserModel>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/Profile'),
        headers: _authHeaders,
      );
      return _handleResponse(
        response,
            (json) => UserModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.error(_exceptionMessage(e));
    }
  }

  static Future<ApiResponse<bool>> updateProfile({
    String? fullName,
    String? skinType,
    String? phoneNumber,
    String? imagePath,
  }) async {
    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/api/Profile/update'),
      );
      request.headers.addAll(_authHeaders);
      if (fullName != null) request.fields['fullName'] = fullName;
      if (skinType != null) request.fields['skinType'] = skinType;
      if (phoneNumber != null) request.fields['phoneNumber'] = phoneNumber;
      if (imagePath != null) {
        request.files.add(
            await http.MultipartFile.fromPath('image', imagePath));
      }
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      return _handleResponse(response, (_) => true);
    } catch (e) {
      return ApiResponse.error(_exceptionMessage(e));
    }
  }

  static Future<ApiResponse<bool>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/Profile/change-password'),
        headers: _headers,
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );
      return _handleResponse(response, (_) => true);
    } catch (e) {
      return ApiResponse.error(_exceptionMessage(e));
    }
  }

  // ── PRIVATE HELPERS ────────────────────────────────────────────────────────

  static ApiResponse<T> _handleResponse<T>(
      http.Response response,
      T Function(dynamic json) fromJson,
      ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        try {
          return ApiResponse.success(
              fromJson(null), statusCode: response.statusCode);
        } catch (_) {
          return ApiResponse.success(
              fromJson(<String, dynamic>{}),
              statusCode: response.statusCode);
        }
      }
      try {
        final decoded = jsonDecode(response.body);
        return ApiResponse.success(fromJson(decoded),
            statusCode: response.statusCode);
      } catch (e) {
        return ApiResponse.error('Failed to parse response',
            statusCode: response.statusCode);
      }
    } else {
      return ApiResponse.error(
        _parseError(response.body),
        statusCode: response.statusCode,
      );
    }
  }

  static String _parseError(String body) {
    if (body.isEmpty) return 'Something went wrong';
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return (json['message'] ?? json['error'] ?? 'Something went wrong')
          .toString();
    } catch (_) {
      return 'Something went wrong';
    }
  }

  static String _exceptionMessage(Object e) {
    if (e is ApiException) return e.message;
    return 'Network error. Please check your connection.';
  }
}

// ── Exception ──────────────────────────────────────────────────────────────────

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
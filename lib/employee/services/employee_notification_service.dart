import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/api_config.dart';

class EmployeeNotificationService {
  static const String baseUrl = AppConfig.baseUrl;

  // Login screen mein token jis key se save hota hai,
  // us key ko is list mein confirm kar lena.
  static const List<String> _tokenKeys = [
    'access_token',
    'accessToken',
    'token',
    'jwt_token',
    'jwtToken',
  ];

  final String? token;

  EmployeeNotificationService({this.token});

  /// Saved JWT token read karta hai.
  Future<String> _getToken() async {
    // Agar constructor mein token diya hai, to use karo.
    if (token != null && token!.trim().isNotEmpty) {
      return token!.trim();
    }

    final prefs = await SharedPreferences.getInstance();

    for (final key in _tokenKeys) {
      final value = prefs.getString(key);

      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    throw Exception(
      'Login token missing. Login screen mein JWT access token save karo.',
    );
  }

  /// Har authenticated API call ke headers.
  Future<Map<String, String>> _getHeaders() async {
    final accessToken = await _getToken();

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }

  /// Common HTTP response validation.
  void _validateResponse(
    http.Response response,
    String action,
  ) {
    if (response.statusCode == 401 ||
        response.statusCode == 403) {
      throw Exception(
        'Authentication failed. Session expire ho sakta hai; dobara login karo.',
      );
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        '$action failed. HTTP ${response.statusCode}: ${response.body}',
      );
    }
  }

  /// API response ko notifications ki list mein convert karta hai.
  List<Map<String, dynamic>> _parseNotifications(
    dynamic decoded,
  ) {
    dynamic items;

    if (decoded is List) {
      items = decoded;
    } else if (decoded is Map &&
        decoded['notifications'] is List) {
      items = decoded['notifications'];
    } else if (decoded is Map &&
        decoded['data'] is List) {
      items = decoded['data'];
    } else {
      items = <dynamic>[];
    }

    return (items as List)
        .whereType<Map>()
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();
  }

  /// Employee ki notifications load karta hai.
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final headers = await _getHeaders();

    final response = await http
        .get(
          Uri.parse('$baseUrl/api/notifications/me'),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));

    _validateResponse(response, 'Notifications load');

    final dynamic decoded = jsonDecode(response.body);

    return _parseNotifications(decoded);
  }

  /// Unread notifications ki count load karta hai.
  Future<int> getUnreadCount() async {
    final headers = await _getHeaders();

    final response = await http
        .get(
          Uri.parse('$baseUrl/api/notifications/unread-count'),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));

    _validateResponse(response, 'Unread count load');

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is int) {
      return decoded;
    }

    if (decoded is Map) {
      final value = decoded['unread_count'] ??
          decoded['count'] ??
          decoded['unread'];

      if (value is int) {
        return value;
      }

      if (value is num) {
        return value.toInt();
      }

      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
    }

    return 0;
  }

  /// Ek notification ko read mark karta hai.
  ///
  /// notificationId ko backend ke actual notification ID se call karo.
  Future<bool> markAsRead(dynamic notificationId) async {
    if (notificationId == null ||
        notificationId.toString().trim().isEmpty) {
      throw Exception('Notification ID missing.');
    }

    final headers = await _getHeaders();

    final id = Uri.encodeComponent(
      notificationId.toString(),
    );

    final response = await http
        .patch(
          Uri.parse('$baseUrl/api/notifications/$id/read'),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));

    _validateResponse(response, 'Mark notification as read');

    return true;
  }

  /// Saari notifications ko read mark karta hai.
  Future<bool> markAllAsRead() async {
    final headers = await _getHeaders();

    final response = await http
        .patch(
          Uri.parse('$baseUrl/api/notifications/read-all'),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));

    _validateResponse(response, 'Mark all as read');

    return true;
  }

  /// Notifications aur unread count ko ek saath load karne ka helper.
  Future<Map<String, dynamic>> getNotificationSummary() async {
    final results = await Future.wait<dynamic>([
      getNotifications(),
      getUnreadCount(),
    ]);

    return {
      'notifications': results[0] as List<Map<String, dynamic>>,
      'unread_count': results[1] as int,
    };
  }

  /// Debug ke liye token saved hai ya nahi check karta hai.
  /// Security ke liye actual token print nahi karta.
  Future<bool> hasSavedToken() async {
    try {
      final value = await _getToken();
      return value.isNotEmpty;
    } catch (e) {
      debugPrint('Notification token check: $e');
      return false;
    }
  }
}

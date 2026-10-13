
import 'dart:convert';
import 'package:http/http.dart' as http;

class EmployeeNotificationService {
  // Apne login screen mein use hone wala SAME FastAPI base URL yahan lagao.
  // Android emulator: http://10.0.2.2:8000
  static const String baseUrl = 'http://127.0.0.1:8000';

  final String? token;

  EmployeeNotificationService({this.token});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null && token!.trim().isNotEmpty)
          'Authorization': 'Bearer ${token!.trim()}',
      };

  void _checkAuth() {
    if (token == null || token!.trim().isEmpty) {
      throw Exception(
        'Login token missing. Login response se access token pass karo.',
      );
    }
  }

  /// Employee ki notifications fetch karta hai.
  Future<List<Map<String, dynamic>>> getNotifications() async {
    _checkAuth();

    final response = await http.get(
      Uri.parse('$baseUrl/api/notifications/me'),
      headers: _headers,
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      final List<dynamic> items = decoded is List
          ? decoded
          : (decoded is Map && decoded['notifications'] is List)
              ? decoded['notifications'] as List
              : [];

      return items
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Session expire ho gaya. Dobara login karo.');
    }

    throw Exception(
      'Notifications load nahi hui. Server response: ${response.statusCode}',
    );
  }

  /// Unread notifications ki total count.
  Future<int> getUnreadCount() async {
    _checkAuth();

    final response = await http.get(
      Uri.parse('$baseUrl/api/notifications/unread-count'),
      headers: _headers,
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is int) return decoded;

      if (decoded is Map) {
        final value = decoded['unread_count'] ??
            decoded['count'] ??
            decoded['unread'];

        if (value is int) return value;
        if (value is num) return value.toInt();
        if (value is String) return int.tryParse(value) ?? 0;
      }

      return 0;
    }

    throw Exception(
      'Unread count load nahi hui: ${response.statusCode}',
    );
  }

  /// Notification ko read mark karta hai.
  Future<bool> markAsRead(dynamic notificationId) async {
    _checkAuth();

    final response = await http.patch(
      Uri.parse(
        '$baseUrl/api/notifications/${Uri.encodeComponent(notificationId.toString())}/read',
      ),
      headers: _headers,
    ).timeout(const Duration(seconds: 15));

    return response.statusCode == 200 ||
        response.statusCode == 204;
  }

  /// Sabhi notifications ko read mark karta hai.
  Future<bool> markAllAsRead() async {
    _checkAuth();

    final response = await http.patch(
      Uri.parse('$baseUrl/api/notifications/read-all'),
      headers: _headers,
    ).timeout(const Duration(seconds: 15));

    return response.statusCode == 200 ||
        response.statusCode == 204;
  }
}

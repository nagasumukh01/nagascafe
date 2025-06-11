import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  // Get all orders
  static Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/orders'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      throw Exception('Failed to load orders');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get orders by date
  static Future<List<Map<String, dynamic>>> getOrdersByDate(DateTime date) async {
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await http.get(Uri.parse('$baseUrl/orders/date/$dateStr'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      throw Exception('Failed to load orders');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Create new order
  static Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderData),
      );
      if (response.statusCode == 201) {
        return json.decode(response.body);
      }
      throw Exception('Failed to create order');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get analytics for a period
  static Future<Map<String, dynamic>> getAnalytics(String period) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/analytics/$period'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to load analytics');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
} 
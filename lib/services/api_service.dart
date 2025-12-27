import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String url = 'https://dummyjson.com/comments?limit=10';

  Future<Map> getChatResponse(String message) async {
    try {
      final response = await http
          .get(Uri.parse('$url'), headers: {'Content-Type': 'application/json'})
          .timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data ?? 'I received your message: $message';
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

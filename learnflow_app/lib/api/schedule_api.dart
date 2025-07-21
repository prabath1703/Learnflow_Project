import 'dart:convert';
import 'package:http/http.dart' as http;

/// Update this URL based on your backend environment.
/// For local emulator: http://10.0.2.2:8000 (Android) or http://127.0.0.1:8000 (iOS or Web)
final String baseUrl = 'http://127.0.0.1:8000';

class ScheduleApi {
  static Future<Map<String, dynamic>?> generateSchedule(Map<String, dynamic> inputData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/generate_schedule'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(inputData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Server responded with status: ${response.statusCode}');
        return {'error': 'Failed to connect to server. Status: ${response.statusCode}'};
      }
    } catch (e) {
      print('Error during HTTP request: $e');
      return {'error': 'An error occurred: ${e.toString()}'};
    }
  }
}

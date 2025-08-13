import 'dart:convert';
import 'package:http/http.dart' as http;

/// ✅ Correct URL of your backend
const String baseUrl = 'http://192.168.1.8:10000';

class ScheduleApi {
  static Future<Map<String, dynamic>?> generateSchedule(Map<String, dynamic> inputData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/generate-visionary-schedule'), // ✅ Correct endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(inputData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('❌ Server responded with status: ${response.statusCode}');
        return {'error': 'Failed to connect to server. Status: ${response.statusCode}'};
      }
    } catch (e) {
      print('❌ Error during HTTP request: $e');
      return {'error': 'An error occurred: ${e.toString()}'};
    }
  }
}

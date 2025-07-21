import 'dart:convert';
import 'package:http/http.dart' as http;

/// ✅ Update this URL to point to your deployed backend
final String baseUrl = 'https://learnflow-backend-n1js.onrender.com';

class ScheduleApi {
  static Future<Map<String, dynamic>?> generateSchedule(Map<String, dynamic> inputData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/smart-schedule'), // ✅ Make sure the endpoint matches FastAPI route
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

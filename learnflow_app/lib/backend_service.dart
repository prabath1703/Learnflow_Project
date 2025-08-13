import 'dart:convert';
import 'package:http/http.dart' as http;

// Updated with your local IP
const String baseUrl = 'https://learnflow-backend-n1js.onrender.com';

class BackendService {
  /// Sends user prompt to the AI model and gets the generated schedule.
  static Future<String> generateVisionarySchedule(String prompt) async {
    final url = Uri.parse('$baseUrl/generate-visionary-schedule');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': prompt}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['generated_schedule']; // Return beautified string
      } else {
        throw Exception('Failed to generate schedule.');
      }
    } catch (e) {
      throw Exception('Failed to generate schedule.');
    }
  }
}

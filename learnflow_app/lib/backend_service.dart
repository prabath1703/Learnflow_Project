import 'dart:convert';
import 'package:http/http.dart' as http;

/// For Android emulator or Chrome web builds, use 10.0.2.2 to connect to host machine.
final String _backendUrl = "https://learnflow-backend-n1js.onrender.com";



class BackendService {
  /// Sends study plan request to the FastAPI backend
  static Future<Map<String, dynamic>> generatePlan(
    List<String> topicsList, {
    required String username,
    int hours = 2,
  }) async {
    final url = Uri.parse("$_backendUrl/smart-schedule");
     // ✅ Correct
    final headers = {"Content-Type": "application/json"};

    final body = jsonEncode({
      "username": username,
      "subjects": topicsList,
      "hours": hours,
    });

    try {
      print("📡 Sending plan request to backend...");
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print("✅ Plan generation successful");
        return jsonDecode(response.body);
      } else {
        print("❌ Server Error [${response.statusCode}]: ${response.body}");
        throw Exception("Failed to generate plan");
      }
    } catch (e) {
      print("⚠️ Exception caught: $e");
      throw Exception("Connection error: $e");
    }
  }
}

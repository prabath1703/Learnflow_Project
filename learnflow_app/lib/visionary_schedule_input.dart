import 'package:flutter/material.dart';
import 'backend_service.dart';
import 'visionary_schedule_result.dart';


class VisionaryScheduleInputPage extends StatefulWidget {
  const VisionaryScheduleInputPage({super.key});

  @override
  State<VisionaryScheduleInputPage> createState() => _VisionaryScheduleInputPageState();
}

class _VisionaryScheduleInputPageState extends State<VisionaryScheduleInputPage> {
  final _promptController = TextEditingController();
  bool _loading = false;

  void _submitPrompt() async {
  final prompt = _promptController.text.trim();

  if (prompt.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enter your study goal or prompt.")),
    );
    return;
  }

  setState(() => _loading = true);

  try {
    final schedule = await BackendService.generateVisionarySchedule(prompt);


    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VisionaryScheduleResultPage(schedule: schedule),
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  } finally {
    setState(() => _loading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🧠 Your AI Study Planner")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Describe your study goals",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _promptController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "e.g. NEET 6-month plan with focus on Biology",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _loading ? null : _submitPrompt,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Generate AI Schedule"),
            ),
          ],
        ),
      ),
    );
  }
}

import 'backend_service.dart';
import 'learning_page.dart';
import 'smart_schedule_input.dart'; // ✅ Correct import
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart' show rootBundle;

class TopicSelectorPage extends StatefulWidget {
  const TopicSelectorPage({super.key});

  @override
  State<TopicSelectorPage> createState() => _TopicSelectorPageState();
}

class _TopicSelectorPageState extends State<TopicSelectorPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _topics = [];
  final Set<String> _existingTopics = {};
  bool _loading = false;

  Future<String> _getIconPath(String topic) async {
    final formatted = topic.toLowerCase().replaceAll(' ', '');
    final pngPath = 'assets/icons/$formatted.png';
    final jpgPath = 'assets/icons/$formatted.jpg';

    try {
      await rootBundle.load(pngPath);
      return pngPath;
    } catch (_) {}

    try {
      await rootBundle.load(jpgPath);
      return jpgPath;
    } catch (_) {}

    return 'assets/icons/default.png';
  }

  void _addTopic(String topic) {
    final cleaned = topic.trim();
    if (cleaned.isEmpty || _existingTopics.contains(cleaned.toLowerCase())) return;

    setState(() {
      _topics.add(cleaned);
      _existingTopics.add(cleaned.toLowerCase());
      _controller.clear();
    });
  }

  void _removeTopic(int index) {
    setState(() {
      _existingTopics.remove(_topics[index].toLowerCase());
      _topics.removeAt(index);
    });
  }

  Future<void> _goToLearningPage(Map<String, dynamic> schedulePrefs) async {
    if (_topics.isEmpty) return;

    setState(() {
      _loading = true;
    });

    try {
      final topic = _topics.first;

      final planData = await BackendService.generatePlan(
        _topics,
        username: "prabath",
        hours: schedulePrefs['studyHours'] ?? 2,
      );

      Navigator.pushNamed(
  context,
  '/learning',
  arguments: {
    'topic': topic,
    'plan': planData,
  },
);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ ${e.toString()}")),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _openSmartScheduleForm() async {
    final schedulePrefs = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SmartScheduleInputPage(selectedTopics: _topics), // ✅ Renamed class
      ),
    );

    if (schedulePrefs != null && schedulePrefs is Map<String, dynamic>) {
      _goToLearningPage(schedulePrefs);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                "What would you like to study today?",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.cyanAccent,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Enter any topic (e.g. Python, DSA)",
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.grey.shade900,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onSubmitted: _addTopic,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _addTopic(_controller.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Add"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _topics.length,
                  itemBuilder: (context, index) {
                    final topic = _topics[index];
                    return FutureBuilder<String>(
                      future: _getIconPath(topic),
                      builder: (context, snapshot) {
                        final iconPath = snapshot.data ?? 'assets/icons/default.png';
                        return Card(
                          color: Colors.grey.shade900,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: Image.asset(iconPath, height: 40, width: 40),
                            title: Text(
                              topic,
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, color: Colors.redAccent),
                              onPressed: () => _removeTopic(index),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              if (_topics.isNotEmpty)
                ElevatedButton(
                  onPressed: _loading ? null : _openSmartScheduleForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.shade400,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          'Continue',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LearningPage extends StatelessWidget {
  final String topic;
  final Map<String, dynamic> plan;

  const LearningPage({
    super.key,
    required this.topic,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Extract the actual daily plan from the backend response
    final Map<String, dynamic> dailyPlan = plan['plan'];
    final dayKeys = dailyPlan.keys.toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.cyan.shade700,
        title: Text(
          "📘 $topic Learning Plan",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: dayKeys.length,
          itemBuilder: (context, index) {
            final day = dayKeys[index];
            final rawItems = dailyPlan[day];
            final items = rawItems is List ? List<String>.from(rawItems) : [rawItems.toString()];

            return Card(
              color: Colors.grey.shade900,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                collapsedIconColor: Colors.white70,
                iconColor: Colors.cyan,
                title: Text(
                  day,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: items
                    .map(
                      (lesson) => ListTile(
                        leading: const Icon(Icons.check_circle, color: Colors.greenAccent),
                        title: Text(
                          lesson,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    )
                    .toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}

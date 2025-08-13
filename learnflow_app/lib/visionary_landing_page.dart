import 'package:flutter/material.dart';
import 'summarizer_screen.dart'; // ✅ import your new screen

class FeatureSelectionPage extends StatelessWidget {
  const FeatureSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome to LearnFlow 👋",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Select a feature to get started:",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              _buildFeatureCard(
                title: "🚀 AI Schedule Generator",
                subtitle: "Create a custom study plan from your goal prompt",
                color: Colors.purple,
                onTap: () {
                  Navigator.pushNamed(context, '/visionary-input');
                },
              ),
              _buildFeatureCard(
                title: "📹 AI-Generated Video & Notes Summarizer",
                subtitle: "Summarize YouTube lectures, PDFs & scanned notes",
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SummarizerScreen()),
                  );
                },
              ),
              _buildFeatureCard(
                title: "🧪 Smart Progress Tracker (Coming Soon)",
                subtitle: "Track how well you’re doing across subjects",
                color: Colors.indigo,
              ),
              _buildFeatureCard(
                title: "📚 Personalized Revision",
                subtitle: "Get revision plans based on your weak topics",
                color: Colors.teal,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'NotoColorEmoji',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

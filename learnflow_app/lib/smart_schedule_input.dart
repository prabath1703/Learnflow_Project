import 'package:flutter/material.dart';
import 'dart:convert';
import '../api/schedule_api.dart'; // <-- Path verified

class SmartScheduleInputPage extends StatefulWidget {
  final List<String> selectedTopics;

  const SmartScheduleInputPage({
    super.key,
    required this.selectedTopics,
  });

  @override
  State<SmartScheduleInputPage> createState() => _SmartScheduleInputPageState();
}

class _SmartScheduleInputPageState extends State<SmartScheduleInputPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _wakeTimeController = TextEditingController();
  final TextEditingController _sleepTimeController = TextEditingController();
  final TextEditingController _classTimesController = TextEditingController();
  final TextEditingController _topicsController = TextEditingController();
  final TextEditingController _studyHoursController = TextEditingController();
  final TextEditingController _breakPreferencesController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _topicsController.text = widget.selectedTopics.join(', ');
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final classTimesText = _classTimesController.text.trim();
      List<Map<String, String>> classTimes = [];

      if (classTimesText.isNotEmpty) {
        classTimes = classTimesText.split(',').map((e) {
          final parts = e.trim().split('-');
          if (parts.length == 2) {
            return {
              'start': parts[0].trim(),
              'end': parts[1].trim(),
            };
          } else {
            throw FormatException("Invalid class time format");
          }
        }).toList();
      }

      List<String> topics = _topicsController.text.split(',').map((e) => e.trim()).toList();

      int breakInterval = int.tryParse(
            _breakPreferencesController.text.replaceAll(RegExp(r'\D'), ''),
          ) ??
          10;

      final inputData = {
        'wake_time': _wakeTimeController.text,
        'sleep_time': _sleepTimeController.text,
        'class_times': classTimes,
        'topics': topics,
        'study_hours': int.tryParse(_studyHoursController.text) ?? 0,
        'breaks': breakInterval,
      };

      final response = await ScheduleApi.generateSchedule(inputData);

      if (response != null && !response.containsKey('error')) {
        Navigator.pushNamed(
          context,
          '/schedule_result',
          arguments: response,
        );
      } else {
        throw Exception(response?['error'] ?? 'Failed to generate schedule');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Smart Schedule Input'),
        backgroundColor: Colors.cyan,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_wakeTimeController, 'Wake-up Time (e.g., 06:00)'),
              _buildTextField(_sleepTimeController, 'Sleep Time (e.g., 22:00)'),
              _buildTextField(_classTimesController, 'Class Times (e.g., 09:00-12:00, 14:00-16:00)'),
              _buildTextField(_topicsController, 'Topics (comma-separated)'),
              _buildTextField(_studyHoursController, 'Total Study Hours (e.g., 5)'),
              _buildTextField(_breakPreferencesController, 'Break Duration (e.g., 10 for 10min/hour)'),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Generate Schedule',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white24),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  @override
  void dispose() {
    _wakeTimeController.dispose();
    _sleepTimeController.dispose();
    _classTimesController.dispose();
    _topicsController.dispose();
    _studyHoursController.dispose();
    _breakPreferencesController.dispose();
    super.dispose();
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SummarizerScreen extends StatefulWidget {
  @override
  _SummarizerScreenState createState() => _SummarizerScreenState();
}

class _SummarizerScreenState extends State<SummarizerScreen> {
  final TextEditingController _youtubeController = TextEditingController();
  String? _summary;
  String? _flashcards;
  String? _quiz;
  bool _isLoading = false;

  final String baseUrl = 'https://learnflow-backend-n1js.onrender.com';

  Future<void> _summarizeYouTube() async {
    if (_youtubeController.text.isEmpty) {
      _showError("Please paste a YouTube link.");
      return;
    }

    setState(() {
      _isLoading = true;
      _summary = null;
      _flashcards = null;
      _quiz = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/summarize-youtube'),
        body: {'url': _youtubeController.text},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _summary = data['summary'];
          _flashcards = data['flashcards'];
          _quiz = data['quiz'];
        });
      } else {
        _showError('Error: ${response.body}');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _summarizePDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);

      setState(() {
        _isLoading = true;
        _summary = null;
        _flashcards = null;
        _quiz = null;
      });

      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/summarize-pdf'),
        );
        request.files.add(await http.MultipartFile.fromPath('file', file.path));

        var res = await request.send();
        var responseData = await res.stream.bytesToString();

        if (res.statusCode == 200) {
          final data = jsonDecode(responseData);
          setState(() {
            _summary = data['summary'];
            _flashcards = data['flashcards'];
            _quiz = data['quiz'];
          });
        } else {
          _showError('Error: $responseData');
        }
      } catch (e) {
        _showError(e.toString());
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildResults() {
    if (_summary == null) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("📄 Summary",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(height: 4),
        Text(_summary ?? ''),
        SizedBox(height: 16),
        Text("🃏 Flashcards",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(height: 4),
        Text(_flashcards ?? ''),
        SizedBox(height: 16),
        Text("❓ Quiz",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(height: 4),
        Text(_quiz ?? ''),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AI Summarizer")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _youtubeController,
                decoration: InputDecoration(
                  labelText: "YouTube Link",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              ElevatedButton.icon(
                icon: Icon(Icons.video_library),
                onPressed: _summarizeYouTube,
                label: Text("Summarize YouTube Video"),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                icon: Icon(Icons.picture_as_pdf),
                onPressed: _summarizePDF,
                label: Text("Summarize PDF"),
              ),
              SizedBox(height: 24),
              if (_isLoading) CircularProgressIndicator(),
              if (!_isLoading) _buildResults(),
            ],
          ),
        ),
      ),
    );
  }
}

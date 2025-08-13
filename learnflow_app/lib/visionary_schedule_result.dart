import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class VisionaryScheduleResultPage extends StatefulWidget {
  final String schedule;

  VisionaryScheduleResultPage({required this.schedule});

  @override
  State<VisionaryScheduleResultPage> createState() =>
      _VisionaryScheduleResultPageState();
}

class _VisionaryScheduleResultPageState
    extends State<VisionaryScheduleResultPage> {
  double _scale = 1.0;
  double _previousScale = 1.0;

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.schedule));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Schedule copied to clipboard!')),
    );
  }

  Future<void> _downloadAsTxt(BuildContext context) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/visionary_schedule.txt');
      await file.writeAsString(widget.schedule);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded to ${file.path}')),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to download file.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lines = widget.schedule
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF2E7FE),
      appBar: AppBar(
        title: const Text("🧠 Your Visionary Schedule"),
        backgroundColor: const Color(0xFFB388FF),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onScaleStart: (details) {
                  _previousScale = _scale;
                },
                onScaleUpdate: (details) {
                  setState(() {
                    _scale = (_previousScale * details.scale).clamp(0.8, 2.0);
                  });
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: lines.length,
                  itemBuilder: (context, index) {
                    final line = lines[index];
                    final match = RegExp(
                      r'^\s*(⏰|🕒|🕘|[\d:]+)\s*[-–]\s*(.+)$',
                    ).firstMatch(line);

                    final time = match?.group(1)?.trim() ?? '';
                    final task = match?.group(2)?.trim() ?? line;

                    return Transform.scale(
                      scale: _scale,
                      alignment: Alignment.topLeft,
                      child: TimelineTile(
                        alignment: TimelineAlign.start,
                        isFirst: index == 0,
                        isLast: index == lines.length - 1,
                        indicatorStyle: IndicatorStyle(
                          width: 16,
                          color: Colors.deepPurple,
                        ),
                        beforeLineStyle: const LineStyle(
                          color: Colors.deepPurple,
                          thickness: 2,
                        ),
                        endChild: Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(2, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "⏰ $time",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5 * _scale,
                                  fontFamilyFallback: [
                                    'Noto Color Emoji',
                                    'Apple Color Emoji',
                                    'Segoe UI Emoji',
                                    'Roboto'
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                task,
                                style: TextStyle(
                                  fontSize: 13.2 * _scale,
                                  fontFamilyFallback: [
                                    'Noto Color Emoji',
                                    'Apple Color Emoji',
                                    'Segoe UI Emoji',
                                    'Roboto'
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _copyToClipboard(context),
                      icon: const Icon(Icons.copy),
                      label: const Text("Copy"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _downloadAsTxt(context),
                      icon: const Icon(Icons.download),
                      label: const Text("Download"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

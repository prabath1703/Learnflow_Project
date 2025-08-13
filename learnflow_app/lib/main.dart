import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import 'visionary_schedule_input.dart';
import 'visionary_schedule_result.dart';
import 'visionary_landing_page.dart';
import 'summarizer_screen.dart'; // ✅ Added import

void main() {
  runApp(const LearnFlowApp());
}

class LearnFlowApp extends StatelessWidget {
  const LearnFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LearnFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LearnFlowHomePage(),
        '/visionary-landing': (context) => const FeatureSelectionPage(),
        '/visionary-input': (context) => const VisionaryScheduleInputPage(),
        '/visionary-result': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String;
          return VisionaryScheduleResultPage(schedule: args);
        },
        '/summarizer': (context) =>  SummarizerScreen(), // ✅ Added route
      },
    );
  }
}

class LearnFlowHomePage extends StatefulWidget {
  const LearnFlowHomePage({super.key});

  @override
  State<LearnFlowHomePage> createState() => _LearnFlowHomePageState();
}

class _LearnFlowHomePageState extends State<LearnFlowHomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(days: 1))
          ..repeat();
    _generateParticles();
  }

  void _generateParticles() {
    final random = Random();
    for (int i = 0; i < 100; i++) {
      _particles.add(
        Particle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          radius: random.nextDouble() * 2 + 1,
          dx: (random.nextDouble() - 0.5) * 0.002,
          dy: (random.nextDouble() - 0.5) * 0.002,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              _updateParticles();
              return CustomPaint(
                painter: ParticlePainter(particles: _particles),
                child: Container(),
              );
            },
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: isWide
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            flex: 1,
                            child: Bounce(
                              infinite: true,
                              child: Image.asset(
                                'assets/logo.png',
                                height: 300,
                              ),
                            ),
                          ),
                          const SizedBox(width: 40),
                          Flexible(
                            flex: 1,
                            child: _buildTextContent(context),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Bounce(
                            infinite: true,
                            child: Image.asset(
                              'assets/logo.png',
                              height: 220,
                            ),
                          ),
                          const SizedBox(height: 30),
                          _buildTextContent(context),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateParticles() {
    for (final p in _particles) {
      p.x += p.dx;
      p.y += p.dy;

      if (p.x < 0 || p.x > 1) p.dx = -p.dx;
      if (p.y < 0 || p.y > 1) p.dy = -p.dy;
    }
  }

  Widget _buildTextContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SlideInLeft(
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.lightBlue.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Hi, I’m Flow – your AI Tutor!",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        FadeInDown(
          child: Text(
            'LearnFlow',
            style: GoogleFonts.poppins(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.cyanAccent,
            ),
          ),
        ),
        const SizedBox(height: 10),
        AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              'Your intelligent learning companion',
              textStyle: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              speed: const Duration(milliseconds: 60),
            ),
          ],
          totalRepeatCount: 999,
          pause: const Duration(milliseconds: 1000),
          displayFullTextOnTap: true,
        ),
        const SizedBox(height: 30),
        BounceInUp(
          delay: const Duration(milliseconds: 600),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/visionary-landing');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Get Started',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class Particle {
  double x;
  double y;
  double radius;
  double dx;
  double dy;

  Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.dx,
    required this.dy,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.3);

    for (final p in particles) {
      final offset = Offset(p.x * size.width, p.y * size.height);
      canvas.drawCircle(offset, p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

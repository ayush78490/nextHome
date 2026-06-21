import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/next_home_logo.dart';

const String _pinSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <path fill="#4B81E1" d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z"/>
  <circle cx="12" cy="9" r="3.5" fill="#FFFFFF"/>
</svg>
''';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Simulate loading delay while animations play
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        context.go(AppRoutes.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF1F8), // Light blue background matching image
      body: Stack(
        children: [
          // Background map image simulation
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.network(
                'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=800&q=80',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildFallbackMapPattern(),
              ),
            ),
          ),
          
          // Animated Location Pins
          const AnimatedMapPins(),

          // Center Logo and text
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const NextHomeLogo(size: 140),
                const SizedBox(height: 16),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 34, 
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                    children: [
                      TextSpan(text: 'next ', style: TextStyle(color: Color(0xFF0F1B2B))),
                      TextSpan(text: 'home', style: TextStyle(color: Color(0xFF4B81E1))),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Find your next rental home',
                  style: TextStyle(
                    color: Color(0xFF4A5568),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackMapPattern() {
    // If the network image fails, show a faint grid as fallback map background
    return CustomPaint(
      painter: _MapGridPainter(),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4B81E1).withOpacity(0.2)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AnimatedMapPins extends StatefulWidget {
  const AnimatedMapPins({Key? key}) : super(key: key);

  @override
  State<AnimatedMapPins> createState() => _AnimatedMapPinsState();
}

class _AnimatedMapPinsState extends State<AnimatedMapPins> {
  final int _pinCount = 5;
  final Random _random = Random();
  late List<Offset> _pinPositions;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pinPositions = List.generate(_pinCount, (_) => _getRandomPosition());
    
    // Periodically randomly locate the pins to simulate "locating"
    _timer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (mounted) {
        setState(() {
          _pinPositions = List.generate(_pinCount, (_) => _getRandomPosition());
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Offset _getRandomPosition() {
    // We use normalized coordinates [0.0, 1.0] and convert to actual width/height in build
    double x = _random.nextDouble();
    double y = _random.nextDouble();
    
    // Avoid the center area where the logo is
    while (x > 0.15 && x < 0.85 && y > 0.3 && y < 0.7) {
      x = _random.nextDouble();
      y = _random.nextDouble();
    }
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: List.generate(_pinCount, (index) {
            final pos = _pinPositions[index];
            return AnimatedPositioned(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutCubic,
              left: pos.dx * (constraints.maxWidth - 40), // 40 is approx pin width
              top: pos.dy * (constraints.maxHeight - 40),
              child: _buildShadowedPin(),
            );
          }),
        );
      },
    );
  }

  Widget _buildShadowedPin() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Drop shadow for the pin
        Positioned(
          bottom: 2,
          child: Container(
            width: 14,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  spreadRadius: 2,
                )
              ],
            ),
          ),
        ),
        // The SVG Pin
        SvgPicture.string(
          _pinSvg,
          width: 44,
          height: 44,
        ),
      ],
    );
  }
}

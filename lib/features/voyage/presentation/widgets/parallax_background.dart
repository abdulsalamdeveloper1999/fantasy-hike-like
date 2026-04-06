import 'package:flutter/material.dart';
import 'voyage_landscape_painter.dart';

class ParallaxBackground extends StatefulWidget {
  final double progress;
  final bool isRunning;

  const ParallaxBackground({
    super.key,
    required this.progress,
    required this.isRunning,
  });

  @override
  State<ParallaxBackground> createState() => _ParallaxBackgroundState();
}

class _ParallaxBackgroundState extends State<ParallaxBackground>
    with TickerProviderStateMixin {
  late AnimationController _timeController;
  late AnimationController _speedController;
  late Animation<double> _speedAnimation;

  @override
  void initState() {
    super.initState();
    // Persistent time loop (the base cycle)
    _timeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Cruise ramp (handles starting/stopping slowly)
    _speedController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _speedAnimation = CurvedAnimation(
      parent: _speedController,
      curve: Curves.easeInOutCubic,
    );

    if (widget.isRunning) {
      _speedController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant ParallaxBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning != oldWidget.isRunning) {
      if (widget.isRunning) {
        _speedController.forward();
      } else {
        _speedController.reverse();
      }
    }
    
    if (!_timeController.isAnimating) {
      _timeController.repeat();
    }
  }

  @override
  void dispose() {
    _timeController.dispose();
    _speedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // ── 1. SKY (Static Foundation - Moodier/Darker) ──────────────────────────────────────
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF7A8D98), Color(0xFFAAB8C0)], // Deeper blue-grey
                stops: [0.0, 1.0],
              ),
            ),
          ),
        ),

        // ── 2. HORIZON GLOW (Softer Atmosphere) ───────────────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: height * 0.455 + 60,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, 0.95),
                  radius: 0.7,
                  colors: [
                    Colors.white.withValues(alpha: 0.25), // Reduced from 0.45
                    Colors.white.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
        ),

        // ── 3. CLOUDS ──────────────────────────────────────────────────────
        Positioned.fill(child: IgnorePointer(child: _drawSkyClouds(context))),

        // ── 4. THE LANDSCAPE (Combined Ocean + Mountains) ────────────────────
        Positioned.fill(
          child: AnimatedBuilder(
            animation: Listenable.merge([_timeController, _speedAnimation]),
            builder: (context, child) {
              return SizedBox.expand(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: VoyageLandscapePainter(
                    progress: widget.progress,
                    animationValue: _timeController.value,
                    sailingIntensity: _speedAnimation.value,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _drawSkyClouds(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        size: Size.infinite,
        painter: _SkyCloudsPainter(),
      ),
    );
  }
}

class _SkyCloudsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    double horizonY = size.height * 0.455;
    for (int i = 0; i < 4; i++) {
      double y = horizonY * (0.15 + (i * 0.18));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

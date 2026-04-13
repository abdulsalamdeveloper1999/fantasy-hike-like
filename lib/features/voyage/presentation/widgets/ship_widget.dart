import 'dart:math' as math;
import 'package:flutter/material.dart';

class ShipWidget extends StatefulWidget {
  final bool isRunning;
  final double progress;
  final VoidCallback? onTap;

  const ShipWidget({
    super.key,
    required this.isRunning,
    required this.progress,
    this.onTap,
  });

  @override
  State<ShipWidget> createState() => _ShipWidgetState();
}

class _ShipWidgetState extends State<ShipWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant ShipWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Perspective Math: Touch the horizon line exactly at 100% progress
        final scale = 1.0 - (widget.progress * 0.75);
        final yPerspectiveOffset = -320.0 * widget.progress;

        // Bobbing gets more subtle in the distance
        final bobbingOffset = (_controller.value * 12.0) * scale;
        final rotation = (math.sin(_controller.value * math.pi) * 0.02) * scale;

        return Stack(
          children: [
            // ── The perspective Ship (Sailing to the Horizon) ──
            Center(
              child: Transform.translate(
                offset: Offset(0, 200 + yPerspectiveOffset + bobbingOffset),
                child: Transform.scale(
                  scale: scale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      if (widget.isRunning) {
                        widget.onTap?.call();
                      }
                    },
                    child: Transform.rotate(
                      angle: rotation,
                      child: SizedBox(
                        width: 480,
                        height: 480,
                        child: Image.asset(
                          'assets/voyage/ship.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

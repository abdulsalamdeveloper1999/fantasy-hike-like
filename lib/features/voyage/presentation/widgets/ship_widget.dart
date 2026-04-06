import 'dart:math' as math;
import 'package:flutter/material.dart';

class ShipWidget extends StatefulWidget {
  final bool isRunning;
  final VoidCallback? onTap;

  const ShipWidget({
    super.key,
    required this.isRunning,
    this.onTap,
  });

  @override
  State<ShipWidget> createState() => _ShipWidgetState();
}

class _ShipWidgetState extends State<ShipWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
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
        final bobbingOffset = _controller.value * 8.0;
        final rotation = math.sin(_controller.value * math.pi) * 0.02;

        return Stack(
          children: [
            // ── The Interactable Ship ──
            Center(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (widget.isRunning) {
                    widget.onTap?.call();
                  }
                },
                child: Transform.translate(
                  offset: Offset(0, 100 + bobbingOffset),
                  child: Transform.rotate(
                    angle: rotation,
                    child: SizedBox(
                      width: 320,
                      height: 320,
                      child: Image.asset(
                        'assets/voyage/ship.png',
                        fit: BoxFit.contain,
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

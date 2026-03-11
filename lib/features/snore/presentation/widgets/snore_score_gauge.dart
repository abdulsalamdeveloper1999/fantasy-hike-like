import 'dart:math';
import 'package:flutter/material.dart';
import 'package:step_journey/features/snore/core/snore_colors.dart';

class SnoreScoreGauge extends StatelessWidget {
  final double score;
  final String label;
  final double size;

  const SnoreScoreGauge({
    super.key,
    required this.score,
    required this.label,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    // Determine color based on score: lower is better
    final scoreColor = score < 30
        ? SnoreColors.quiet
        : (score < 70 ? Colors.orangeAccent : Colors.redAccent);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _GaugePainter(score: score, activeColor: scoreColor),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${score.toInt()}',
                style: TextStyle(
                  color: scoreColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: scoreColor.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double score;
  final Color activeColor;

  _GaugePainter({required this.score, required this.activeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    final strokeWidth = size.width * 0.12;

    final basePaint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw background arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      pi * 0.75,
      pi * 1.5,
      false,
      basePaint,
    );

    // Draw score arc
    final scorePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (score / 100) * pi * 1.5;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      pi * 0.75,
      sweepAngle,
      false,
      scorePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

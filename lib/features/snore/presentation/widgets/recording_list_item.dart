import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:step_journey/features/snore/core/snore_colors.dart';
import 'package:step_journey/features/snore/domain/recording_model.dart';

class RecordingListItem extends StatelessWidget {
  final RecordingModel recording;
  final VoidCallback onPlay;
  final VoidCallback onDelete;
  final VoidCallback onFavorite;
  final Function(DateTime) onEditTime;
  final bool isPlaying;
  final double progress;

  const RecordingListItem({
    super.key,
    required this.recording,
    required this.onPlay,
    required this.onDelete,
    required this.onFavorite,
    required this.onEditTime,
    this.isPlaying = false,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F26),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Play Button
              GestureDetector(
                onTap: onPlay,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.stop : Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(recording.timestamp),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: SnoreColors.primary,
                                      onPrimary: Colors.white,
                                      surface: SnoreColors.surface,
                                      onSurface: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (time != null) {
                              final newDate = DateTime(
                                recording.timestamp.year,
                                recording.timestamp.month,
                                recording.timestamp.day,
                                time.hour,
                                time.minute,
                              );
                              onEditTime(newDate);
                            }
                          },
                          child: Text(
                            DateFormat('h:mm a').format(recording.timestamp),
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${recording.duration.inSeconds}s',
                          style: GoogleFonts.inter(
                            color: SnoreColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Loud',
                            style: GoogleFonts.inter(
                              color: Colors.redAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Favorite
              IconButton(
                icon: Icon(
                  recording.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: recording.isFavorite ? Colors.redAccent : SnoreColors.textSecondary,
                  size: 20,
                ),
                onPressed: onFavorite,
              ),
            ],
          ),
          
          // Waveform / Progress
          const SizedBox(height: 12),
          SizedBox(
            height: 20,
            child: CustomPaint(
              painter: _WaveformPainter(
                isPlaying: isPlaying,
                seed: recording.id.hashCode,
                progress: progress,
              ),
              size: const Size(double.infinity, 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final bool isPlaying;
  final int seed;
  final double progress;

  _WaveformPainter({
    required this.isPlaying,
    required this.seed,
    this.progress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isPlaying ? SnoreColors.primary : Colors.white24
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final random = Random(seed);
    final dashWidth = 3.0;
    final dashSpace = 2.0;
    double x = 0;

    while (x < size.width) {
      // Simulate unique waveform heights based on seed
      final height = (0.2 + (0.8 * random.nextDouble())) * size.height;
      final startY = (size.height - height) / 2;
      canvas.drawLine(Offset(x, startY), Offset(x, startY + height), paint);
      x += dashWidth + dashSpace;
    }

    if (isPlaying && progress > 0) {
      final progressX = size.width * progress;
      final progressPaint = Paint()
        ..color = SnoreColors.secondary
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(progressX, 0),
        Offset(progressX, size.height),
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) =>
      oldDelegate.isPlaying != isPlaying ||
      oldDelegate.seed != seed ||
      oldDelegate.progress != progress;
}

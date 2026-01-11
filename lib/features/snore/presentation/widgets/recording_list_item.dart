import 'dart:math';
import 'package:flutter/material.dart';
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              recording.isFavorite ? Icons.star : Icons.star_border,
              color: recording.isFavorite
                  ? SnoreColors.secondary
                  : SnoreColors.textSecondary,
            ),
            onPressed: onFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: SnoreColors.textSecondary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: SnoreColors.primary,
                              ),
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
                    '${DateFormat.jm().format(recording.timestamp)} (${recording.duration.inSeconds}s)',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
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
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: Icon(
              isPlaying ? Icons.stop : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: onPlay,
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_horiz,
              color: SnoreColors.textSecondary,
            ),
            color: SnoreColors.surface,
            onSelected: (value) {
              if (value == 'delete') onDelete();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
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

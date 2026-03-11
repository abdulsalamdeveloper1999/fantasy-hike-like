import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:auto_route/auto_route.dart';

import 'package:step_journey/features/snore/core/snore_colors.dart';
import 'package:step_journey/features/snore/presentation/state/snore_controller.dart';
import 'package:step_journey/features/snore/presentation/widgets/snore_score_gauge.dart';
import 'package:step_journey/features/snore/presentation/widgets/recording_list_item.dart';
import 'package:step_journey/features/snore/presentation/widgets/stat_card.dart';

@RoutePage()
class SnoreRecorderPage extends StatefulWidget {
  const SnoreRecorderPage({super.key});

  @override
  State<SnoreRecorderPage> createState() => _SnoreRecorderPageState();
}

class _SnoreRecorderPageState extends State<SnoreRecorderPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SnoreController(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F141A), // Darker background
        body: Consumer<SnoreController>(
          builder: (context, controller, child) {
            return SafeArea(
              child: CustomScrollView(
                slivers: [
                  // App Bar / Logo
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 8),
                      child: Center(
                        child: Image.asset(
                          'assets/snoreAI.png',
                          height: 48,
                          errorBuilder: (context, error, stackTrace) =>
                              const Text(
                                'Snore AI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                        ),
                      ),
                    ),
                  ),

                  // Header Row
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 3,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _showBedTimeEditDialog(
                                context,
                                controller,
                                isSessionStart: true,
                              ),
                              child: Text(
                                'Session at ${DateFormat('h:mm a').format(controller.sessionStartTime)}',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                              size: 24,
                            ),
                            onPressed: () {}, // Clear session logic
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Score Gauge
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: GestureDetector(
                          onTap: () =>
                              _showScoreEditDialog(context, controller),
                          child: SnoreScoreGauge(
                            score: controller.snoreScore,
                            label: controller.snoreScoreLabel,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Stats Row
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          StatCard(
                            title: 'Snore Ratio',
                            value: '${controller.snoreRatio.toInt()}%',
                            icon: Icons.trending_up,
                            onTap: () =>
                                _showRatioEditDialog(context, controller),
                          ),
                          StatCard(
                            title: 'Sleep Time',
                            value: _formatFullDuration(controller.sleepTime),
                            icon: Icons.dark_mode_outlined,
                            onTap: () =>
                                _showSleepTimeEditDialog(context, controller),
                          ),
                          StatCard(
                            title: 'Want to Bed',
                            value: DateFormat(
                              'h:mm a',
                            ).format(controller.wantToBed),
                            icon: Icons.bed_outlined,
                            onTap: () =>
                                _showBedTimeEditDialog(context, controller),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Factors Section
                  _buildSectionHeader(
                    'FACTORS',
                    () => _showFactorsEditDialog(context, controller),
                  ),
                  _buildChipList(controller.factors, 'None'),

                  // Sleep Aids Section
                  _buildSectionHeader(
                    'SLEEP AIDS',
                    () => _showSleepAidsEditDialog(context, controller),
                  ),
                  _buildChipList(controller.sleepAids, 'None'),

                  // Recordings Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 32, 20, 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.mic,
                            color: SnoreColors.textSecondary,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${controller.recordings.length} RECORDINGS',
                            style: GoogleFonts.inter(
                              color: SnoreColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Recordings List
                  _buildSliverRecordingsList(controller),

                  const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
                ],
              ),
            );
          },
        ),
        floatingActionButton: _buildFAB(),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 8),
        child: GestureDetector(
          onTap: onTap,
          child: Text(
            title,
            style: GoogleFonts.inter(
              color: SnoreColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChipList(List<String> items, String emptyLabel) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: items.isEmpty
            ? Text(
                emptyLabel,
                style: GoogleFonts.inter(color: Colors.white24, fontSize: 14),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items
                    .map(
                      (item) => Chip(
                        label: Text(
                          item,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: Colors.white.withOpacity(0.05),
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
      ),
    );
  }

  Widget _buildSliverRecordingsList(SnoreController controller) {
    if (controller.recordings.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Center(
            child: Text(
              'No recordings',
              style: TextStyle(color: Colors.white24),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final recording = controller.recordings[index];
        final isPlaying = controller.currentlyPlayingId == recording.id;
        double progress = 0.0;
        if (isPlaying && controller.currentDuration.inMilliseconds > 0) {
          progress =
              controller.currentPosition.inMilliseconds /
              controller.currentDuration.inMilliseconds;
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: RecordingListItem(
            recording: recording,
            isPlaying: isPlaying,
            progress: progress,
            onPlay: () => controller.playRecording(recording),
            onDelete: () => controller.deleteRecording(recording.id),
            onFavorite: () => controller.toggleFavorite(recording.id),
            onEditTime: (newTime) =>
                controller.updateTimestamp(recording.id, newTime),
          ),
        );
      }, childCount: controller.recordings.length),
    );
  }

  Widget _buildFAB() {
    return Consumer<SnoreController>(
      builder: (context, controller, child) {
        return FloatingActionButton(
          onPressed: () {
            if (controller.isRecording) {
              controller.stopRecording();
            } else {
              controller.startRecording();
            }
          },
          backgroundColor: controller.isRecording
              ? Colors.redAccent
              : SnoreColors.primary,
          child: Icon(controller.isRecording ? Icons.stop : Icons.mic),
        );
      },
    );
  }

  String _formatFullDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  void _showScoreEditDialog(BuildContext context, SnoreController controller) {
    double currentScore = controller.snoreScore;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1F26),
            title: const Text(
              'Edit Snore Score',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SnoreScoreGauge(
                  score: currentScore,
                  label: controller.snoreScoreLabel,
                  size: 100,
                ),
                Slider(
                  value: currentScore,
                  min: 0,
                  max: 100,
                  activeColor: SnoreColors.primary,
                  onChanged: (val) => setState(() => currentScore = val),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  controller.updateSnoreScore(currentScore);
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRatioEditDialog(BuildContext context, SnoreController controller) {
    double currentRatio = controller.snoreRatio;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1F26),
            title: const Text(
              'Edit Snore Ratio',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${currentRatio.toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Slider(
                  value: currentRatio,
                  min: 0,
                  max: 100,
                  activeColor: Colors.blueAccent,
                  onChanged: (val) => setState(() => currentRatio = val),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  controller.updateSnoreRatio(currentRatio);
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSleepTimeEditDialog(
    BuildContext context,
    SnoreController controller,
  ) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: controller.sleepTime.inHours,
        minute: controller.sleepTime.inMinutes.remainder(60),
      ),
      helpText: 'SELECT SLEEP DURATION',
    );
    if (time != null) {
      controller.updateSleepTime(
        Duration(hours: time.hour, minutes: time.minute),
      );
    }
  }

  void _showBedTimeEditDialog(
    BuildContext context,
    SnoreController controller, {
    bool isSessionStart = false,
  }) async {
    final DateTime initialDate = isSessionStart
        ? controller.sessionStartTime
        : controller.wantToBed;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
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
      final newTime = DateTime(
        initialDate.year,
        initialDate.month,
        initialDate.day,
        time.hour,
        time.minute,
      );
      if (isSessionStart) {
        controller.updateSessionStartTime(newTime);
      } else {
        controller.updateWantToBed(newTime);
      }
    }
  }

  void _showFactorsEditDialog(
    BuildContext context,
    SnoreController controller,
  ) {
    _showMultiSelectDialog(
      context,
      'FACTORS',
      ['Alcohol', 'Caffeine', 'Late Meal', 'Stress', 'Exercise', 'Tobacco'],
      controller.factors,
      (selected) => controller.setFactors(selected),
    );
  }

  void _showSleepAidsEditDialog(
    BuildContext context,
    SnoreController controller,
  ) {
    _showMultiSelectDialog(
      context,
      'SLEEP AIDS',
      [
        'Eye Mask',
        'Earplugs',
        'White Noise',
        'Humidifier',
        'Melatonin',
        'Mouth Tape',
      ],
      controller.sleepAids,
      (selected) => controller.setSleepAids(selected),
    );
  }

  void _showMultiSelectDialog(
    BuildContext context,
    String title,
    List<String> options,
    List<String> initialSelected,
    Function(List<String>) onSave,
  ) {
    List<String> selected = List.from(initialSelected);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1F26),
            title: Text(title, style: const TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                children: options.map((option) {
                  final isSelected = selected.contains(option);
                  return FilterChip(
                    label: Text(option),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          selected.add(option);
                        } else {
                          selected.remove(option);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  onSave(selected);
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Removed unused methods: _showAddRecordingDialog, _showSleepNoteDialog
}

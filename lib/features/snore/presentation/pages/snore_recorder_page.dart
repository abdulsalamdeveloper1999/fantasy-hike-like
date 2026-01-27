import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:step_journey/features/snore/core/snore_colors.dart';
import 'package:step_journey/features/snore/domain/recording_model.dart';
import 'package:step_journey/features/snore/presentation/state/snore_controller.dart';
import 'package:step_journey/features/snore/presentation/widgets/snore_score_gauge.dart';
import 'package:step_journey/features/snore/presentation/widgets/summary_card.dart';
import 'package:step_journey/features/snore/presentation/widgets/recording_list_item.dart';

class SnoreRecorderPage extends StatefulWidget {
  const SnoreRecorderPage({super.key});

  @override
  State<SnoreRecorderPage> createState() => _SnoreRecorderPageState();
}

class _SnoreRecorderPageState extends State<SnoreRecorderPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SnoreController(),
      child: Scaffold(
        backgroundColor: SnoreColors.background,
        drawer: const Drawer(),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            DateFormat('EEEE, MMM d').format(DateTime.now()),
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: SnoreColors.primary,
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: Consumer<SnoreController>(
          builder: (context, controller, child) {
            return Column(
              children: [
                const SizedBox(height: 20),
                _buildHeader(controller),
                const SizedBox(height: 30),
                _buildTabs(),
                Expanded(child: _buildRecordingsList(controller)),
              ],
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Consumer<SnoreController>(
          builder: (context, controller, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!controller.isRecording && controller.recordings.isEmpty)
                  const Text(
                    'Tap to start recording',
                    style: TextStyle(
                      color: SnoreColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    if (controller.isRecording) {
                      controller.stopRecording();
                    } else {
                      controller.startRecording();
                    }
                  },
                  child: ScaleTransition(
                    scale: controller.isRecording
                        ? _pulseAnimation
                        : const AlwaysStoppedAnimation(1.0),
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: controller.isRecording
                            ? Colors.redAccent
                            : SnoreColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                (controller.isRecording
                                        ? Colors.redAccent
                                        : SnoreColors.primary)
                                    .withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        controller.isRecording ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ),
                if (controller.isRecording)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'Recording...',
                      style: GoogleFonts.inter(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(SnoreController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _showScoreEditDialog(context, controller),
                child: SnoreScoreGauge(score: controller.snoreScore),
              ),
              const SizedBox(width: 40),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SummaryCard(
                      title: 'Active Time',
                      value: _formatDuration(controller.totalActiveDuration),
                      icon: Icons.mic_none,
                    ),
                    SummaryCard(
                      title: 'Time Snoring',
                      value: _formatDuration(controller.totalSnoreDuration),
                      subValue:
                          '| ${controller.totalActiveDuration.inSeconds > 0 ? (controller.totalSnoreDuration.inSeconds * 100 ~/ controller.totalActiveDuration.inSeconds) : 0}%',
                      icon: Icons.graphic_eq,
                    ),
                    const SummaryCard(
                      title: 'BreathFlow',
                      value: 'Upgrade',
                      icon: Icons.air,
                      isLocked: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _showSleepNoteDialog(context, controller),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        controller.sleepNote.isEmpty
                            ? 'Sleep Notes'
                            : 'Edit Note',
                        style: const TextStyle(
                          color: SnoreColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.add_circle_outline,
                        color: SnoreColors.primary,
                        size: 20,
                      ),
                    ],
                  ),
                  if (controller.sleepNote.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        controller.sleepNote,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildTabItem('Quiet', SnoreColors.quiet),
          _buildTabItem('Light', SnoreColors.light),
          _buildTabItem('Loud', SnoreColors.loud),
          _buildTabItem('Epic', SnoreColors.epic),
          _buildTabItem('Noise', SnoreColors.noise),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: color, width: 2)),
      ),
      child: Text(
        label,
        style: TextStyle(color: SnoreColors.textSecondary, fontSize: 13),
      ),
    );
  }

  Widget _buildRecordingsList(SnoreController controller) {
    if (controller.recordings.isEmpty) {
      return Column(
        children: [
          _buildRecordingsHeader(context, controller),
          const SizedBox(height: 50),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.nightlight_round, color: Colors.white12, size: 80),
                const SizedBox(height: 16),
                Text(
                  'No recordings yet',
                  style: TextStyle(color: SnoreColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final grouped = _groupRecordingsByDate(controller.recordings);

    return Column(
      children: [
        _buildRecordingsHeader(context, controller),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 150),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final date = grouped.keys.elementAt(index);
              final dateRecordings = grouped[date]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Text(
                      DateFormat(
                        'EEEE, MMMM d, yyyy',
                      ).format(date).toUpperCase(),
                      style: const TextStyle(
                        color: SnoreColors.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  ...dateRecordings.map((recording) {
                    final isPlaying =
                        controller.currentlyPlayingId == recording.id;
                    double progress = 0.0;
                    if (isPlaying &&
                        controller.currentDuration.inMilliseconds > 0) {
                      progress =
                          controller.currentPosition.inMilliseconds /
                          controller.currentDuration.inMilliseconds;
                    }
                    return RecordingListItem(
                      recording: recording,
                      isPlaying: isPlaying,
                      progress: progress,
                      onPlay: () => controller.playRecording(recording),
                      onDelete: () => controller.deleteRecording(recording.id),
                      onFavorite: () => controller.toggleFavorite(recording.id),
                      onEditTime: (newTime) =>
                          controller.updateTimestamp(recording.id, newTime),
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingsHeader(
    BuildContext context,
    SnoreController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'RECORDINGS (${controller.recordings.length})',
            style: const TextStyle(
              color: SnoreColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: SnoreColors.primary),
            onPressed: () => _showAddRecordingDialog(context, controller),
            tooltip: 'Add Manual Recording',
          ),
        ],
      ),
    );
  }

  Map<DateTime, List<RecordingModel>> _groupRecordingsByDate(
    List<RecordingModel> recordings,
  ) {
    final Map<DateTime, List<RecordingModel>> grouped = {};
    for (var r in recordings) {
      final date = DateTime(
        r.timestamp.year,
        r.timestamp.month,
        r.timestamp.day,
      );
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(r);
    }
    return grouped;
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes >= 1) {
      return '${duration.inMinutes}m';
    }
    return '${duration.inSeconds}s';
  }

  void _showScoreEditDialog(BuildContext context, SnoreController controller) {
    double currentScore = controller.snoreScore;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: SnoreColors.surface,
            title: const Text(
              'Edit SnoreScore',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentScore.round().toString(),
                  style: const TextStyle(
                    color: SnoreColors.primary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
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
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: SnoreColors.primary,
                ),
                onPressed: () {
                  controller.updateSnoreScore(currentScore);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddRecordingDialog(
    BuildContext context,
    SnoreController controller,
  ) async {
    TimeOfDay selectedTime = TimeOfDay.now();
    int durationSeconds = 30;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: SnoreColors.surface,
            title: const Text(
              'Add Recording',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text(
                    'Time',
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: Text(
                    selectedTime.format(context),
                    style: const TextStyle(
                      color: SnoreColors.primary,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
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
                    if (t != null) setState(() => selectedTime = t);
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Duration (seconds)',
                  style: TextStyle(color: Colors.white70),
                ),
                Slider(
                  value: durationSeconds.toDouble(),
                  min: 5,
                  max: 120,
                  divisions: 23,
                  label: '$durationSeconds s',
                  activeColor: SnoreColors.primary,
                  onChanged: (val) =>
                      setState(() => durationSeconds = val.toInt()),
                ),
                Text(
                  '$durationSeconds seconds',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: SnoreColors.primary,
                ),
                onPressed: () {
                  final now = DateTime.now();
                  final timestamp = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );
                  controller.addManualRecording(
                    timestamp,
                    Duration(seconds: durationSeconds),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Add', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSleepNoteDialog(BuildContext context, SnoreController controller) {
    final textController = TextEditingController(text: controller.sleepNote);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SnoreColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: SnoreColors.primary, width: 1.5),
        ),
        title: const Text('Sleep Notes', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'How did you sleep?',
            hintStyle: TextStyle(color: Colors.white30),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: SnoreColors.primary),
            ),
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SnoreColors.primary,
            ),
            onPressed: () {
              controller.updateSleepNote(textController.text);
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

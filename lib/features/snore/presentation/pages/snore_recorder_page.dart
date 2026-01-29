import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:step_journey/core/widgets/app_drawer.dart';
import 'package:step_journey/features/snore/core/snore_colors.dart';
import 'package:step_journey/features/snore/domain/recording_model.dart';
import 'package:step_journey/features/snore/presentation/state/snore_controller.dart';
import 'package:step_journey/features/snore/presentation/widgets/snore_score_gauge.dart';
import 'package:step_journey/features/snore/presentation/widgets/recording_list_item.dart';

@RoutePage()
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
        drawer: const AppDrawer(),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Snore AI',
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
            // Show error message if present
            if (controller.errorMessage != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(controller.errorMessage!),
                    backgroundColor: Colors.redAccent,
                    duration: const Duration(seconds: 4),
                    action: SnackBarAction(
                      label: 'Dismiss',
                      textColor: Colors.white,
                      onPressed: () => controller.clearError(),
                    ),
                  ),
                );
                controller.clearError();
              });
            }

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
      child: Center(child: SnoreScoreGauge(score: controller.snoreScore)),
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
          _buildTabItem('WTF', SnoreColors.epic),
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
      return Center(
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
      );
    }

    final grouped = _groupRecordingsByDate(controller.recordings);

    return ListView.builder(
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
                DateFormat('EEEE, MMMM d, yyyy').format(date).toUpperCase(),
                style: const TextStyle(
                  color: SnoreColors.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            ...dateRecordings.map((recording) {
              final isPlaying = controller.currentlyPlayingId == recording.id;
              double progress = 0.0;
              if (isPlaying && controller.currentDuration.inMilliseconds > 0) {
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
}

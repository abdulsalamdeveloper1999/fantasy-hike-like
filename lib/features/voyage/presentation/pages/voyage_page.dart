import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:step_journey/features/voyage/presentation/cubit/voyage_cubit.dart';
import 'package:step_journey/features/voyage/presentation/cubit/voyage_state.dart';
import 'package:step_journey/features/voyage/presentation/widgets/parallax_background.dart';
import 'package:step_journey/features/voyage/presentation/widgets/ship_widget.dart';
import 'package:step_journey/features/voyage/presentation/widgets/timer_overlay.dart';
import 'package:step_journey/features/voyage/presentation/widgets/slide_to_focus_button.dart';

class VoyagePage extends StatelessWidget {
  const VoyagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VoyageCubit(),
      child: const VoyageView(),
    );
  }
}

class VoyageView extends StatelessWidget {
  const VoyageView({super.key});

  void _showStopConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (innerContext) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: const Color(0xFF2E3135).withValues(alpha: 0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Abandon Voyage?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Your current focus progress will be lost. Are you sure you want to return to port?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(innerContext),
              child: const Text(
                'Continue Sailing',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(innerContext);
                context.read<VoyageCubit>().resetVoyage();
              },
              child: const Text(
                'Stop Voyage',
                style: TextStyle(
                  color: Color(0xFFFF5252),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121B22),
      body: BlocBuilder<VoyageCubit, VoyageState>(
        builder: (context, state) {
          final isStarted = state.status == VoyageStatus.running;

          return Stack(
            children: [
              // 1. Parallax Layers
              ParallaxBackground(
                progress: state.progress,
                isRunning: isStarted,
              ),

              // 2. The Ship (Now Interacted)
              ShipWidget(
                isRunning: isStarted,
                onTap: () => _showStopConfirmation(context),
              ),

              // 3. UI Overlays (Timer, Goal)
              const TimerOverlay(),

              // 4. Slide Button (Bottom)
              Positioned(
                left: 24,
                right: 24,
                bottom: 60,
                child: SlideToFocusButton(
                  isStarted: isStarted,
                  onSlideComplete: () {
                    context.read<VoyageCubit>().startVoyage();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

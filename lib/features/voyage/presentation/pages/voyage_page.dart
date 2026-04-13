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


              // 4. The Ship (Perspective Driven)
              ShipWidget(
                isRunning: isStarted,
                progress: state.progress,
                onTap: () => _showStopConfirmation(context),
              ),

              // 5. UI Overlays (Timer, Goal)
              const TimerOverlay(),

              // 6. Slide Button (Bottom) - RESTORED
              if (state.status == VoyageStatus.initial)
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 60,
                  child: SlideToFocusButton(
                    isStarted: false,
                    onSlideComplete: () {
                      context.read<VoyageCubit>().startVoyage();
                    },
                  ),
                ),

              // 7. Countdown Timer (TOP LAYER)
              if (state.status == VoyageStatus.countingDown)
                Positioned(
                  top:
                      350, // Slightly lower to not overlap too much with the top card
                  left: 0,
                  right: 0,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                    child: Text(
                      '${state.countdownValue}',
                      key: ValueKey('countdown_${state.countdownValue}'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 60, // Decreased as requested
                        fontWeight: FontWeight.w100,
                        letterSpacing: -4,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 30,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

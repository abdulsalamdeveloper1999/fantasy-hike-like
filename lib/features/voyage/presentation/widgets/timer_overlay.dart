import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:step_journey/features/voyage/presentation/cubit/voyage_cubit.dart';
import 'package:step_journey/features/voyage/presentation/cubit/voyage_state.dart';

class TimerOverlay extends StatelessWidget {
  const TimerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VoyageCubit, VoyageState>(
      builder: (context, state) {
        final remaining = state.remainingDuration;
        final minutes = remaining.inMinutes.toString().padLeft(2, '0');
        final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
          child: Column(
            children: [
              // Premium Focus Card (Glassmorphism Look)
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      left: 28,
                      right: 28,
                      top: 16,
                      bottom: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E3135).withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 50,
                          spreadRadius: -15,
                          offset: const Offset(0, 30),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 1. Centered Clock at Top (User size 32)
                        Text(
                          '$minutes:$seconds',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w200,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // 2. Goal Metadata Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'GOAL',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 10,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Text(
                                    state.voyage.goalTitle,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Distance Indicator
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '${state.elapsedDistanceKm.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    const Text(
                                      'KM',
                                      style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // 3. Bottom Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: state.progress,
                            backgroundColor: Colors.white.withOpacity(0.08),
                            color: Colors.white70,
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

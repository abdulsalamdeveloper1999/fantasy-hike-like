import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:step_journey/features/voyage/presentation/cubit/voyage_cubit.dart';
import 'package:step_journey/features/voyage/presentation/cubit/voyage_state.dart';

class TimerOverlay extends StatefulWidget {
  const TimerOverlay({super.key});

  @override
  State<TimerOverlay> createState() => _TimerOverlayState();
}

class _TimerOverlayState extends State<TimerOverlay> {
  double _dragOffset = 0.0;
  final double _swipeThreshold = 150.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VoyageCubit, VoyageState>(
      builder: (context, state) {
        final remaining = state.remainingDuration;
        final minutes = remaining.inMinutes.toString().padLeft(2, '0');
        final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
        final isRunning = state.status == VoyageStatus.running;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
          child: Column(
            children: [
              GestureDetector(
                onHorizontalDragUpdate: (details) {
                  if (isRunning) return;
                  setState(() {
                    _dragOffset += details.delta.dx;
                    if (_dragOffset < 0) _dragOffset = 0;
                    if (_dragOffset > _swipeThreshold)
                      _dragOffset = _swipeThreshold;
                  });
                },
                onHorizontalDragEnd: (details) {
                  if (isRunning) return;
                  if (_dragOffset >= _swipeThreshold) {
                    context.read<VoyageCubit>().startVoyage();
                  }
                  setState(() {
                    _dragOffset = 0;
                  });
                },
                child: Transform.translate(
                  offset: Offset(_dragOffset, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          left: 28,
                          right: 28,
                          top: 20,
                          bottom: 20,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E3135).withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withValues(
                              alpha:
                                  (_dragOffset / _swipeThreshold * 0.3) + 0.12,
                            ),
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
                            // 1. Centered Clock at Top
                            Text(
                              '$minutes:$seconds',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 48, // Increased size for premium look
                                fontWeight: FontWeight.w400,
                                letterSpacing: -2,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 2. Goal Metadata Section
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'GOAL',
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 11,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        state.voyage.goalTitle,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    // Distance Indicator
                                    Opacity(
                                      opacity: state.status != VoyageStatus.initial ? 1.0 : 0.0,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text(
                                            '${state.elapsedDistanceKm.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text(
                                            'KM',
                                            style: TextStyle(
                                              color: Colors.white38,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // 3. Bottom Progress Bar
                            Stack(
                              children: [
                                Container(
                                  height: 4,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: 4,
                                  width:
                                      (MediaQuery.of(context).size.width -
                                          104) *
                                      state.progress,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.4),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            if (!isRunning && _dragOffset < 20)
                              Padding(
                                padding: EdgeInsets.only(top: 12.0),
                                child: Text(
                                  'Slide to Start →',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.3),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
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

import 'package:flutter/material.dart';

class SlideToFocusButton extends StatefulWidget {
  final VoidCallback onSlideComplete;
  final bool isStarted;

  const SlideToFocusButton({
    super.key,
    required this.onSlideComplete,
    required this.isStarted,
  });

  @override
  State<SlideToFocusButton> createState() => _SlideToFocusButtonState();
}

class _SlideToFocusButtonState extends State<SlideToFocusButton> {
  double _dragValue = 0.0;
  final double _buttonHeight = 64.0;

  @override
  void didUpdateWidget(covariant SlideToFocusButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset position if the voyage state changes back to initial/stopped
    if (!widget.isStarted && oldWidget.isStarted) {
      setState(() {
        _dragValue = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isStarted) {
      return const SizedBox.shrink(); // Hide after start
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final maxDrag = totalWidth - _buttonHeight;

        return Container(
          width: totalWidth,
          height: _buttonHeight,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white12),
          ),
          child: Stack(
            children: [
              const Center(
                child: Text(
                  'Slide to Focus',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Positioned(
                left: _dragValue * maxDrag,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _dragValue += details.delta.dx / maxDrag;
                      _dragValue = _dragValue.clamp(0.0, 1.0);
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_dragValue > 0.8) {
                      setState(() {
                        _dragValue = 1.0;
                      });
                      widget.onSlideComplete();
                    } else {
                      setState(() {
                        _dragValue = 0.0;
                      });
                    }
                  },
                  child: Container(
                    width: _buttonHeight - 4,
                    height: _buttonHeight - 4,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.black,
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

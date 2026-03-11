import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_journey/features/snore/core/snore_colors.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F26), // Darker surface
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.blueAccent, size: 20),
              const SizedBox(height: 8),
              Text(
                value,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: GoogleFonts.inter(
                  color: SnoreColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

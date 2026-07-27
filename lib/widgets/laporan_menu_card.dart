import 'package:flutter/material.dart';

/// A reusable menu card for the Laporan screen.
/// Displays a colored icon box, title, subtitle, and a trailing chevron.
class LaporanMenuCard extends StatelessWidget {
  final Color iconColor;
  final Color iconBackgroundColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const LaporanMenuCard({
    super.key,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: const Color(0xFFEAECF2),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon box
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E1E1E),
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF9E9E9E),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            // Trailing chevron
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFBDBDBD),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

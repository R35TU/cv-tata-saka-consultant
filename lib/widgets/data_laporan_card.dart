import 'package:flutter/material.dart';

/// Compact project card for the Data Laporan screen.
/// Shows title, location, status badge, and dual progress bars (no image).
class DataLaporanCard extends StatelessWidget {
  final String title;
  final String location;
  final String status; // "Progres" or "Selesai"
  final double physicalProgress; // 0.0 – 1.0  → green bar
  final double financialProgress; // 0.0 – 1.0  → blue bar
  final VoidCallback? onTap;

  const DataLaporanCard({
    super.key,
    required this.title,
    required this.location,
    required this.status,
    required this.physicalProgress,
    required this.financialProgress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = status.toLowerCase() == 'selesai';

    final Color badgeDotColor =
        isCompleted ? const Color(0xFF001AFF) : const Color(0xFF00C853);
    final Color badgeBgColor =
        isCompleted ? const Color(0xFFE5EAFF) : const Color(0xFFE8F9EE);
    final Color badgeTextColor = badgeDotColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: const Color(0xFFEAECF2), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left: title, location, status badge ──────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                      fontFamily: 'Inter',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    location,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFA0A0A0),
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: badgeBgColor,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: badgeDotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: badgeTextColor,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ── Right: dual progress bars ─────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildProgressBar(
                  label: '${(physicalProgress * 100).toInt()}%',
                  value: physicalProgress,
                  barColor: const Color(0xFF00C853),
                ),
                const SizedBox(height: 10),
                _buildProgressBar(
                  label: '${(financialProgress * 100).toInt()}%',
                  value: financialProgress,
                  barColor: const Color(0xFF001AFF),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar({
    required String label,
    required double value,
    required Color barColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E1E1E),
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 110,
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

/// A single entry in a project chronology timeline.
///
/// Displays a blue dot with a connecting vertical line on the left, and
/// the activity date/time, description, and actor on the right.
class TimelineItem extends StatelessWidget {
  final String date;        // e.g. "1 Januari 2025"
  final String time;        // e.g. "14:30"
  final String description; // bold activity text
  final String actor;       // e.g. "CV. Tata Saka (Konsultan)"
  final bool isLast;        // hides the connector line below the last dot

  const TimelineItem({
    super.key,
    required this.date,
    required this.time,
    required this.description,
    required this.actor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left: dot + vertical line ──────────────────────────────────
          SizedBox(
            width: 32,
            child: Column(
              children: [
                // Blue circle dot
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF001AFF),
                    border: Border.all(
                      color: const Color(0xFFB3C0FF),
                      width: 3,
                    ),
                  ),
                ),
                // Connector line (stretch to fill remaining height)
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: const Color(0xFFDDE1F0),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ── Right: text content ─────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date + time
                  Text(
                    '$date   $time',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9E9E9E),
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Activity description
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E1E1E),
                      fontFamily: 'Inter',
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Actor
                  Text(
                    actor,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9E9E9E),
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Inter',
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
}

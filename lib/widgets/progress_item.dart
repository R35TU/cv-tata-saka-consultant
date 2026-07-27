import 'package:flutter/material.dart';
import '../screens/detail_proyek_screen.dart';

class ProgressItem extends StatelessWidget {
  final String title;
  final double progress; // Value between 0.0 and 1.0
  final Color progressColor;

  const ProgressItem({
    super.key,
    required this.title,
    required this.progress,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DetailProyekScreen(
              title: title,
              location: 'Purwokerto Selatan',
              status: 'Progres',
              imageUrl: 'https://images.unsplash.com/photo-1545628221-bb35ab299e58?q=80&w=600&auto=format&fit=crop',
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Project Title
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6E6E6E),
                  fontFamily: 'Inter',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 16),
            // Progress Bar
            SizedBox(
              width: 100,
              height: 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../features/projects/presentation/project_detail_screen.dart';

class ProgressItem extends StatelessWidget {
  final String title;
  final double progress; // Value between 0.0 and 1.0
  final Color progressColor;
  final String? projectId;

  const ProgressItem({
    super.key,
    required this.title,
    required this.progress,
    required this.progressColor,
    this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (projectId != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ContractDetailScreen(
                contractId: projectId!,
              ),
            ),
          );
        }
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

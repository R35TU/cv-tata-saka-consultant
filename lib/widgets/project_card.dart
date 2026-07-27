import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProjectCard extends StatelessWidget {
  final String projectId;
  final String title;
  final String location;
  final String status; // "Progres" or "Selesai"
  final double physicalProgress; // 0.0 to 1.0 (Green bar)
  final double financialProgress; // 0.0 to 1.0 (Blue bar)
  final String imageUrl;

  const ProjectCard({
    super.key,
    this.projectId = '',
    required this.title,
    required this.location,
    required this.status,
    required this.physicalProgress,
    required this.financialProgress,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = status.toLowerCase() == 'selesai';
    
    // Status color mapping
    final Color badgeDotColor = isCompleted ? const Color(0xFF001AFF) : const Color(0xFF00C853);
    final Color badgeBgColor = isCompleted ? const Color(0xFFE5EAFF) : const Color(0xFFE8F9EE);
    final Color badgeTextColor = isCompleted ? const Color(0xFF001AFF) : const Color(0xFF00C853);

    return GestureDetector(
      onTap: () {
        context.push('/projects/$projectId');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: const Color(0xFFF0F1F5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x04000000), // Very subtle shadow
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14.5),
                topRight: Radius.circular(14.5),
              ),
              child: _buildImage(imageUrl),
            ),
            
            // Project Details
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left Column: Title, Location, Status Badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E1E),
                            fontFamily: 'Inter',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
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
                        
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
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
                  
                  // Right Column: Dual Progress Indicators
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Physical Progress Bar (Green)
                      _buildProgressBarBlock(
                        percentageLabel: '${(physicalProgress * 100).toInt()}%',
                        progressValue: physicalProgress,
                        barColor: const Color(0xFF00C853),
                      ),
                      const SizedBox(height: 12),
                      // Financial Progress Bar (Blue)
                      _buildProgressBarBlock(
                        percentageLabel: '${(financialProgress * 100).toInt()}%',
                        progressValue: financialProgress,
                        barColor: const Color(0xFF001AFF),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBarBlock({
    required String percentageLabel,
    required double progressValue,
    required Color barColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Percentage Label above bar
        Text(
          percentageLabel,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E1E1E),
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 4),
        // Progress Bar track
        SizedBox(
          width: 100,
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage(String url) {
    const double h = 135;
    final placeholder = Container(
      height: h,
      color: const Color(0xFFE5E7EB),
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 32),
    );

    if (url.isEmpty) return placeholder;

    // Local file path (from image_picker)
    if (url.startsWith('/') || url.startsWith('file://')) {
      return Image.file(
        File(url.replaceFirst('file://', '')),
        height: h,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }

    // Network URL
    return Image.network(
      url,
      height: h,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }
}

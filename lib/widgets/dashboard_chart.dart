import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../features/projects/data/models/project_model.dart';
import '../core/enums/app_role.dart';

class DashboardChart extends StatelessWidget {
  final List<ProjectModel>? projects;
  final AppRole? userRole;

  const DashboardChart({
    super.key,
    this.projects,
    this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    // If parameters are null, fallback to the original static layout (backwards compatibility)
    final resolvedProjects = projects;
    final resolvedRole = userRole;

    if (resolvedProjects == null || resolvedRole == null) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: const Color(0xFFF0F1F5),
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progres Proyek',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E1E1E),
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // Donut Chart
                Expanded(
                  flex: 5,
                  child: SizedBox(
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: StaticDonutChartPainter(),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              '67%',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E1E1E),
                                fontFamily: 'Inter',
                              ),
                            ),
                            Text(
                              'Rata-rata Progres',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF757575),
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(
                        color: const Color(0xFF0055FF),
                        label: 'Selesai',
                        value: '(37,5%)',
                      ),
                      const SizedBox(height: 12),
                      _buildLegendItem(
                        color: const Color(0xFFAFD0FF),
                        label: 'Proses',
                        value: '(25,0%)',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (resolvedProjects.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0F1F5), width: 1.5),
        ),
        child: const Center(
          child: Text(
            'Belum ada data progres proyek',
            style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.grey),
          ),
        ),
      );
    }

    if (resolvedRole == AppRole.dinas) {
      final avgPhysical = resolvedProjects.map((p) => p.physicalProgress).reduce((a, b) => a + b) / resolvedProjects.length;
      final avgSupervision = resolvedProjects.map((p) => p.financialProgress).reduce((a, b) => a + b) / resolvedProjects.length;

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: const Color(0xFFF0F1F5), width: 1.5),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progres Proyek (Monitoring Dinas)',
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Color(0xFF1E1E1E), fontFamily: 'Inter'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildSingleCircularChart(
                    title: 'Rata-rata Fisik',
                    progress: avgPhysical,
                    color: const Color(0xFF00C853),
                    label: 'Fisik',
                  ),
                ),
                Container(width: 1.5, height: 120, color: const Color(0xFFF0F1F5)),
                Expanded(
                  child: _buildSingleCircularChart(
                    title: 'Rata-rata Pengawasan',
                    progress: avgSupervision,
                    color: const Color(0xFF0055FF),
                    label: 'Pengawasan',
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final isSupervision = resolvedRole == AppRole.konsultan;
    final progressList = resolvedProjects.map((p) => isSupervision ? p.financialProgress : p.physicalProgress).toList();
    final avgProgress = progressList.reduce((a, b) => a + b) / resolvedProjects.length;

    final selesaiCount = resolvedProjects.where((p) => (isSupervision ? p.financialProgress : p.physicalProgress) >= 1.0).length;
    final prosesCount = resolvedProjects.length - selesaiCount;

    final selesaiPercent = (selesaiCount / resolvedProjects.length) * 100.0;
    final prosesPercent = (prosesCount / resolvedProjects.length) * 100.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFF0F1F5), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isSupervision ? 'Progres Pengawasan Proyek' : 'Progres Fisik Proyek',
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E1E1E),
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: DonutChartPainter(
                            selesaiRatio: selesaiCount / resolvedProjects.length,
                            prosesRatio: prosesCount / resolvedProjects.length,
                            colorSelesai: isSupervision ? const Color(0xFF0055FF) : const Color(0xFF00C853),
                            colorProses: isSupervision ? const Color(0xFFAFD0FF) : const Color(0xFFA8E6CF),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(avgProgress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E1E1E),
                              fontFamily: 'Inter',
                            ),
                          ),
                          const Text(
                            'Rata-rata Progres',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF757575),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem(
                      color: isSupervision ? const Color(0xFF0055FF) : const Color(0xFF00C853),
                      label: 'Selesai',
                      value: '(${selesaiPercent.toStringAsFixed(1)}%)',
                    ),
                    const SizedBox(height: 12),
                    _buildLegendItem(
                      color: isSupervision ? const Color(0xFFAFD0FF) : const Color(0xFFA8E6CF),
                      label: 'Proses',
                      value: '(${prosesPercent.toStringAsFixed(1)}%)',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSingleCircularChart({
    required String title,
    required double progress,
    required Color color,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF757575), fontFamily: 'Inter'),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 90,
          width: 90,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 90,
                width: 90,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 9,
                  color: color,
                  backgroundColor: color.withOpacity(0.12),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E1E1E), fontFamily: 'Inter'),
                  ),
                  Text(
                    label,
                    style: const TextStyle(fontSize: 8, color: Color(0xFF757575), fontFamily: 'Inter'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF555555),
              fontFamily: 'Inter',
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF757575),
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}

class StaticDonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = math.min(size.width, size.height) / 2 - 12;

    final rect = Rect.fromCircle(center: Offset(centerX, centerY), radius: radius);

    final bgPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18.0
      ..strokeCap = StrokeCap.round;

    final selesaiPaint = Paint()
      ..color = const Color(0xFF0055FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18.0
      ..strokeCap = StrokeCap.round;

    final prosesPaint = Paint()
      ..color = const Color(0xFFAFD0FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18.0
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(centerX, centerY), radius, bgPaint);

    const double startAngle = -math.pi / 2;
    const double selesaiSweep = 0.42 * 2 * math.pi;
    canvas.drawArc(rect, startAngle, selesaiSweep, false, selesaiPaint);

    const double prosesSweep = 0.25 * 2 * math.pi;
    canvas.drawArc(rect, startAngle + selesaiSweep, prosesSweep, false, prosesPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DonutChartPainter extends CustomPainter {
  final double selesaiRatio;
  final double prosesRatio;
  final Color colorSelesai;
  final Color colorProses;

  DonutChartPainter({
    required this.selesaiRatio,
    required this.prosesRatio,
    required this.colorSelesai,
    required this.colorProses,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = math.min(size.width, size.height) / 2 - 12;

    final rect = Rect.fromCircle(center: Offset(centerX, centerY), radius: radius);

    final bgPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18.0
      ..strokeCap = StrokeCap.round;

    final selesaiPaint = Paint()
      ..color = colorSelesai
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18.0
      ..strokeCap = StrokeCap.round;

    final prosesPaint = Paint()
      ..color = colorProses
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18.0
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(centerX, centerY), radius, bgPaint);

    const double startAngle = -math.pi / 2;

    if (selesaiRatio > 0) {
      final double selesaiSweep = selesaiRatio * 2 * math.pi;
      canvas.drawArc(rect, startAngle, selesaiSweep, false, selesaiPaint);
      
      if (prosesRatio > 0) {
        final double prosesSweep = prosesRatio * 2 * math.pi;
        canvas.drawArc(rect, startAngle + selesaiSweep, prosesSweep, false, prosesPaint);
      }
    } else if (prosesRatio > 0) {
      final double prosesSweep = prosesRatio * 2 * math.pi;
      canvas.drawArc(rect, startAngle, prosesSweep, false, prosesPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

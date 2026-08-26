import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/projects/data/models/project_model.dart';
import '../core/enums/app_role.dart';
import '../features/projects/presentation/project_controller.dart';

class DashboardChart extends ConsumerStatefulWidget {
  final List<ContractModel>? projects;
  final AppRole? userRole;

  const DashboardChart({
    super.key,
    this.projects,
    this.userRole,
  });

  @override
  ConsumerState<DashboardChart> createState() => _DashboardChartState();
}

class _DashboardChartState extends ConsumerState<DashboardChart> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (widget.projects != null && widget.projects!.isNotEmpty) {
        if (_currentPage < widget.projects!.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeIn,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedProjects = widget.projects;

    if (resolvedProjects == null || resolvedProjects.isEmpty) {
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
            'Belum ada data progres kontrak',
            style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: resolvedProjects.length,
            itemBuilder: (context, index) {
              return _buildContractCard(resolvedProjects[index]);
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            resolvedProjects.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              width: _currentPage == index ? 24.0 : 8.0,
              height: 8.0,
              decoration: BoxDecoration(
                color: _currentPage == index ? const Color(0xFF001AFF) : const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContractCard(ContractModel contract) {
    final asyncProjects = ref.watch(projectsProvider(contract.id));
    
    final bool isPerencanaan = contract.type.toLowerCase().contains('perencanaan');
    final Color bgColor = isPerencanaan 
        ? const Color(0xFFE50012).withOpacity(0.04) 
        : const Color(0xFF0033CC).withOpacity(0.04);
    final Color borderColor = isPerencanaan 
        ? const Color(0xFFE50012).withOpacity(0.15) 
        : const Color(0xFF0033CC).withOpacity(0.15);
        
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: asyncProjects.when(
        data: (projects) {
          final totalProjects = projects.length;
          double avgPhysical = 0.0;
          if (totalProjects > 0) {
            avgPhysical = projects.fold(0.0, (sum, p) => sum + p.physicalProgress) / totalProjects;
          }
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${contract.name} (${contract.type})',
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E1E1E),
                  fontFamily: 'Inter',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
                                selesaiRatio: avgPhysical,
                                prosesRatio: 0.0,
                                colorSelesai: const Color(0xFF0055FF),
                                colorProses: Colors.transparent,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${(avgPhysical * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E1E1E),
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const Text(
                                'Progres',
                                style: TextStyle(
                                  fontSize: 13,
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
                          label: 'Total Proyek',
                          value: '$totalProjects',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err', style: const TextStyle(fontSize: 12))),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF555555),
              fontFamily: 'Inter',
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E1E1E),
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

import 'package:flutter/material.dart';
import '../widgets/laporan_harian_card.dart';

// ─────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────

/// A single daily report entry.
class LaporanEntry {
  final String title;
  final String time; // "HH:mm"
  final Color iconColor;
  final Color iconBackgroundColor;

  const LaporanEntry({
    required this.title,
    required this.time,
    this.iconColor = const Color(0xFF0D47A1),
    this.iconBackgroundColor = const Color(0xFFE8F0FE),
  });
}

/// One day in the week calendar: date + list of reports for that day.
class CalendarDay {
  final DateTime date;
  final List<LaporanEntry> reports;

  const CalendarDay({required this.date, this.reports = const []});
}

// ─────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────

/// Detail page that shows a project header, a navigable weekly calendar,
/// and the list of daily reports for the selected day.
class DetailDataLaporanScreen extends StatefulWidget {
  final String projectTitle;
  final String projectStatus;
  final String projectImageUrl;

  const DetailDataLaporanScreen({
    super.key,
    required this.projectTitle,
    required this.projectStatus,
    required this.projectImageUrl,
  });

  @override
  State<DetailDataLaporanScreen> createState() =>
      _DetailDataLaporanScreenState();
}

class _DetailDataLaporanScreenState extends State<DetailDataLaporanScreen> {
  // Tracks the Monday of the displayed week
  late DateTime _weekStart;
  // Currently selected date
  late DateTime _selectedDate;

  // Indonesian month names
  static const List<String> _monthNames = [
    '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  // Indonesian day names
  static const List<String> _dayNames = [
    'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min',
  ];

  static const List<String> _fullDayNames = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];

  // Dummy report data keyed by date (yyyy-MM-dd)
  static final Map<String, List<LaporanEntry>> _reportData = {
    '2025-01-01': [
      const LaporanEntry(title: 'Laporan Pengawasan Harian', time: '08:30'),
    ],
    '2025-01-02': [
      const LaporanEntry(
          title: 'Laporan Fisik Harian',
          time: '09:15',
          iconColor: Color(0xFF1565C0),
          iconBackgroundColor: Color(0xFFBBDEFB)),
    ],
    '2025-01-03': [
      const LaporanEntry(title: 'Laporan Pengawasan Harian', time: '08:00'),
      const LaporanEntry(
          title: 'Laporan Cuaca Harian',
          time: '14:00',
          iconColor: Color(0xFF2E7D32),
          iconBackgroundColor: Color(0xFFC8E6C9)),
    ],
    '2025-01-04': [
      const LaporanEntry(title: 'Laporan Pengawasan Harian', time: '10:48'),
      const LaporanEntry(
          title: 'Laporan Fisik Harian',
          time: '16:30',
          iconColor: Color(0xFF1565C0),
          iconBackgroundColor: Color(0xFFBBDEFB)),
    ],
    '2025-01-05': [
      const LaporanEntry(title: 'Laporan Pengawasan Harian', time: '09:00'),
      const LaporanEntry(
          title: 'Laporan Fisik Harian',
          time: '14:45',
          iconColor: Color(0xFF1565C0),
          iconBackgroundColor: Color(0xFFBBDEFB)),
    ],
  };

  @override
  void initState() {
    super.initState();
    // Default: week of 1–7 Jan 2025, selected = Thursday 4 Jan
    _selectedDate = DateTime(2025, 1, 4);
    _weekStart = _mondayOf(_selectedDate);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  DateTime _mondayOf(DateTime date) {
    // weekday: Mon=1 … Sun=7
    return date.subtract(Duration(days: date.weekday - 1));
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<LaporanEntry> _reportsForDate(DateTime d) =>
      _reportData[_dateKey(d)] ?? [];

  String _formattedSelectedDate() {
    final int wd = _selectedDate.weekday - 1; // 0=Mon … 6=Sun
    final dayName = _fullDayNames[wd];
    final monthName = _monthNames[_selectedDate.month];
    return '$dayName, ${_selectedDate.day.toString().padLeft(2, '0')} $monthName ${_selectedDate.year}';
  }

  String _formattedReportDate(DateTime d) {
    final monthName = _monthNames[d.month];
    return '${d.day.toString().padLeft(2, '0')} $monthName ${d.year}';
  }

  String _headerMonth() {
    final monthName = _monthNames[_selectedDate.month];
    return '$monthName ${_selectedDate.year}';
  }

  void _prevWeek() => setState(() {
        _weekStart = _weekStart.subtract(const Duration(days: 7));
        // Don't auto-select; keep _selectedDate unless it's out of visible week
        if (_selectedDate.isBefore(_weekStart) ||
            _selectedDate.isAfter(_weekStart.add(const Duration(days: 6)))) {
          _selectedDate = _weekStart;
        }
      });

  void _nextWeek() => setState(() {
        _weekStart = _weekStart.add(const Duration(days: 7));
        if (_selectedDate.isBefore(_weekStart) ||
            _selectedDate.isAfter(_weekStart.add(const Duration(days: 6)))) {
          _selectedDate = _weekStart;
        }
      });

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool isCompleted =
        widget.projectStatus.toLowerCase() == 'selesai';
    final Color badgeDotColor =
        isCompleted ? const Color(0xFF001AFF) : const Color(0xFF00C853);
    final Color badgeBgColor =
        isCompleted ? const Color(0xFFE5EAFF) : const Color(0xFFE8F9EE);

    final List<LaporanEntry> todayReports = _reportsForDate(_selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFF0F1F5), height: 1.0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color(0xFF1E1E1E), size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Data Laporan',
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontWeight: FontWeight.w700,
            fontSize: 16.5,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Project header card ─────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    widget.projectImageUrl,
                    width: 64,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      width: 64,
                      height: 56,
                      color: const Color(0xFFE5E7EB),
                      child: const Icon(Icons.image_not_supported_outlined,
                          color: Colors.grey, size: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name + badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.projectTitle,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E1E),
                          fontFamily: 'Inter',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
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
                              widget.projectStatus,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: badgeDotColor,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Weekly calendar ─────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: Column(
              children: [
                // Month nav row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _prevWeek,
                      icon: const Icon(Icons.chevron_left,
                          color: Color(0xFF1E1E1E), size: 22),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Text(
                      _headerMonth(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E1E1E),
                        fontFamily: 'Inter',
                      ),
                    ),
                    IconButton(
                      onPressed: _nextWeek,
                      icon: const Icon(Icons.chevron_right,
                          color: Color(0xFF1E1E1E), size: 22),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Day columns
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (i) {
                    final day = _weekStart.add(Duration(days: i));
                    final isSelected = day.year == _selectedDate.year &&
                        day.month == _selectedDate.month &&
                        day.day == _selectedDate.day;
                    final dayReports = _reportsForDate(day);

                    return GestureDetector(
                      onTap: () => setState(() => _selectedDate = day),
                      child: Column(
                        children: [
                          // Day label (Sen, Sel, ...)
                          Text(
                            _dayNames[i],
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF001AFF)
                                  : const Color(0xFF9E9E9E),
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Date circle
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF001AFF)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              day.day.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF1E1E1E),
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          // Dot indicators (one per report, max 3)
                          if (dayReports.isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: dayReports
                                  .take(3)
                                  .map(
                                    (r) => Container(
                                      width: 5,
                                      height: 5,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 1.5),
                                      decoration: BoxDecoration(
                                        color: r.iconColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            )
                          else
                            const SizedBox(height: 5),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // ── Selected day label ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(
              _formattedSelectedDate(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E1E1E),
                fontFamily: 'Inter',
              ),
            ),
          ),

          // ── Report list ─────────────────────────────────────────────────
          Expanded(
            child: todayReports.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_note_outlined,
                            size: 42, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada laporan pada hari ini',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.only(top: 4, bottom: 24),
                    itemCount: todayReports.length,
                    itemBuilder: (context, index) {
                      final report = todayReports[index];
                      final dateStr = _formattedReportDate(_selectedDate);
                      return LaporanHarianCard(
                        title: report.title,
                        createdAt: '$dateStr - ${report.time}',
                        iconColor: report.iconColor,
                        iconBackgroundColor: report.iconBackgroundColor,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Membuka: ${report.title}'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

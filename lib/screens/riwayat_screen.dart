import 'package:flutter/material.dart';
import '../widgets/timeline_item.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────────────────────

class _KronologiEntry {
  final String date;
  final String time;
  final String description;
  final String actor;

  const _KronologiEntry({
    required this.date,
    required this.time,
    required this.description,
    required this.actor,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

/// "Riwayat" tab content: shows a project header and its full activity timeline.
class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({super.key});

  // Dummy project data
  static const String _projectTitle    = 'Pembangunan Jembatan';
  static const String _projectLocation = 'Purwokerto';
  static const String _projectImageUrl =
      'https://images.unsplash.com/photo-1545628221-bb35ab299e58?q=80&w=800&auto=format&fit=crop';

  // Dummy chronology entries
  static const List<_KronologiEntry> _entries = [
    _KronologiEntry(
      date: '1 Januari 2025',
      time: '14:30',
      description: 'Proyek Dibuat',
      actor: 'Aradea (Konsultan)',
    ),
    _KronologiEntry(
      date: '2 Januari 2025',
      time: '11:30',
      description: 'Menambahkan Folder Administrasi "Pra Kontrak"',
      actor: 'Aradea (Konsultan)',
    ),
    _KronologiEntry(
      date: '3 Januari 2025',
      time: '12:35',
      description: 'Menambahkan File dalam folder "Pra Kontrak"',
      actor: 'Aradea (Konsultan)',
    ),
    _KronologiEntry(
      date: '4 Januari 2025',
      time: '11:30',
      description: 'Menambahkan Folder Administrasi "Dokumen Kontrak"',
      actor: 'Aradea (Konsultan)',
    ),
    _KronologiEntry(
      date: '4 Januari 2025',
      time: '11:35',
      description: 'Menambahkan File dalam folder "Dokumen Kontrak"',
      actor: 'Aradea (Konsultan)',
    ),
    _KronologiEntry(
      date: '5 Januari 2025',
      time: '11:35',
      description: 'Menambahkan File dalam folder "PCM"',
      actor: 'Aradea (Konsultan)',
    ),
    _KronologiEntry(
      date: '5 Januari 2025',
      time: '11:40',
      description: 'Menambahkan Folder Administrasi "PCM"',
      actor: 'Aradea (Konsultan)',
    ),
    _KronologiEntry(
      date: '6 Januari 2025',
      time: '09:00',
      description: 'Laporan Pengawasan Harian ditambahkan',
      actor: 'Aradea (Konsultan)',
    ),
    _KronologiEntry(
      date: '6 Januari 2025',
      time: '16:45',
      description: 'Laporan Fisik Harian ditambahkan',
      actor: 'Aradea (Konsultan)',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Project header card ───────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: const Color(0xFFEAECF2), width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(13),
                    topRight: Radius.circular(13),
                  ),
                  child: Image.network(
                    _projectImageUrl,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      height: 130,
                      color: const Color(0xFFE5E7EB),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                // Project info
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _projectTitle,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E1E),
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _projectLocation,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFFA0A0A0),
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Timeline list ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              children: List.generate(_entries.length, (index) {
                final entry = _entries[index];
                return TimelineItem(
                  date: entry.date,
                  time: entry.time,
                  description: entry.description,
                  actor: entry.actor,
                  isLast: index == _entries.length - 1,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

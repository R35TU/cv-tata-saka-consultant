import 'package:flutter/material.dart';
import '../widgets/folder_item.dart';

class DetailProyekScreen extends StatefulWidget {
  final String title;
  final String location;
  final String status;
  final String imageUrl;

  const DetailProyekScreen({
    super.key,
    required this.title,
    required this.location,
    required this.status,
    required this.imageUrl,
  });

  @override
  State<DetailProyekScreen> createState() => _DetailProyekScreenState();
}

class _DetailProyekScreenState extends State<DetailProyekScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = widget.status.toLowerCase() == 'selesai';
    
    // Status color mapping
    final Color badgeDotColor = isCompleted ? const Color(0xFF001AFF) : const Color(0xFF00C853);
    final Color badgeBgColor = isCompleted ? const Color(0xFFE5EAFF) : const Color(0xFFE8F9EE);
    final Color badgeTextColor = isCompleted ? const Color(0xFF001AFF) : const Color(0xFF00C853);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Detail Proyek',
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontWeight: FontWeight.w700,
            fontSize: 16.5,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFF0F1F5),
                  width: 1.0,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF001AFF),
              indicatorWeight: 2.0,
              labelColor: const Color(0xFF001AFF),
              unselectedLabelColor: const Color(0xFFB0B3BE),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                fontFamily: 'Inter',
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                fontFamily: 'Inter',
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: 'Umum'),
                Tab(text: 'Administrasi'),
                Tab(text: 'Progres'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(), // Only focus on Umum tab content
        children: [
          // Tab 1: Umum Content
          _buildUmumTabContent(badgeBgColor, badgeDotColor, badgeTextColor),
          // Tab 2: Administrasi Content
          _buildAdministrasiTabContent(),
          // Tab 3: Progres Placeholder
          _buildPlaceholderView('Progres'),
        ],
      ),
    );
  }

  Widget _buildPlaceholderView(String tabName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'Halaman Detail $tabName sedang dikembangkan',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdministrasiTabContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: const [
          FolderItem(
            folderName: 'Dokumen Pra Kontrak',
            fileCount: 3,
            files: ['LoremIpsum.pdf', 'HebatKamuTuh.txt', 'Hahahahhahahahaa.pdf'],
          ),
          FolderItem(
            folderName: 'Dokumen Kontrak',
            fileCount: 8,
            files: [
              'SuratPerjanjian.pdf',
              'RencanaKerja.pdf',
              'SpekTeknis.pdf',
              'BAP.pdf',
              'Lampiran1.pdf',
              'Lampiran2.pdf',
              'Lampiran3.pdf',
              'SertifikatJaminan.pdf'
            ],
          ),
          FolderItem(
            folderName: 'PCM',
            fileCount: 2,
            files: ['NotulenPCM.pdf', 'DaftarHadirPCM.pdf'],
          ),
          FolderItem(
            folderName: 'Adendum',
            fileCount: 1,
            files: ['Adendum_Final.pdf'],
          ),
          FolderItem(
            folderName: 'Addset',
            fileCount: 3,
            files: ['Addset_1.pdf', 'Addset_2.pdf', 'Addset_3.pdf'],
          ),
          FolderItem(
            folderName: 'Request of Work',
            fileCount: 1,
            files: ['RoW_Jembatan.pdf'],
          ),
          FolderItem(
            folderName: 'Soft Drawing',
            fileCount: 1,
            files: ['DesignJembatan.txt'],
          ),
          FolderItem(
            folderName: 'Surat Pengunduran Diri',
            fileCount: 1,
            files: ['SuratPengunduran.pdf'],
          ),
        ],
      ),
    );
  }

  Widget _buildUmumTabContent(Color badgeBgColor, Color badgeDotColor, Color badgeTextColor) {
    // 6 identical bridge documentation photos matching the screenshot
    const String docPhotoUrl = 'https://images.unsplash.com/photo-1545628221-bb35ab299e58?q=80&w=300&auto=format&fit=crop';
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Cover Image with Overlay Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14.0),
                child: Image.network(
                  widget.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                left: 14,
                bottom: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
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
                      const SizedBox(width: 6),
                      Text(
                        widget.status,
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
              ),
            ],
          ),
          
          const SizedBox(height: 18),
          
          // 2. Project Title
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E1E1E),
              height: 1.3,
              fontFamily: 'Inter',
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 3. Location and Supervision row
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Color(0xFFA0A0A0), size: 16),
              const SizedBox(width: 4),
              Text(
                widget.location,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFA0A0A0),
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                '|',
                style: TextStyle(color: Color(0xFFE0E0E0)),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.access_time_rounded, color: Color(0xFFA0A0A0), size: 15),
              const SizedBox(width: 4),
              const Text(
                'Jenis Pengawasan',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFFA0A0A0),
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 4. Dates Grid (Mulai & Selesai)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Tanggal Mulai',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF8E8E93),
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '1 Januari 2026',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Tanggal Selesai',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF8E8E93),
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '30 Februari 2026',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 22),
          
          // 5. Project Specifications Table Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1.0,
              ),
            ),
            child: Column(
              children: [
                _buildTableRow('Pemilik Proyek', 'Pemerintah Kabupaten Banyumas'),
                _buildTableRow('Sumber Dana', 'APBD 2026'),
                _buildTableRow('Konsultan Pengawas', 'CV. Tata Saka Consultant'),
                _buildTableRow('Kontraktor Pelaksana', 'PT. Maju Mundur Jaya'),
                _buildTableRow(
                  'Deskripsi',
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ulla.',
                  isLast: true,
                  isLongText: true,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 26),
          
          // 6. Tim Proyek (Team) Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tim Proyek',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E1E1E),
                  fontFamily: 'Inter',
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF1E1E1E), size: 24),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit Tim Proyek clicked.')),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 14),
          
          // Horizontal scrolling Team Members with vertical dividers
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildTeamMemberItem('CV. Tata Saka Konsultan', 'Konsultan', const Color(0xFFE8F9EE), const Color(0xFF00C853)),
                _buildVerticalDivider(),
                _buildTeamMemberItem('Evos E.', 'Kontraktor', const Color(0xFFE5EAFF), const Color(0xFF001AFF)),
                _buildVerticalDivider(),
                _buildTeamMemberItem('Alter Ego', 'External', const Color(0xFFF3E5F5), const Color(0xFFAB47BC)),
                _buildVerticalDivider(),
                _buildTeamMemberItem('Onic P.', 'Konsultan', const Color(0xFFE8F9EE), const Color(0xFF00C853)),
                _buildVerticalDivider(),
                _buildTeamMemberItem('Aura Fi', 'Dinas', const Color(0xFFFFEBEE), const Color(0xFFEF5350)),
              ],
            ),
          ),
          
          const SizedBox(height: 28),
          
          // 7. Foto Dokumentasi Section
          const Text(
            'Foto Dokumentasi',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E1E1E),
              fontFamily: 'Inter',
            ),
          ),
          
          const SizedBox(height: 14),
          
          // 2-Column Grid of 6 Photos
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.45,
            ),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  docPhotoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTableRow(String label, String value, {bool isLast = false, bool isLongText = false}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : const Color(0xFFE5E7EB),
            width: 1.0,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF8E8E93),
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isLongText ? FontWeight.w400 : FontWeight.bold,
                color: const Color(0xFF1E1E1E),
                height: isLongText ? 1.4 : 1.2,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberItem(String name, String role, Color badgeBg, Color badgeText) {
    return Container(
      width: 72,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          // Grey Circle Avatar
          const CircleAvatar(
            backgroundColor: Color(0xFFA0A0A0),
            radius: 20,
          ),
          const SizedBox(height: 8),
          // Member Name
          Text(
            name,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E1E),
              fontFamily: 'Inter',
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          // Role Badge Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.5),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              role,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: badgeText,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 60,
      width: 1,
      color: const Color(0xFFF0F1F5),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
    );
  }
}

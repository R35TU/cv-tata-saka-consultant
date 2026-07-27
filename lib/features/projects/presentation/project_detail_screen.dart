import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/enums/app_role.dart';
import '../../../widgets/dynamic_folder_item.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/data/models/user_model.dart';
import '../data/models/project_model.dart';
import '../data/models/document_model.dart';
import 'project_controller.dart';
import '../../../widgets/mock_image_picker.dart';  // exports AppImagePicker

// Fixed role options for project members
const _kProjectRoles = ['Pengawas', 'Pelaksana', 'Pengawas Dinas', 'Eksternal'];

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(documentsControllerProvider.notifier).loadDocuments(widget.projectId);
      ref.read(projectsControllerProvider.notifier).loadProjects();
    });
  }

  void _setupTabController(bool isExternal) {
    final length = isExternal ? 2 : 3;
    if (_tabController == null || _tabController!.length != length) {
      _tabController?.dispose();
      _tabController = TabController(length: length, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  // ── Show Upload Dialog ───────────────────────────────────────────────────
  void _showUploadDialog(String folderName, AppRole role, String userName) {
    final nameCtrl = TextEditingController();
    String extension = '.pdf';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Upload ke $folderName', style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nama File (tanpa ekstensi)', hintText: 'Laporan_Tambahan'),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Format File:', style: TextStyle(fontFamily: 'Inter', fontSize: 13)),
                  DropdownButton<String>(
                    value: extension,
                    items: const [
                      DropdownMenuItem(value: '.pdf', child: Text('PDF (.pdf)')),
                      DropdownMenuItem(value: '.txt', child: Text('Text (.txt)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          extension = val;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
            TextButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;
                final filename = nameCtrl.text.trim() + extension;
                final newDoc = DocumentModel(
                  id: const Uuid().v4(),
                  projectId: widget.projectId,
                  folderName: folderName,
                  name: filename,
                  fileUrl: '/documents/$filename',
                  fileSize: '1.4 MB',
                  uploadedBy: userName,
                  uploadedAt: DateTime.now().toString().substring(0, 16),
                );
                await ref.read(documentsControllerProvider.notifier).addDocument(newDoc, userName, role.label);
                if (mounted) Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File $filename berhasil diunggah.')));
              },
              child: const Text('Upload', style: TextStyle(color: Color(0xFF001AFF), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Show Document Actions Bottom Sheet ────────────────────────────────────
  void _showDocumentActionsBottomSheet(DocumentModel doc, AppRole role, String userName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(doc.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), fontFamily: 'Inter')),
              const SizedBox(height: 4),
              Text('Versi ${doc.version} • ${doc.fileSize} • Oleh: ${doc.uploadedBy}', style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontFamily: 'Inter')),
              const SizedBox(height: 20),
              
              // Action 1: Preview
              ListTile(
                leading: const Icon(Icons.visibility_outlined, color: Color(0xFF001AFF)),
                title: const Text('Preview File', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                onTap: () {
                  Navigator.of(context).pop();
                  _showPreviewDialog(doc);
                },
              ),
              // Action 2: Download
              ListTile(
                leading: const Icon(Icons.download_rounded, color: Color(0xFF00C853)),
                title: const Text('Download File', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                onTap: () {
                  Navigator.of(context).pop();
                  _simulateDownload(doc);
                },
              ),
              // Action 3: Version History
              ListTile(
                leading: const Icon(Icons.history_rounded, color: Color(0xFFFFB300)),
                title: const Text('Riwayat Versi & Upload Baru', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                onTap: () {
                  Navigator.of(context).pop();
                  _showVersionHistoryDialog(doc, role, userName);
                },
              ),
              // Action 4: Rename (Konsultan only)
              if (role.canManageAdministration)
                ListTile(
                  leading: const Icon(Icons.edit_outlined, color: Color(0xFF8E8E93)),
                  title: const Text('Ubah Nama File', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showRenameDialog(doc, role, userName);
                  },
                ),
              // Action 5: Delete (Konsultan only)
              if (role.canManageAdministration)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF3D00)),
                  title: const Text('Hapus File', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFFF3D00), fontFamily: 'Inter')),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showDeleteConfirmDialog(doc, role, userName);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showPreviewDialog(DocumentModel doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Preview - ${doc.name}', style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 15)),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
          child: Text(
            doc.name.toLowerCase().endsWith('.txt')
                ? '=== ISI FILE TEXT ===\nDokumen: ${doc.name}\nVersi: ${doc.version}\nPengunggah: ${doc.uploadedBy}\nTanggal: ${doc.uploadedAt}\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Kerja lapangan berjalan lancar.'
                : '=== PRATINJAU DOKUMEN PDF ===\nFormat: Adobe PDF Document\nHalaman: 1 / 4\nStatus Enkripsi: Secure (AES-256)\nSemua tanda tangan digital terverifikasi.',
            style: const TextStyle(fontFamily: 'Courier', fontSize: 11, color: Colors.black87),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Tutup', style: TextStyle(color: Color(0xFF001AFF), fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  void _simulateDownload(DocumentModel doc) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        double progress = 0.0;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (progress < 1.0) {
                if (ctx.mounted) {
                  setDialogState(() {
                    progress = (progress + 0.25).clamp(0.0, 1.0);
                  });
                }
              } else {
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File "${doc.name}" disimpan ke folder Unduhan.')));
                });
              }
            });
            return AlertDialog(
              title: const Text('Mengunduh File', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 14)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(value: progress, color: const Color(0xFF001AFF), backgroundColor: Colors.grey.shade200),
                  const SizedBox(height: 12),
                  Text('${(progress * 100).toInt()}% selesai (${doc.fileSize})', style: const TextStyle(fontFamily: 'Inter', fontSize: 12)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showVersionHistoryDialog(DocumentModel doc, AppRole role, String userName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Riwayat Versi - ${doc.name}', style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 15)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Version list
              if (doc.versions.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Tidak ada riwayat versi sebelumnya.', style: TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'Inter')),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: doc.versions.length,
                    itemBuilder: (context, index) {
                      final ver = doc.versions[index];
                      return ListTile(
                        dense: true,
                        title: Text(ver.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        subtitle: Text('Versi ${ver.version} • ${ver.fileSize}\nOleh: ${ver.uploadedBy} • ${ver.uploadedAt}', style: const TextStyle(fontSize: 10)),
                      );
                    },
                  ),
                ),
              const Divider(),
              // Upload new version (Restricted to Konsultan/Super User)
              if (role.canManageAdministration)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _showUploadNewVersionDialog(doc, role, userName);
                    },
                    icon: const Icon(Icons.upload_rounded, size: 16),
                    label: Text('Unggah Versi Baru (v${doc.version + 1})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF001AFF), foregroundColor: Colors.white),
                  ),
                )
              else
                const Text('Hanya Konsultan yang dapat mengunggah versi baru.', style: TextStyle(fontSize: 10.5, color: Colors.red, fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Tutup', style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  void _showUploadNewVersionDialog(DocumentModel doc, AppRole role, String userName) {
    final nameCtrl = TextEditingController(text: doc.name.replaceAll('.pdf', '').replaceAll('.txt', '') + '_v${doc.version + 1}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unggah Versi Baru', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 15)),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Nama File Baru'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty) return;
              final ext = doc.name.endsWith('.pdf') ? '.pdf' : '.txt';
              final newName = nameCtrl.text.trim() + ext;
              await ref.read(documentsControllerProvider.notifier).uploadNewVersion(
                    widget.projectId,
                    doc.id,
                    newName,
                    '1.5 MB',
                    '/documents/$newName',
                    userName,
                    role.label,
                  );
              if (mounted) Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File "${doc.name}" diperbarui ke versi ${doc.version + 1} dengan nama "$newName".')));
            },
            child: const Text('Upload', style: TextStyle(color: Color(0xFF001AFF), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(DocumentModel doc, AppRole role, String userName) {
    final nameCtrl = TextEditingController(text: doc.name.replaceAll('.pdf', '').replaceAll('.txt', ''));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah Nama File', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 15)),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Nama Baru'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty) return;
              final ext = doc.name.endsWith('.pdf') ? '.pdf' : '.txt';
              final newName = nameCtrl.text.trim() + ext;
              await ref.read(documentsControllerProvider.notifier).renameDocument(
                    widget.projectId,
                    doc.id,
                    newName,
                    userName,
                    role.label,
                  );
              if (mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Ubah', style: TextStyle(color: Color(0xFF001AFF), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(DocumentModel doc, AppRole role, String userName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Dokumen', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red)),
        content: Text('Apakah Anda yakin ingin menghapus file "${doc.name}"? File ini akan hilang secara permanen dari database lokal.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              await ref.read(documentsControllerProvider.notifier).deleteDocument(
                    widget.projectId,
                    doc.id,
                    userName,
                    role.label,
                  );
              if (mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── Show Modify Progress Dialog (Konsultan only) ──────────────────────────
  void _showModifyProgressDialog(ProjectModel project) {
    double physical = project.physicalProgress;
    double financial = project.financialProgress;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Ubah Progress Proyek', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Progress Fisik: ${(physical * 100).toInt()}%', style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.bold)),
              Slider(
                value: physical,
                onChanged: (val) => setDialogState(() => physical = val),
                activeColor: const Color(0xFF00C853),
                inactiveColor: Colors.grey.shade200,
              ),
              const SizedBox(height: 12),
              Text('Progress Pengawasan: ${(financial * 100).toInt()}%', style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.bold)),
              Slider(
                value: financial,
                onChanged: (val) => setDialogState(() => financial = val),
                activeColor: const Color(0xFF001AFF),
                inactiveColor: Colors.grey.shade200,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
            TextButton(
              onPressed: () async {
                await ref.read(projectsControllerProvider.notifier).updateProjectProgress(project.id, physical);
                // Also update financial progress manually if needed
                final updatedProject = project.copyWith(physicalProgress: physical, financialProgress: financial);
                await ref.read(projectRepositoryProvider).updateProject(updatedProject);
                ref.read(projectsControllerProvider.notifier).loadProjects();
                if (mounted) Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Progres proyek berhasil diperbarui.')));
              },
              child: const Text('Simpan', style: TextStyle(color: Color(0xFF001AFF), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.valueOrNull;
    final userRole = user?.role ?? AppRole.eksternal;
    final userName = user?.name ?? 'User';

    // Ensure tab controller is correctly initialized for external/other roles
    final isExternal = userRole == AppRole.eksternal;
    _setupTabController(isExternal);

    final projectsState = ref.watch(projectsControllerProvider);
    final projects = projectsState.valueOrNull ?? [];
    final project = projects.firstWhere(
      (p) => p.id == widget.projectId,
      orElse: () => ProjectModel(
        id: widget.projectId,
        name: 'Memuat...',
        location: '',
        status: '',
        physicalProgress: 0.0,
        financialProgress: 0.0,
        imageUrl: '',
        description: '',
        owner: '',
        supervisor: '',
        createdAt: '',
      ),
    );

    if (project.name == 'Memuat...') {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bool isCompleted = project.status.toLowerCase() == 'selesai';
    final Color badgeDotColor = isCompleted ? const Color(0xFF001AFF) : const Color(0xFF00C853);
    final Color badgeBgColor = isCompleted ? const Color(0xFFE5EAFF) : const Color(0xFFE8F9EE);
    final Color badgeTextColor = isCompleted ? const Color(0xFF001AFF) : const Color(0xFF00C853);

    // Watch documents
    final docsState = ref.watch(documentsControllerProvider);
    final documents = docsState.valueOrNull ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E)),
          onPressed: () => context.pop(),
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
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF0F1F5), width: 1.0))),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF001AFF),
              indicatorWeight: 2.0,
              labelColor: const Color(0xFF001AFF),
              unselectedLabelColor: const Color(0xFFB0B3BE),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Inter'),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, fontFamily: 'Inter'),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                const Tab(text: 'Umum'),
                if (!isExternal) const Tab(text: 'Administrasi'),
                const Tab(text: 'Progres'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Tab 1: Umum Content
          _buildUmumTabContent(project, badgeBgColor, badgeDotColor, badgeTextColor, userRole),
          // Tab 2: Administrasi Content (Hidden if Eksternal)
          if (!isExternal) _buildAdministrasiTabContent(documents, userRole, userName),
          // Tab 3: Progres Content
          _buildProgresTabContent(project, userRole),
        ],
      ),
    );
  }

  Widget _buildCoverImage(String url) {
    const double h = 180;
    final placeholder = Container(
      height: h,
      width: double.infinity,
      color: const Color(0xFFF0F1F5),
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: Color(0xFFB0B3BE), size: 40),
    );
    if (url.isEmpty) return placeholder;
    if (url.startsWith('/') || url.startsWith('file://')) {
      return Image.file(
        File(url.replaceFirst('file://', '')),
        height: h, width: double.infinity, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }
    return Image.network(
      url,
      height: h, width: double.infinity, fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }

  Widget _buildUmumTabContent(ProjectModel p, Color badgeBgColor, Color badgeDotColor, Color badgeTextColor, AppRole role) {
    final photo = p.imageUrl;

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
                child: _buildCoverImage(photo),
              ),
              if (role == AppRole.konsultan || role == AppRole.kontraktor)
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () async {
                      final path = await AppImagePicker.pickImage(context);
                      if (path != null && context.mounted) {
                        final updated = p.copyWith(imageUrl: path);
                        await ref.read(projectRepositoryProvider).updateProject(updated);
                        ref.read(projectsControllerProvider.notifier).loadProjects();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Foto cover proyek berhasil diperbarui.')),
                          );
                        }
                      }
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 18,
                      child: Icon(Icons.camera_alt, color: Color(0xFF001AFF), size: 18),
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
                        p.status,
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
            p.name,
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
                p.location,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFA0A0A0),
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(width: 10),
              const Text('|', style: TextStyle(color: Color(0xFFE0E0E0))),
              const SizedBox(width: 10),
              const Icon(Icons.access_time_rounded, color: Color(0xFFA0A0A0), size: 15),
              const SizedBox(width: 4),
              Text(
                p.status.toLowerCase() == 'selesai' ? 'Pengawasan Selesai' : 'Masa Pengawasan',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFA0A0A0),
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 4. Dates Grid
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tanggal Mulai', style: TextStyle(fontSize: 10.5, color: Color(0xFF8E8E93), fontWeight: FontWeight.w500, fontFamily: 'Inter')),
                    const SizedBox(height: 4),
                    Text(p.startDate, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), fontFamily: 'Inter')),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tanggal Selesai', style: TextStyle(fontSize: 10.5, color: Color(0xFF8E8E93), fontWeight: FontWeight.w500, fontFamily: 'Inter')),
                    const SizedBox(height: 4),
                    Text(p.endDate, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), fontFamily: 'Inter')),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 22),
          
          // 5. Specifications Table Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
            ),
            child: Column(
              children: [
                _buildTableRow('Pemilik Proyek', p.ownerDetail),
                _buildTableRow('Sumber Dana', p.fundingSource),
                _buildTableRow('Konsultan Pengawas', p.supervisor),
                _buildTableRow('Kontraktor Pelaksana', p.owner),
                _buildTableRow('Deskripsi', p.description, isLast: true, isLongText: true),
              ],
            ),
          ),
          
          const SizedBox(height: 26),

          // 6. Tim Proyek Section
          _buildTimProyekSection(p.id, role),

          const SizedBox(height: 28),
          
          // 7. Foto Dokumentasi Section
          const Text('Foto Dokumentasi', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Color(0xFF1E1E1E), fontFamily: 'Inter')),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
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
                  photo,
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

  Widget _buildAdministrasiTabContent(List<DocumentModel> docs, AppRole role, String userName) {
    // Group files by folder categories
    final List<String> folderNames = [
      'Dokumen Pra Kontrak',
      'Dokumen Kontrak',
      'PCM',
      'Adendum',
      'Request Of Work',
      'Shop Drawing',
      'As Built Drawing',
      'Surat',
      'Dokumen Pendukung'
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: folderNames.map((folder) {
          final folderDocs = docs.where((d) => d.folderName.toLowerCase() == folder.toLowerCase()).toList();
          return DynamicFolderItem(
            folderName: folder,
            fileCount: folderDocs.length,
            documents: folderDocs,
            showUploadButton: role.canManageAdministration,
            onUploadTap: () => _showUploadDialog(folder, role, userName),
            onDocumentTap: (doc) => _showDocumentActionsBottomSheet(doc, role, userName),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProgresTabContent(ProjectModel p, AppRole role) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Physical progress block
          const Text('Progress Fisik Proyek', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), fontFamily: 'Inter')),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: LinearProgressIndicator(
                    value: p.physicalProgress,
                    minHeight: 18,
                    color: const Color(0xFF00C853),
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text('${(p.physicalProgress * 100).toInt()}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), fontFamily: 'Inter')),
            ],
          ),
          const SizedBox(height: 24),

          // Supervision progress block
          const Text('Progress Pengawasan Proyek', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), fontFamily: 'Inter')),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: LinearProgressIndicator(
                    value: p.financialProgress,
                    minHeight: 18,
                    color: const Color(0xFF001AFF),
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text('${(p.financialProgress * 100).toInt()}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), fontFamily: 'Inter')),
            ],
          ),
          const SizedBox(height: 36),

          // Statistics card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF0F1F5), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Statistik Penyelesaian', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                const SizedBox(height: 16),
                _buildStatProgressRow('Rata-rata Kenaikan Mingguan', '2.4%'),
                const Divider(height: 24, color: Color(0xFFF0F1F5)),
                _buildStatProgressRow('Deviasi Rencana vs Realisasi', '+1.2% (Surplus)'),
                const Divider(height: 24, color: Color(0xFFF0F1F5)),
                _buildStatProgressRow('Sisa Hari Kerja Kontrak', '124 Hari'),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Change Progress button (Konsultan only)
          if (role.canInputSupervisorReport) // Only Konsultan has right to change progress directly
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _showModifyProgressDialog(p),
                icon: const Icon(Icons.edit_road_rounded, color: Colors.white),
                label: const Text('Sesuaikan Progres Fisik & Pengawasan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF001AFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  elevation: 0,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatProgressRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, color: Color(0xFF757575), fontFamily: 'Inter')),
        Text(val, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), fontFamily: 'Inter')),
      ],
    );
  }

  // ── Tim Proyek Section (real data) ──────────────────────────────────────
  Widget _buildTimProyekSection(String projectId, AppRole role) {
    final membersAsync = ref.watch(projectMembersProvider(projectId));
    final allUsersAsync = ref.watch(allUsersProvider);

    return membersAsync.when(
      loading: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
      error: (e, _) => Text('Error memuat tim: $e', style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.red)),
      data: (members) {
        final allUsers = allUsersAsync.valueOrNull ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tim Proyek', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Color(0xFF1E1E1E), fontFamily: 'Inter')),
                if (role.canManageProjects)
                  GestureDetector(
                    onTap: () => _showKelolaTim(projectId, members, allUsers),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF001AFF).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_note_rounded, color: Color(0xFF001AFF), size: 15),
                          SizedBox(width: 4),
                          Text('Kelola Tim', style: TextStyle(fontFamily: 'Inter', fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF001AFF))),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (members.isEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE8E8E8)),
                ),
                child: const Center(
                  child: Text('Belum ada anggota tim.', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF8E8E93))),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: members.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final m = entry.value;
                    final user = allUsers.where((u) => u.id == m.userId).firstOrNull;
                    final name = user != null
                        ? (user.name.length > 8 ? '${user.name.substring(0, 7)}.' : user.name)
                        : 'User';
                    final memberRole = m.role;
                    final colors = _memberRoleColors(user?.role ?? AppRole.eksternal);
                    return Row(
                      children: [
                        _buildTeamMemberItem(name, memberRole, colors.$1, colors.$2),
                        if (idx < members.length - 1) _buildVerticalDivider(),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        );
      },
    );
  }

  // ── Warna avatar berdasarkan AppRole ─────────────────────────────────────
  (Color, Color) _memberRoleColors(AppRole role) => switch (role) {
    AppRole.konsultan  => (const Color(0xFFE8F9EE), const Color(0xFF00C853)),
    AppRole.kontraktor => (const Color(0xFFE5EAFF), const Color(0xFF001AFF)),
    AppRole.dinas      => (const Color(0xFFFFEBEE), const Color(0xFFFF3D00)),
    AppRole.eksternal  => (const Color(0xFFF3E5F5), const Color(0xFFAB47BC)),
  };

  // ── Dialog: Kelola Tim Proyek ─────────────────────────────────────────────
  void _showKelolaTim(
    String projectId,
    List<dynamic> currentMembers,
    List<UserModel> allUsers,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _KelolaTimSheet(
        projectId: projectId,
        allUsers: allUsers,
        ref: ref,
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
              style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93), fontWeight: FontWeight.w500, fontFamily: 'Inter'),
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
          CircleAvatar(
            backgroundColor: badgeBg,
            radius: 20,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 15, color: badgeText),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), fontFamily: 'Inter'),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.5),
            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(10.0)),
            child: Text(
              role,
              style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: badgeText, fontFamily: 'Inter'),
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

// ═══════════════════════════════════════════════════════════════════════════
// Kelola Tim Bottom Sheet Widget
// ═══════════════════════════════════════════════════════════════════════════

class _KelolaTimSheet extends ConsumerStatefulWidget {
  final String projectId;
  final List<UserModel> allUsers;
  final WidgetRef ref;

  const _KelolaTimSheet({
    required this.projectId,
    required this.allUsers,
    required this.ref,
  });

  @override
  ConsumerState<_KelolaTimSheet> createState() => _KelolaTimSheetState();
}

class _KelolaTimSheetState extends ConsumerState<_KelolaTimSheet> {
  UserModel? _selectedUser;
  String _selectedProjectRole = _kProjectRoles[0];
  bool _isAdding = false;

  Color _roleColor(AppRole role) => switch (role) {
    AppRole.konsultan  => const Color(0xFF00C853),
    AppRole.kontraktor => const Color(0xFF001AFF),
    AppRole.dinas      => const Color(0xFFFF3D00),
    AppRole.eksternal  => const Color(0xFFAB47BC),
  };

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(projectMembersProvider(widget.projectId));

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kelola Tim Proyek', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E1E1E))),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Color(0xFF8E8E93)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF0F1F5)),

            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(20),
                children: [
                  // ── Current members list ────────────────────────────────
                  const Text('Anggota Saat Ini', style: TextStyle(fontFamily: 'Inter', fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF6B7280))),
                  const SizedBox(height: 10),
                  membersAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    error: (e, _) => Text('Error: $e'),
                    data: (members) {
                      if (members.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text('Belum ada anggota.', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF8E8E93))),
                          ),
                        );
                      }
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE8E8E8)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: members.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final m = entry.value;
                            final user = widget.allUsers.where((u) => u.id == m.userId).firstOrNull;
                            final roleColor = _roleColor(user?.role ?? AppRole.eksternal);
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 17,
                                        backgroundColor: roleColor.withValues(alpha: 0.12),
                                        child: Text(
                                          user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                                          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 13, color: roleColor),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user?.name ?? 'Unknown',
                                              style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E)),
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: roleColor.withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(user?.role.label ?? '', style: TextStyle(fontFamily: 'Inter', fontSize: 9.5, fontWeight: FontWeight.bold, color: roleColor)),
                                                ),
                                                const SizedBox(width: 6),
                                                Text('Jabatan: ${m.role}', style: const TextStyle(fontFamily: 'Inter', fontSize: 10.5, color: Color(0xFF8E8E93))),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Remove button
                                      IconButton(
                                        icon: const Icon(Icons.person_remove_outlined, size: 18, color: Color(0xFFFF3D00)),
                                        onPressed: () async {
                                          await ref.read(projectsControllerProvider.notifier).removeMember(widget.projectId, m.userId);
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('${user?.name ?? 'Anggota'} dihapus dari tim.')),
                                            );
                                          }
                                        },
                                        tooltip: 'Hapus dari tim',
                                      ),
                                    ],
                                  ),
                                ),
                                if (idx < members.length - 1)
                                  const Divider(height: 1, color: Color(0xFFF0F1F5), indent: 14, endIndent: 14),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // ── Add member section ──────────────────────────────────
                  const Text('Tambah Anggota', style: TextStyle(fontFamily: 'Inter', fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF6B7280))),
                  const SizedBox(height: 10),

                  // User dropdown
                  Builder(builder: (context) {
                    final currentMembers = membersAsync.valueOrNull ?? [];
                    final currentMemberIds = currentMembers.map((m) => m.userId).toSet();
                    final availableUsers = widget.allUsers.where((u) => !currentMemberIds.contains(u.id)).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<UserModel>(
                              isExpanded: true,
                              hint: const Text('Pilih User...', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF8E8E93))),
                              value: _selectedUser,
                              items: availableUsers.map((u) => DropdownMenuItem(
                                value: u,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: _roleColor(u.role).withValues(alpha: 0.12),
                                      child: Text(u.name[0].toUpperCase(), style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.bold, color: _roleColor(u.role))),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text('${u.name} (${u.role.label})', style: const TextStyle(fontFamily: 'Inter', fontSize: 13), overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                ),
                              )).toList(),
                              onChanged: (u) => setState(() => _selectedUser = u),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Jabatan dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedProjectRole,
                              items: _kProjectRoles.map((r) => DropdownMenuItem(
                                value: r,
                                child: Text('Jabatan: $r', style: const TextStyle(fontFamily: 'Inter', fontSize: 13)),
                              )).toList(),
                              onChanged: (v) => setState(() => _selectedProjectRole = v!),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF001AFF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: (_selectedUser == null || _isAdding) ? null : () async {
                              final addedName = _selectedUser!.name;
                              setState(() => _isAdding = true);
                              await ref.read(projectsControllerProvider.notifier).addMember(
                                widget.projectId,
                                _selectedUser!.id,
                                _selectedProjectRole,
                              );
                              setState(() {
                                _isAdding = false;
                                _selectedUser = null;
                              });
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('$addedName ditambahkan ke tim.')),
                                );
                              }
                            },
                            icon: _isAdding
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.person_add_alt_1_rounded, size: 18),
                            label: Text(_isAdding ? 'Menambahkan...' : 'Tambah ke Tim', style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

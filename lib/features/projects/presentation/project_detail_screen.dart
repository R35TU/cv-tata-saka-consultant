import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:isar/isar.dart';
import '../../../../core/database/isar_database_service.dart';
import '../../../../core/database/isar_models.dart';
import '../../../../core/enums/app_role.dart';
import '../../../widgets/dynamic_folder_item.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/data/models/user_model.dart';
import '../data/models/project_model.dart';
import '../data/models/document_model.dart';
import '../data/models/folder_model.dart';
import 'project_controller.dart';
import 'folder_controller.dart';
import 'add_project_screen.dart';
import '../../../widgets/mock_image_picker.dart';  // exports AppImagePicker

// Fixed role options for project members
const _kProjectRoles = ['Pengawas', 'Pelaksana', 'Pengawas Dinas', 'Eksternal'];

class ContractDetailScreen extends ConsumerStatefulWidget {
  final String contractId;

  const ContractDetailScreen({super.key, required this.contractId});

  @override
  ConsumerState<ContractDetailScreen> createState() => _ContractDetailScreenState();
}

class _ContractDetailScreenState extends ConsumerState<ContractDetailScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(documentsControllerProvider.notifier).loadDocuments(widget.contractId);
      ref.read(contractsControllerProvider.notifier).loadProjects();
    });
  }

  void _setupTabController(bool isExternal) {
    final length = isExternal ? 1 : 2;
    if (_tabController == null || _tabController!.length != length) {
      _tabController?.dispose();
      _tabController = TabController(length: length, vsync: this);
      _tabController!.addListener(() {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  // ── Show Upload Dialog ───────────────────────────────────────────────────
  void _showUploadDialog(FolderModel folder, AppRole role, String userName) {
    final nameCtrl = TextEditingController();
    String extension = '.pdf';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Upload ke ${folder.name}', style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16)),
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
                  contractId: widget.contractId,
                  projectId: folder.projectId,
                  folderId: folder.id,
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

  // (Optional functionality for future, removed for Day 1 constraints)

  void _showEditProjectDialog(ContractModel project) async {
    final isar = await IsarDatabaseService.db;
    final allUsers = await isar.userIsars.where().findAll();
    final kontraktorUsers = allUsers.where((u) => u.role.toLowerCase() == 'kontraktor').map((u) => u.name).toList();
    final konsultanUsers = allUsers.where((u) => u.role.toLowerCase() == 'konsultan').map((u) => u.name).toList();

    if (kontraktorUsers.isEmpty) kontraktorUsers.add(project.owner);
    if (!kontraktorUsers.contains(project.owner)) kontraktorUsers.add(project.owner);

    if (konsultanUsers.isEmpty) konsultanUsers.add(project.supervisor);
    if (!konsultanUsers.contains(project.supervisor)) konsultanUsers.add(project.supervisor);

    final formKey = GlobalKey<FormState>();
    final ownerDetailCtrl = TextEditingController(text: project.dinas.join(", "));
    final sourceCtrl = TextEditingController(text: project.fundingSource);
    final descCtrl = TextEditingController(text: project.description);

    String selectedOwner = kontraktorUsers.contains(project.owner) ? project.owner : kontraktorUsers.first;
    String selectedSupervisor = konsultanUsers.contains(project.supervisor) ? project.supervisor : konsultanUsers.first;

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: const Text('Ubah Informasi Proyek', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Kontraktor Pelaksana', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: selectedOwner,
                    items: kontraktorUsers.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedOwner = val);
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Konsultan Pengawas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: selectedSupervisor,
                    items: konsultanUsers.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedSupervisor = val);
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Pemilik Proyek (Instansi)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: ownerDetailCtrl,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Pemilik proyek harus diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  const Text('Sumber Dana', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: sourceCtrl,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Deskripsi Proyek', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final updated = project.copyWith(
                  owner: selectedOwner,
                  supervisor: selectedSupervisor,
                  dinas: [ownerDetailCtrl.text.trim()],
                  fundingSource: sourceCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                );
                await ref.read(contractRepositoryProvider).updateContract(updated);
                ref.read(contractsControllerProvider.notifier).loadProjects();
                ref.invalidate(contractMembersProvider(project.id));
                if (mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Informasi proyek berhasil diperbarui.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF001AFF),
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan'),
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

    final projectsState = ref.watch(contractsControllerProvider);
    final projects = projectsState.valueOrNull ?? [];
    final project = projects.firstWhere(
      (p) => p.id == widget.contractId,
      orElse: () => ContractModel(
        id: widget.contractId,
        type: '',
        name: 'Memuat...',
        location: '',
        status: '',
        imageUrl: '',
        description: '',
        owner: '',
        supervisor: '',
        createdAt: '',
        startDate: '',
        endDate: '',
        dinas: [],
        fundingSource: '',
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
          'Detail Kegiatan / Kontrak',
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
          if (!isExternal) _buildAdministrasiTabContent(project, userRole, userName),
        ],
      ),
      floatingActionButton: (_tabController?.index == 1 && userRole.canManageAdministration)
          ? FloatingActionButton(
              onPressed: () => _showAddFolderDialog(project.id, null),
              backgroundColor: const Color(0xFF001AFF),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
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

  Widget _buildUmumTabContent(ContractModel p, Color badgeBgColor, Color badgeDotColor, Color badgeTextColor, AppRole role) {
    final photo = p.imageUrl;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Status Badge
          Container(
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
          
          const SizedBox(height: 12),
          
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
          
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Spesifikasi Kontrak',
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Color(0xFF1E1E1E), fontFamily: 'Inter'),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 5. Specifications Table Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
            ),
            child: Column(
              children: [
                _buildTableRow('Tipe Kontrak', p.type),
                _buildTableRow('Instansi Jasa', p.dinas.join(', ')),
                _buildTableRow('Sumber Dana', p.fundingSource),
                _buildTableRow('Konsultan Pengawas', p.supervisor),
                _buildTableRow('Deskripsi', p.description, isLast: true, isLongText: true),
              ],
            ),
          ),
          
          const SizedBox(height: 26),

          // 6. Tim Kontrak Section — hanya untuk Dinas & Konsultan
          if (role == AppRole.dinas || role == AppRole.konsultan)
            _buildTimProyekSection(p.id, role),

          if (role == AppRole.dinas || role == AppRole.konsultan)
            const SizedBox(height: 28),
          
          // 7. Proyek (Pekerjaan Fisik)
          _buildPekerjaanFisikTabContent(p, role),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  Widget _buildAdministrasiTabContent(ContractModel p, AppRole role, String userName) {
    return _FolderListWidget(
      contractId: p.id,
      projectId: null,
      role: role,
      userName: userName,
      onUpload: _showUploadDialog,
      onAction: _showDocumentActionsBottomSheet,
      onEdit: (f) => _showEditFolderDialog(p.id, null, f),
      onDelete: (f) => _showDeleteFolderDialog(p.id, null, f),
    );
  }

  void _showAddFolderDialog(String contractId, String? projectId) {
    final folderController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Tambah Folder', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16)),
          content: TextField(
            controller: folderController,
            decoration: InputDecoration(
              hintText: 'Nama Folder',
              hintStyle: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF8E8E93)),
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Color(0xFF8E8E93), fontFamily: 'Inter', fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () {
                if (folderController.text.isNotEmpty) {
                  final contextId = projectId == null ? contractId : '$contractId:$projectId';
                  ref.read(foldersControllerProvider(contextId).notifier).addFolder(folderController.text);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF001AFF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Tambah', style: TextStyle(color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
            ),
          ],
        );
      }
    );
  }

  void _showEditFolderDialog(String contractId, String? projectId, FolderModel folder) {
    final nameCtrl = TextEditingController(text: folder.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah Nama Folder', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16)),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Nama Folder Baru'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                final contextId = projectId == null ? contractId : '$contractId:$projectId';
                ref.read(foldersControllerProvider(contextId).notifier).updateFolderName(folder.id, nameCtrl.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Color(0xFF001AFF), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDeleteFolderDialog(String contractId, String? projectId, FolderModel folder) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Folder', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text('Apakah Anda yakin ingin menghapus folder "${folder.name}"? Semua dokumen di dalamnya akan ikut terhapus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              final contextId = projectId == null ? contractId : '$contractId:$projectId';
              ref.read(foldersControllerProvider(contextId).notifier).deleteFolder(folder.id);
              Navigator.pop(ctx);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPekerjaanFisikTabContent(ContractModel p, AppRole role) {
    final asyncActivities = ref.watch(projectsProvider(p.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Proyek', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), fontFamily: 'Inter')),
              if (role.canCreateProject)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddProjectScreen(contractId: p.id)),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF001AFF).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Color(0xFF001AFF), size: 15),
                        SizedBox(width: 4),
                        Text('Tambah', style: TextStyle(fontFamily: 'Inter', fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF001AFF))),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          asyncActivities.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
            data: (activities) {
              if (activities.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE8E8E8)),
                  ),
                  child: const Center(
                    child: Text('Belum ada proyek yang didaftarkan pada kontrak ini.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF8E8E93))),
                  ),
                );
              }
              
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final act = activities[index];
                  return GestureDetector(
                    onTap: () {
                      context.push('/physical_activities/${act.id}', extra: act);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                        boxShadow: const [
                          BoxShadow(color: Color(0x04000000), blurRadius: 10, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(act.name, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E1E1E))),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF8E8E93)),
                                    const SizedBox(width: 4),
                                    Text(act.location, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Color(0xFF8E8E93))),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.engineering_outlined, size: 12, color: Color(0xFF8E8E93)),
                                    const SizedBox(width: 4),
                                    Expanded(child: Text(act.contractor, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Color(0xFF8E8E93)), overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F9EE),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.show_chart_rounded, size: 12, color: Color(0xFF00C853)),
                                const SizedBox(width: 4),
                                Text('${(act.physicalProgress * 100).toInt()}%', style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF00C853))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
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
  Widget _buildTimProyekSection(String contractId, AppRole role) {
    final membersAsync = ref.watch(contractMembersProvider(contractId));
    final allUsersAsync = ref.watch(allUsersProvider);

    return membersAsync.when(
      loading: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
      error: (e, _) => Text('Error memuat tim: $e', style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.red)),
      data: (allMembers) {
        final allUsers = allUsersAsync.valueOrNull ?? [];
        final members = allMembers.where((m) {
          final user = allUsers.where((u) => u.id == m.userId).firstOrNull;
          return user?.role != AppRole.kontraktor;
        }).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tim Kontrak', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Color(0xFF1E1E1E), fontFamily: 'Inter')),
                if (role.canManageProjects)
                  GestureDetector(
                    onTap: () => _showKelolaTim(contractId, members, allUsers),
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
    String contractId,
    List<dynamic> currentMembers,
    List<UserModel> allUsers,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _KelolaTimSheet(
        contractId: contractId,
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
  final String contractId;
  final List<UserModel> allUsers;
  final WidgetRef ref;

  const _KelolaTimSheet({
    required this.contractId,
    required this.allUsers,
    required this.ref,
  });

  @override
  ConsumerState<_KelolaTimSheet> createState() => _KelolaTimSheetState();
}

class _KelolaTimSheetState extends ConsumerState<_KelolaTimSheet> {
  UserModel? _selectedUser;
  bool _isAdding = false;

  Color _roleColor(AppRole role) => switch (role) {
    AppRole.konsultan  => const Color(0xFF00C853),
    AppRole.kontraktor => const Color(0xFF001AFF),
    AppRole.dinas      => const Color(0xFFFF3D00),
    AppRole.eksternal  => const Color(0xFFAB47BC),
  };

  /// Jabatan di proyek otomatis ditentukan dari role akun
  String _autoRoleLabel(AppRole role) => switch (role) {
    AppRole.konsultan  => 'Pengawas',
    AppRole.kontraktor => 'Pelaksana',
    AppRole.dinas      => 'Pengawas Dinas',
    AppRole.eksternal  => 'Eksternal',
  };

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(contractMembersProvider(widget.contractId));

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
                                          await ref.read(contractsControllerProvider.notifier).removeMember(widget.contractId, m.userId);
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
                    // Dinas otomatis masuk — jangan tampilkan di dropdown
                    final availableUsers = widget.allUsers
                        .where((u) => !currentMemberIds.contains(u.id) && u.role != AppRole.dinas)
                        .toList();

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

                        const SizedBox(height: 12),

                        // ── Jabatan info (otomatis dari role akun) ──────
                        if (_selectedUser != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline_rounded, size: 15, color: Color(0xFF6B7280)),
                                const SizedBox(width: 8),
                                Text(
                                  'Jabatan: ${_autoRoleLabel(_selectedUser!.role)}',
                                  style: const TextStyle(fontFamily: 'Inter', fontSize: 12.5, color: Color(0xFF6B7280)),
                                ),
                              ],
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
                              await ref.read(contractsControllerProvider.notifier).addMember(
                                widget.contractId,
                                _selectedUser!.id,
                                _autoRoleLabel(_selectedUser!.role),
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

class _FolderListWidget extends ConsumerWidget {
  final String contractId;
  final String? projectId;
  final AppRole role;
  final String userName;
  final void Function(FolderModel, AppRole, String) onUpload;
  final void Function(DocumentModel, AppRole, String) onAction;
  final void Function(FolderModel) onEdit;
  final void Function(FolderModel) onDelete;

  const _FolderListWidget({
    required this.contractId,
    this.projectId,
    required this.role,
    required this.userName,
    required this.onUpload,
    required this.onAction,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contextId = projectId == null ? contractId : "$contractId:$projectId";
    final foldersAsync = ref.watch(foldersControllerProvider(contextId));

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Folder Administrasi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), fontFamily: 'Inter')),
            ],
          ),
          const SizedBox(height: 16),
          foldersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error: $e')),
            data: (folders) {
              if (folders.isEmpty) {
                return const Center(child: Text('Belum ada folder.', style: TextStyle(color: Colors.grey, fontSize: 13)));
              }
              return Column(
                children: folders.map((folder) {
                  return _FolderItemConsumer(
                    folder: folder,
                    role: role,
                    userName: userName,
                    onUpload: onUpload,
                    onAction: onAction,
                    onEdit: onEdit,
                    onDelete: onDelete,
                  );
                }).toList(),
              );
            }
          ),
        ],
      ),
    );
  }
}

class _FolderItemConsumer extends ConsumerWidget {
  final FolderModel folder;
  final AppRole role;
  final String userName;
  final void Function(FolderModel, AppRole, String) onUpload;
  final void Function(DocumentModel, AppRole, String) onAction;
  final void Function(FolderModel) onEdit;
  final void Function(FolderModel) onDelete;

  const _FolderItemConsumer({
    required this.folder,
    required this.role,
    required this.userName,
    required this.onUpload,
    required this.onAction,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allDocsState = ref.watch(documentsControllerProvider);
    final allDocs = allDocsState.valueOrNull ?? [];
    final folderDocs = allDocs.where((d) => d.folderId == folder.id).toList();

    return DynamicFolderItem(
      folderName: folder.name,
      fileCount: folderDocs.length,
      documents: folderDocs,
      showUploadButton: role.canManageAdministration,
      isDefaultFolder: folder.isDefault,
      onUploadTap: () => onUpload(folder, role, userName),
      onDocumentTap: (doc) => onAction(doc, role, userName),
      onEditFolderTap: () => onEdit(folder),
      onDeleteFolderTap: () => onDelete(folder),
    );
  }
}

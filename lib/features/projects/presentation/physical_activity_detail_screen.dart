import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/enums/app_role.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/models/project_model.dart';
import '../data/models/document_model.dart';
import '../data/models/folder_model.dart';
import 'project_controller.dart';
import 'folder_controller.dart';
import '../../../widgets/dynamic_folder_item.dart';
import 'package:uuid/uuid.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final ProjectModel activity;

  const ProjectDetailScreen({super.key, required this.activity});

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  void _showAddFolderDialog(String activityId, String projectId) {
    final folderController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Tambah Folder Pelaporan', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16)),
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
                  final contextId = '$activityId:$projectId';
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

  void _showEditFolderDialog(FolderModel folder) {
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
                final contextId = '${widget.activity.contractId}:${widget.activity.id}';
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

  void _showDeleteFolderDialog(FolderModel folder) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Folder', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text('Apakah Anda yakin ingin menghapus folder "${folder.name}"? Semua dokumen di dalamnya akan ikut terhapus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              final contextId = '${widget.activity.contractId}:${widget.activity.id}';
              ref.read(foldersControllerProvider(contextId).notifier).deleteFolder(folder.id);
              Navigator.pop(ctx);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

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
                decoration: const InputDecoration(labelText: 'Nama File (tanpa ekstensi)', hintText: 'Laporan_Mingguan'),
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
                  contractId: widget.activity.contractId,
                  projectId: folder.projectId,
                  folderId: folder.id,
                  name: filename,
                  fileUrl: '/documents/physical/$filename',
                  fileSize: '1.2 MB',
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

  void _showDocumentActions(DocumentModel doc, AppRole role, String userName) {
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
              if (role.canManageAdministration)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Color(0xFFFF3D00)),
                  title: const Text('Hapus Permanen', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Inter', color: Color(0xFFFF3D00))),
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(documentsControllerProvider.notifier).deleteDocument(doc.id, userName, role.label);
                  },
                ),
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final role = user?.role ?? AppRole.eksternal;
    final userName = user?.name ?? 'User';
    final progress = widget.activity.physicalProgress;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.activity.name, style: const TextStyle(color: Color(0xFF1E1E1E), fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress Bar Card
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Progress Fisik', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 14)),
                      Text('${(progress * 100).toInt()}%', style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF00C853))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFF0F0F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00C853)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Administrasi
            _buildDokumenPelaporanContent(role, userName),
          ],
        ),
      ),
      floatingActionButton: role.canCreateProject
          ? FloatingActionButton(
              onPressed: () => _showAddFolderDialog(widget.activity.contractId, widget.activity.id),
              backgroundColor: const Color(0xFF001AFF),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildDokumenPelaporanContent(AppRole role, String userName) {
    final contextId = '${widget.activity.contractId}:${widget.activity.id}';
    final foldersAsync = ref.watch(foldersControllerProvider(contextId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Folder Pelaporan (Administrasi)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), fontFamily: 'Inter')),
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
                return _PhysicalFolderConsumer(
                  folder: folder,
                  role: role,
                  userName: userName,
                  onUpload: _showUploadDialog,
                  onAction: _showDocumentActions,
                  onEdit: _showEditFolderDialog,
                  onDelete: _showDeleteFolderDialog,
                );
              }).toList(),
            );
          }
        ),
      ],
    );
  }
}

class _PhysicalFolderConsumer extends ConsumerWidget {
  final FolderModel folder;
  final AppRole role;
  final String userName;
  final void Function(FolderModel, AppRole, String) onUpload;
  final void Function(DocumentModel, AppRole, String) onAction;
  final void Function(FolderModel) onEdit;
  final void Function(FolderModel) onDelete;

  const _PhysicalFolderConsumer({
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

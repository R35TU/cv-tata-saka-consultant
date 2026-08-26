import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/isar_database_service.dart';
import '../../../../core/database/isar_models.dart';
import 'package:isar/isar.dart';
import '../data/models/project_model.dart';
import 'project_controller.dart';

class AddContractScreen extends ConsumerStatefulWidget {
  final ContractModel? contract;
  const AddContractScreen({super.key, this.contract});

  @override
  ConsumerState<AddContractScreen> createState() => _AddContractScreenState();
}

class _AddContractScreenState extends ConsumerState<AddContractScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final List<TextEditingController> _dinasControllers = [TextEditingController(text: 'Pemerintah Kabupaten Banyumas')];
  final _sourceCtrl = TextEditingController(text: 'APBD 2026');
  
  String _selectedSupervisor = '';
  String _selectedType = 'Pengawasan Teknis';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 180));
  String? _selectedImagePath;

  List<String> _konsultanUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  DateTime _parseDate(String dateStr) {
    try {
      final parts = dateStr.split(' ');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final monthStr = parts[1];
        final year = int.parse(parts[2]);
        final months = [
          '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
          'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
        ];
        final month = months.indexOf(monthStr);
        if (month > 0) return DateTime(year, month, day);
      }
    } catch (_) {}
    return DateTime.now();
  }

  Future<void> _loadData() async {
    final isar = await IsarDatabaseService.db;
    final allUsers = await isar.userIsars.where().findAll();
    final konsultanUsers = allUsers.where((u) => u.role == 'Konsultan').map((u) => u.name).toList();
    
    if (konsultanUsers.isEmpty) konsultanUsers.add('CV. Tata Saka Konsultan');
    
    setState(() {
      _konsultanUsers = konsultanUsers;
      
      if (widget.contract != null) {
        _nameCtrl.text = widget.contract!.name;
        _locCtrl.text = widget.contract!.location;
        _descCtrl.text = widget.contract!.description;
        _sourceCtrl.text = widget.contract!.fundingSource;
        _selectedType = widget.contract!.type;
        _startDate = _parseDate(widget.contract!.startDate);
        _endDate = _parseDate(widget.contract!.endDate);
        _selectedImagePath = widget.contract!.imageUrl.isNotEmpty ? widget.contract!.imageUrl : null;
        
        if (widget.contract!.dinas.isNotEmpty) {
          _dinasControllers.clear();
          for (var d in widget.contract!.dinas) {
            _dinasControllers.add(TextEditingController(text: d));
          }
        }
        
        _selectedSupervisor = widget.contract!.supervisor;
        if (!_konsultanUsers.contains(_selectedSupervisor)) {
          _konsultanUsers.add(_selectedSupervisor);
        }
      } else {
        _selectedSupervisor = konsultanUsers.first;
      }
      
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locCtrl.dispose();
    _descCtrl.dispose();
    for (var ctrl in _dinasControllers) {
      ctrl.dispose();
    }
    _sourceCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    final months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E1E1E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.contract != null ? 'Ubah Kontrak' : 'Tambah Kontrak Baru',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1E1E1E),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Type
              DropdownButtonFormField<String>(
                value: _selectedType,
                style: const TextStyle(fontSize: 13, fontFamily: 'Inter', color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Jenis Kegiatan',
                  labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                  prefixIcon: const Icon(Icons.category_rounded, size: 20, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                items: ['Pengawasan Teknis', 'Perencanaan Teknis'].map((name) => 
                  DropdownMenuItem(value: name, child: Text(name))
                ).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
              ),
              const SizedBox(height: 16),

              // Project Name
              TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(fontSize: 13, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  labelText: 'Nama Kegiatan / Kontrak',
                  labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                  prefixIcon: const Icon(Icons.business_rounded, size: 20, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nama kegiatan wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locCtrl,
                style: const TextStyle(fontSize: 13, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  labelText: 'Lokasi',
                  labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                  prefixIcon: const Icon(Icons.location_on_rounded, size: 20, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Lokasi wajib diisi' : null,
              ),
              const SizedBox(height: 16),



              // Date Pickers Row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (d != null) {
                          setState(() {
                            _startDate = d;
                            if (_endDate.isBefore(_startDate)) {
                              _endDate = _startDate.add(const Duration(days: 30));
                            }
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Tgl Mulai',
                            labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                            hintText: _formatDate(_startDate),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            prefixIcon: const Icon(Icons.calendar_today_rounded, size: 20, color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          style: const TextStyle(fontSize: 12.5, fontFamily: 'Inter', color: Colors.black),
                          controller: TextEditingController(text: _formatDate(_startDate)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _endDate,
                          firstDate: _startDate,
                          lastDate: DateTime(2030),
                        );
                        if (d != null) {
                          setState(() => _endDate = d);
                        }
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Tgl Selesai',
                            labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                            hintText: _formatDate(_endDate),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            prefixIcon: const Icon(Icons.calendar_month_rounded, size: 20, color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          style: const TextStyle(fontSize: 12.5, fontFamily: 'Inter', color: Colors.black),
                          controller: TextEditingController(text: _formatDate(_endDate)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Owner detail (Instansi Pemilik) Dynamic List
              const Text(
                'Instansi / Dinas Terkait',
                style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
              ),
              const SizedBox(height: 12),
              ..._dinasControllers.asMap().entries.map((entry) {
                int idx = entry.key;
                TextEditingController ctrl = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: ctrl,
                          style: const TextStyle(fontSize: 13, fontFamily: 'Inter'),
                          decoration: InputDecoration(
                            labelText: 'Nama Dinas',
                            labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                            prefixIcon: const Icon(Icons.account_balance_rounded, size: 20, color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                        ),
                      ),
                      if (_dinasControllers.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _dinasControllers.removeAt(idx).dispose();
                              });
                            },
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            tooltip: 'Hapus Dinas',
                          ),
                        ),
                    ],
                  ),
                );
              }),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _dinasControllers.add(TextEditingController());
                    });
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('Tambah Dinas Lain', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF001AFF),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Funding source
              TextFormField(
                controller: _sourceCtrl,
                style: const TextStyle(fontSize: 13, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  labelText: 'Sumber Dana',
                  labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                  prefixIcon: const Icon(Icons.monetization_on_rounded, size: 20, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                style: const TextStyle(fontSize: 13, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  labelText: 'Deskripsi Kegiatan',
                  labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ]
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;
              final newProj = ContractModel(
                id: widget.contract?.id ?? const Uuid().v4(),
                type: _selectedType,
                name: _nameCtrl.text,
                location: _locCtrl.text,
                status: widget.contract?.status ?? 'Progres',
                imageUrl: _selectedImagePath ?? widget.contract?.imageUrl ?? '',
                description: _descCtrl.text,
                owner: widget.contract?.owner ?? '',
                supervisor: _selectedSupervisor,
                createdAt: widget.contract?.createdAt ?? DateTime.now().toString().substring(0, 10),
                startDate: _formatDate(_startDate),
                endDate: _formatDate(_endDate),
                dinas: _dinasControllers.map((e) => e.text.trim()).where((e) => e.isNotEmpty).toList(),
                fundingSource: _sourceCtrl.text,
                isArchived: widget.contract?.isArchived ?? false,
              );
              if (widget.contract != null) {
                await ref.read(contractsControllerProvider.notifier).updateContract(newProj);
              } else {
                await ref.read(contractsControllerProvider.notifier).addContract(newProj);
              }
              if (mounted) Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF001AFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              elevation: 0,
            ),
            child: const Text('Simpan Kontrak', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ),
      ),
    );
  }
}

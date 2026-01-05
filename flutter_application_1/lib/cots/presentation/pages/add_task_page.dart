import 'package:flutter/material.dart';
import '../../design_system/styles.dart';
import '../widgets/custom_button.dart';
import '../../services/task_service.dart'; // Pakai Service
import '../../models/task.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TaskService _taskService = TaskService(); // Service
  
  String? _selectedCourse;
  DateTime? _selectedDate;
  bool _isTaskDone = false;
  bool _isLoading = false; // Loading state

  final List<String> _courses = ['Pemrograman Lanjut', 'Rekayasa Perangkat Lunak', 'Metodologi Penelitian', 'UI Engineering', 'RPL'];

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context, initialDate: DateTime.now(), firstDate: DateTime(2024), lastDate: DateTime(2030)
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String _formatDate(DateTime date) {
    List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.text), onPressed: () => Navigator.pop(context)),
        title: const Text('Tambah Tugas', style: AppTextStyles.section),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Judul Tugas'),
                    TextFormField(
                      controller: _titleController,
                      validator: (val) => val == null || val.isEmpty ? 'Judul wajib diisi' : null,
                      decoration: _inputDecor('Masukkan judul tugas'),
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Mata Kuliah'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCourse, hint: const Text('Pilih mata kuliah'), isExpanded: true,
                          items: _courses.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                          onChanged: (val) => setState(() => _selectedCourse = val),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Deadline'),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_selectedDate == null ? 'Pilih tanggal' : _formatDate(_selectedDate!), style: TextStyle(color: _selectedDate == null ? AppColors.muted : AppColors.text)),
                            const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.text),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Catatan'),
                    TextFormField(
                      controller: _noteController, maxLines: 4, decoration: _inputDecor('Catatan tambahan (opsional)'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            color: AppColors.background,
            child: Row(
              children: [
                Expanded(child: CustomButton(text: 'Batal', onTap: () => Navigator.pop(context), isSecondary: true)),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: _isLoading ? 'Menyimpan...' : 'Simpan', 
                    onTap: _isLoading ? () {} : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _isLoading = true);
                        try {
                          String dateStr = _selectedDate != null ? _formatDate(_selectedDate!) : "-";
                          Task newTask = Task(
                            title: _titleController.text,
                            course: _selectedCourse ?? 'Umum',
                            deadline: dateStr,
                            status: 'BERJALAN',
                            note: _noteController.text,
                            isDone: false,
                          );

                          // KIRIM KE API
                          await _taskService.addTask(newTask);

                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tugas berhasil disimpan ke Server!')));
                          Navigator.pop(context, true); 
                        } catch (e) {
                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
                        } finally {
                           if (mounted) setState(() => _isLoading = false);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: AppTextStyles.section.copyWith(fontSize: 14)));
  InputDecoration _inputDecor(String hint) => InputDecoration(hintText: hint, filled: true, fillColor: AppColors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)));
}
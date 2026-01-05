import 'package:flutter/material.dart';
import '../../design_system/styles.dart';
import '../widgets/custom_button.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';

class DetailTaskPage extends StatefulWidget {
  final Task task; // Menerima Object Task

  const DetailTaskPage({super.key, required this.task});

  @override
  State<DetailTaskPage> createState() => _DetailTaskPageState();
}

class _DetailTaskPageState extends State<DetailTaskPage> {
  late bool isChecked;
  final TaskService _taskService = TaskService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    isChecked = widget.task.status == 'SELESAI';
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.task;
    String statusLabel = isChecked ? 'Selesai' : 'Berjalan'; // Simpel visual
    Color statusBg = isChecked ? AppColors.successBg : AppColors.runningBg;
    Color statusColor = isChecked ? AppColors.success : AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.text), onPressed: () => Navigator.pop(context)),
        title: const Text('Detail Tugas', style: AppTextStyles.section), centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Judul Tugas', style: AppTextStyles.caption),
                        Text(t.title, style: AppTextStyles.title),
                        const SizedBox(height: 20),
                        const Text('Mata Kuliah', style: AppTextStyles.caption),
                        Text(t.course, style: AppTextStyles.body),
                        const SizedBox(height: 20),
                        const Text('Deadline', style: AppTextStyles.caption),
                        Text(t.deadline, style: AppTextStyles.body),
                        const SizedBox(height: 20),
                        const Text('Status', style: AppTextStyles.caption),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(100)),
                          child: Text(statusLabel, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Checkbox(value: isChecked, activeColor: AppColors.primary, onChanged: (val) => setState(() => isChecked = val!)),
                      const SizedBox(width: 8),
                      const Text('Tugas sudah selesai', style: AppTextStyles.body),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Catatan', style: AppTextStyles.section),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                    child: Text(t.note.isEmpty ? 'Tidak ada catatan.' : t.note, style: AppTextStyles.body),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: CustomButton(
              text: _isLoading ? 'Menyimpan...' : 'Simpan Perubahan',
              onTap: _isLoading ? () {} : () async {
                setState(() => _isLoading = true);
                try {
                  // UPDATE KE SERVER
                  await _taskService.updateTask(t.id, isDone: isChecked);
                  if(!mounted) return;
                  Navigator.pop(context, true);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
                } finally {
                  if(mounted) setState(() => _isLoading = false);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
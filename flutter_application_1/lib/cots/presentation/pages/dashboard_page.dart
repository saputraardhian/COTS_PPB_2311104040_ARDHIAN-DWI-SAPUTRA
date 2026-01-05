import 'package:flutter/material.dart';
import '../../design_system/styles.dart';
import '../widgets/custom_button.dart';
import 'list_task_page.dart';
import 'add_task_page.dart';
import 'detail_task_page.dart';
import '../../services/task_service.dart'; // Ganti TaskData jadi TaskService
import '../../models/task.dart'; // Import Model Task

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TaskService _taskService = TaskService(); // Panggil Service

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: FutureBuilder<List<Task>>( // Gunakan FutureBuilder untuk ambil data API
            future: _taskService.getTasks(), // Panggil fungsi GET API
            builder: (context, snapshot) {
              
              // 1. TAMPILAN LOADING
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // 2. TAMPILAN ERROR
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              // 3. DATA BERHASIL DIMUAT
              final tasks = snapshot.data ?? [];
              
              // Hitung Statistik
              int totalTugas = tasks.length;
              int tugasSelesai = tasks.where((t) => t.status == 'SELESAI').length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tugas Besar', style: AppTextStyles.title),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ListTaskPage()))
                              .then((_) => setState(() {})); 
                        },
                        child: Text('Daftar Tugas', style: AppTextStyles.body.copyWith(
                          color: AppColors.primary, fontWeight: FontWeight.w600
                        )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // STATS GRID
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Total Tugas', '$totalTugas')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('Selesai', '$tugasSelesai')),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // SECTION TUGAS TERDEKAT
                  const Text('Tugas Terdekat', style: AppTextStyles.section),
                  const SizedBox(height: 16),

                  // LIST TUGAS (Ambil 3 Teratas)
                  Expanded(
                    child: tasks.isEmpty 
                    ? const Center(child: Text("Belum ada tugas"))
                    : ListView.builder(
                      itemCount: tasks.length > 3 ? 3 : tasks.length,
                      itemBuilder: (context, index) {
                        return _buildTaskCard(context, tasks[index]);
                      },
                    ),
                  ),

                  // TOMBOL TAMBAH
                  CustomButton(
                    text: 'Tambah Tugas',
                    onTap: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (_) => const AddTaskPage())
                      ).then((value) {
                        if (value == true) setState(() {}); 
                      });
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String count) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption.copyWith(fontSize: 14)),
          const SizedBox(height: 8),
          Text(count, style: AppTextStyles.title.copyWith(fontSize: 32)),
        ],
      ),
    );
  }

  // UPDATE: Menerima object 'Task' (Bukan Map lagi)
  Widget _buildTaskCard(BuildContext context, Task task) {
    bool isDone = task.status == 'SELESAI';
    bool isLate = task.status == 'TERLAMBAT' || (task.status != 'SELESAI' && _isOverdue(task.deadline));
    
    // Warna Status
    Color statusColor = isDone ? AppColors.success : (isLate ? AppColors.danger : AppColors.primary);
    Color statusBg = isDone ? AppColors.successBg : (isLate ? const Color(0xFFFEE2E2) : AppColors.runningBg);
    String statusText = isDone ? 'Selesai' : (isLate ? 'Terlambat' : 'Berjalan');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => DetailTaskPage(task: task))
        ).then((_) => setState(() {})); 
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: AppTextStyles.section.copyWith(fontSize: 14, height: 1.2)),
                  const SizedBox(height: 4),
                  Text(task.course, style: AppTextStyles.caption),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 14, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Text('Deadline: ${task.deadline}', style: AppTextStyles.caption.copyWith(color: AppColors.danger)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusText,
                style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Cek Tanggal
  bool _isOverdue(String dateStr) {
    try {
      if (dateStr == '-') return false;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      List<String> parts = dateStr.split(' ');
      if (parts.length < 3) return false;
      int day = int.parse(parts[0]);
      Map<String, int> months = {'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'Mei': 5, 'Jun': 6, 'Jul': 7, 'Ags': 8, 'Sep': 9, 'Okt': 10, 'Nov': 11, 'Des': 12};
      int month = months[parts[1]] ?? 1;
      return DateTime(int.parse(parts[2]), month, day).isBefore(today);
    } catch (e) { return false; }
  }
}
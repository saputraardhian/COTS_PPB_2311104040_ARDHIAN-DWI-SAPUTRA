import 'package:flutter/material.dart';
import '../../design_system/styles.dart';
import 'add_task_page.dart'; 
import 'detail_task_page.dart';
import '../../services/task_service.dart';
import '../../models/task.dart';

class ListTaskPage extends StatefulWidget {
  const ListTaskPage({super.key});

  @override
  State<ListTaskPage> createState() => _ListTaskPageState();
}

class _ListTaskPageState extends State<ListTaskPage> {
  final TaskService _taskService = TaskService();
  
  // State untuk Data
  late Future<List<Task>> _tasksFuture;
  
  // State untuk Filter & Search
  String _activeFilter = 'Semua';
  String _searchQuery = ''; // <-- Variabel Pencarian

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Ambil data saat halaman dibuka
  }

  // Fungsi untuk refresh data API
  void _loadTasks() {
    setState(() {
      _tasksFuture = _taskService.getTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Daftar Tugas', style: AppTextStyles.section),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTaskPage()))
                  .then((value) { 
                    // Refresh data jika ada tugas baru
                    if (value == true) _loadTasks(); 
                  });
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                children: [
                  Text('Tambah', style: AppTextStyles.body.copyWith(color: AppColors.primary)),
                  const SizedBox(width: 4),
                  Container(
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary)),
                    child: const Icon(Icons.add, size: 16, color: AppColors.primary),
                  )
                ],
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // SEARCH BAR (SEKARANG SUDAH BERFUNGSI)
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface, 
                borderRadius: BorderRadius.circular(12), 
                border: Border.all(color: AppColors.border)
              ),
              child: TextField( // <-- Ganti const TextField jadi TextField biasa
                onChanged: (value) {
                  // Update state pencarian setiap ngetik
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Cari tugas atau mata kuliah...',
                  hintStyle: TextStyle(color: AppColors.muted, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: AppColors.muted),
                  border: InputBorder.none, 
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // FILTER CHIPS
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildChip('Semua'),
                  _buildChip('Berjalan'),
                  _buildChip('Selesai'),
                  _buildChip('Terlambat'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // LIST DATA (API + SEARCH FILTER)
            Expanded(
              child: FutureBuilder<List<Task>>(
                future: _tasksFuture, // Pakai variabel future agar tidak reload saat ngetik
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  final allTasks = snapshot.data ?? [];
                  
                  // --- LOGIKA FILTER GABUNGAN (STATUS + SEARCH) ---
                  final filteredTasks = allTasks.where((task) {
                     // 1. Cek Status
                     bool matchStatus = _activeFilter == 'Semua' || 
                                        task.status.toUpperCase() == _activeFilter.toUpperCase();
                     
                     // 2. Cek Pencarian (Case Insensitive)
                     bool matchSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                                        task.course.toLowerCase().contains(_searchQuery.toLowerCase());

                     // Harus cocok dua-duanya
                     return matchStatus && matchSearch;
                  }).toList();

                  if (filteredTasks.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isNotEmpty 
                          ? "Tidak ditemukan '$_searchQuery'" 
                          : "Tidak ada tugas $_activeFilter", 
                        style: AppTextStyles.caption
                      )
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      return _buildListItem(context, filteredTasks[index]);
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    final isActive = _activeFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: isActive ? null : Border.all(color: AppColors.border),
        ),
        child: Text(label, style: TextStyle(color: isActive ? Colors.white : AppColors.muted, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, Task task) {
    bool isDone = task.status == 'SELESAI';
    bool isLate = task.status == 'TERLAMBAT';
    Color dotColor = isDone ? AppColors.success : (isLate ? AppColors.danger : AppColors.primary);

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => DetailTaskPage(task: task)))
            .then((_) => _loadTasks()); // Refresh data setelah kembali dari detail
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.only(top: 4.0), child: CircleAvatar(radius: 5, backgroundColor: dotColor)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: AppTextStyles.section.copyWith(fontSize: 14, height: 1.4)),
                  const SizedBox(height: 4),
                  Text(task.course, style: AppTextStyles.caption),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('${task.deadline} >', style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
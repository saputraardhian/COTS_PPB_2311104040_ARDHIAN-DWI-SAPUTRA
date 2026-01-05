import 'package:flutter/material.dart';

class TaskData {
  // Data Global
  static List<Map<String, dynamic>> tasks = [
    {
      'title': 'Perancangan MVC + Services',
      'course': 'Pemrograman Lanjut',
      'deadline': '18 Jan 2026',
      'status': 'Berjalan',
      'color': Colors.blue,
    },
    {
      'title': 'Integrasi Consume API',
      'course': 'Rekayasa Perangkat Lunak',
      'deadline': '15 Jan 2026',
      'status': 'Berjalan',
      'color': Colors.blue,
    },
    {
      'title': 'Revisi Proposal',
      'course': 'Metodologi Penelitian',
      'deadline': '10 Jan 2026',
      'status': 'Selesai',
      'color': Colors.green,
    },
    // Contoh tugas lama untuk tes Terlambat
    {
      'title': 'Test Tugas Lama',
      'course': 'Metodologi Penelitian',
      'deadline': '1 Jan 2026', // Ini harusnya Terlambat
      'status': 'Berjalan',
      'color': Colors.blue, 
    },
  ];

  // --- LOGIKA BARU UNTUK CEK TERLAMBAT ---
  static void updateOverdueStatus() {
    final now = DateTime.now();
    // Kita reset waktu hari ini ke jam 00:00:00 agar perbandingannya adil (per tanggal)
    final today = DateTime(now.year, now.month, now.day);

    for (var task in tasks) {
      // 1. Lewati jika tugas sudah 'Selesai'
      if (task['status'] == 'Selesai') continue;

      // 2. Parsing Tanggal (Format: "18 Jan 2026")
      try {
        String dateStr = task['deadline'];
        DateTime? deadline = _parseDate(dateStr);

        if (deadline != null) {
          // 3. Cek apakah deadline lebih kecil dari hari ini?
          if (deadline.isBefore(today)) {
            task['status'] = 'Terlambat';
            task['color'] = const Color(0xFFEF4444); // Merah
          } 
          // Opsional: Kembalikan ke 'Berjalan' jika tanggal diedit jadi masa depan
          else if (task['status'] == 'Terlambat' && !deadline.isBefore(today)) {
            task['status'] = 'Berjalan';
            task['color'] = const Color(0xFF2F6BFF); // Biru
          }
        }
      } catch (e) {
        debugPrint("Error parsing date: $e");
      }
    }
  }

  // Helper untuk mengubah string "1 Jan 2026" menjadi DateTime
  static DateTime? _parseDate(String dateStr) {
    try {
      if (dateStr == '-') return null;
      
      List<String> parts = dateStr.split(' ');
      if (parts.length < 3) return null;

      int day = int.parse(parts[0]);
      String monthStr = parts[1];
      int year = int.parse(parts[2]);

      // Map nama bulan ke angka
      Map<String, int> months = {
        'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'Mei': 5, 'Jun': 6,
        'Jul': 7, 'Ags': 8, 'Sep': 9, 'Okt': 10, 'Nov': 11, 'Des': 12
      };

      int month = months[monthStr] ?? 1;

      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }
}
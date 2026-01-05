import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class TaskService {
  // PERBAIKAN 1: Tambahkan path '/rest/v1/tasks' agar mengarah ke tabel yang benar
  static const String baseUrl = 'https://rpblbedyqmnzpowbumzd.supabase.co/rest/v1/tasks';
  
  // PERBAIKAN 2: Pastikan token tersambung (tidak ada enter/spasi di tengah)
  static const String apiKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJwYmxiZWR5cW1uenBvd2J1bXpkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgxMjcxMjYsImV4cCI6MjA3MzcwMzEyNn0.QaMJlyqhZcPorbFUpImZAynz3o2l0xDfq_exf2wUrTs';

  static final Map<String, String> headers = {
    'apikey': apiKey,
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation', // Wajib untuk Supabase
  };

  // 1. GET TASKS
  Future<List<Task>> getTasks({String? status}) async {
    String query = '?select=*';
    if (status != null && status.isNotEmpty && status != 'Semua') {
      // Filter status jika ada
      query += '&status=eq.${status.toUpperCase()}';
    }

    final response = await http.get(
      Uri.parse('$baseUrl$query'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((e) => Task.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data tugas: ${response.statusCode}');
    }
  }

  // 2. ADD TASK
  Future<Task> addTask(Task task) async {
    final body = json.encode({
      'title': task.title,
      'course': task.course,
      'deadline': task.deadline,
      'status': 'BERJALAN',
      'note': task.note,
      'is_done': false,
    });

    final response = await http.post(
      Uri.parse(baseUrl), // URL sudah benar mengarah ke /tasks
      headers: headers,
      body: body,
    );

    if (response.statusCode == 201) {
      List data = json.decode(response.body);
      return Task.fromJson(data[0]);
    } else {
      throw Exception('Gagal menambah tugas: ${response.statusCode}');
    }
  }

  // 3. UPDATE TASK
  Future<bool> updateTask(String id, {bool? isDone, String? note}) async {
    Map<String, dynamic> dataToUpdate = {};

    if (isDone != null) {
      dataToUpdate['is_done'] = isDone;
      dataToUpdate['status'] = isDone ? 'SELESAI' : 'BERJALAN';
    }

    if (note != null) {
      dataToUpdate['note'] = note;
    }

    final response = await http.patch(
      Uri.parse('$baseUrl?id=eq.$id'), // Filter by ID
      headers: headers,
      body: json.encode(dataToUpdate),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      throw Exception('Gagal update tugas: ${response.statusCode}');
    }
  }
}
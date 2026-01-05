import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskController extends ChangeNotifier {
  final TaskService _service = TaskService();
  
  List<Task> _tasks = [];
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  // Mengambil semua tugas
  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _service.getTasks();
    } catch (e) {
      debugPrint("Error fetching tasks: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Menambah tugas baru
  Future<void> addTask(Task task) async {
    try {
      await _service.addTask(task);
      await fetchTasks(); // Refresh list setelah tambah
    } catch (e) {
      debugPrint("Error adding task: $e");
      rethrow;
    }
  }
}
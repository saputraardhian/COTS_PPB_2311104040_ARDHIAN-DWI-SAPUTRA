class Task {
  final String id;
  final String title;
  final String course;
  final String deadline;
  final String status;
  final String note;
  final bool isDone;

  Task({
    this.id = '', // Default empty string jika create baru
    required this.title,
    required this.course,
    required this.deadline,
    required this.status,
    required this.note,
    required this.isDone,
  });

  // Mengubah JSON dari Supabase menjadi Object Task
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      course: json['course'] ?? '',
      deadline: json['deadline'] ?? '',
      status: json['status'] ?? 'BERJALAN',
      note: json['note'] ?? '',
      isDone: json['is_done'] ?? false,
    );
  }

  // Mengubah Object Task menjadi JSON untuk dikirim ke API
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'course': course,
      'deadline': deadline,
      'status': status,
      'note': note,
      'is_done': isDone,
    };
  }
}
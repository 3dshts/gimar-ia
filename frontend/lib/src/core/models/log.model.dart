//frontend/lib/src/models/log_model.dart

class LogModel {
  final String date;
  final String fullName;
  final String user;
  final String email;

  LogModel({
    required this.date,
    required this.fullName,
    required this.user,
    required this.email,
  });

  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      date: json['date'] ?? '',
      fullName: json['fullName'] ?? '',
      user: json['user'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

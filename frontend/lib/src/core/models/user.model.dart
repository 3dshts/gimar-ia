//frontend/lib/src/core/models/user_model.dart


class UserModel {
final String fullName;
final String username;
final String email;


UserModel({
required this.fullName,
required this.username,
required this.email,
});


factory UserModel.fromJson(Map<String, dynamic> json) {
return UserModel(
fullName: json['full_name'] ?? '',
username: json['user'] ?? '',
email: json['email'] ?? '',
);
}
}
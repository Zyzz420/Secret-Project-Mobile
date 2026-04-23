class UserModel {
  final String id;
  final String firstName;
  final String email;
  final String role;
  final String? phoneNumber;

  UserModel({
    required this.id,
    required this.firstName,
    required this.email,
    required this.role,
    this.phoneNumber,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      firstName: json['first_name'],
      email: json['email'],
      role: json['role'],
      phoneNumber: json['phone_number'],
    );
  }
}
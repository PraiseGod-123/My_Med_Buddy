class UserModel {
  final String name;
  final int age;
  final String condition;
  final bool medicationReminders;
  final String email;
  final String phone;
  final List<String> allergies;
  final String emergencyContact;

  UserModel({
    required this.name,
    required this.age,
    required this.condition,
    required this.medicationReminders,
    required this.email,
    required this.phone,
    required this.allergies,
    required this.emergencyContact,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'condition': condition,
      'medicationReminders': medicationReminders,
      'email': email,
      'phone': phone,
      'allergies': allergies,
      'emergencyContact': emergencyContact,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      condition: json['condition'] ?? '',
      medicationReminders: json['medicationReminders'] ?? false,
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      allergies: List<String>.from(json['allergies'] ?? []),
      emergencyContact: json['emergencyContact'] ?? '',
    );
  }
}

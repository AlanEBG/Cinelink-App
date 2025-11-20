import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String userId;
  final String userEmail;
  final List<String> userRoles;

  User({
    required this.userId,
    required this.userEmail,
    required this.userRoles,
  });

  // Getters de utilidad
  String get email => userEmail;
  String get id => userId;
  
  bool get isAdmin => userRoles.contains('Admin');
  bool get isCustomer => userRoles.contains('Customer');
  bool get isManager => userRoles.contains('Manager');
  
  String get primaryRole => userRoles.isNotEmpty ? userRoles.first : 'Customer';
  
  // Iniciales para el avatar (basado en email)
  String get initials {
    final emailParts = userEmail.split('@');
    if (emailParts.isNotEmpty && emailParts[0].length >= 2) {
      return emailParts[0].substring(0, 2).toUpperCase();
    }
    return 'U?';
  }
  
  // Nombre de display (usa el email sin dominio)
  String get displayName {
    final emailParts = userEmail.split('@');
    return emailParts.isNotEmpty ? emailParts[0] : userEmail;
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? userId,
    String? userEmail,
    List<String>? userRoles,
  }) {
    return User(
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      userRoles: userRoles ?? this.userRoles,
    );
  }

  @override
  String toString() {
    return 'User(userId: $userId, userEmail: $userEmail, userRoles: $userRoles)';
  }
}
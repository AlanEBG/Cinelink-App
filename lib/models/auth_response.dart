import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse {
  final User user;
  final String? token;
  final String? accessToken;
  final String? refreshToken;

  AuthResponse({
    required this.user,
    this.token,
    this.accessToken,
    this.refreshToken,
  });

  // Getter para obtener el token de acceso (puede venir como 'token' o 'accessToken')
  String? get access => accessToken ?? token;

  factory AuthResponse.fromJson(Map<String, dynamic> json) => 
      _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);

  @override
  String toString() {
    return 'AuthResponse(user: $user, hasToken: ${access != null})';
  }
}
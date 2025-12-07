import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../app/constant.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Login
  Future<User> login({
    required String email,
    required String password,
  }) async {
    print('[AuthService] ===== INICIO LOGIN =====');
    print('[AuthService] Intentando login con email: $email');
    
    final loginData = {
      'userEmail': email,
      'userPassword': password,
    };
    
    print('[AuthService] Datos de login: $loginData');
    print('[AuthService] Endpoint login: ${AppConstants.loginEndpoint}');
    
    final response = await _apiService.post(
      AppConstants.loginEndpoint,
      data: loginData,
    );
    
    print('[AuthService] Response status: ${response.statusCode}');
    print('[AuthService] Response data: ${response.data}');
    
    // Verificar que el login fue exitoso
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Login falló: ${response.data}');
    }
    
    // El backend devuelve el token directamente como string
    String token;
    if (response.data is String) {
      token = response.data;
    } else if (response.data is Map && response.data.containsKey('token')) {
      token = response.data['token'];
    } else {
      throw Exception('Formato de respuesta inválido: ${response.data}');
    }
    
    print('[AuthService] Token obtenido (primeros 20 chars): ${token.substring(0, 20)}...');
    
    // Guardar token
    await _storage.write(
      key: AppConstants.accessTokenKey,
      value: token,
    );
    print('[AuthService] Token guardado en storage');
    
    // Obtener datos del usuario usando el token
    print('[AuthService] Obteniendo datos del usuario...');
    final user = await getCurrentUser();
    
    // Guardar usuario en cache
    await _storage.write(
      key: AppConstants.userDataKey,
      value: jsonEncode(user.toJson()),
    );
    print('[AuthService] Datos de usuario guardados en cache');
    print('[AuthService] ===== FIN LOGIN =====');
    
    return user;
  }
  
  // Signup/Register
  Future<User> signup({
    required String email,
    required String password,
    String? role,  // Cambiado de List<String>? a String?
  }) async {
    print('[AuthService] ========== INICIO REGISTRO ==========');
    print('[AuthService] Email: $email');
    print('[AuthService] Password length: ${password.length}');
    print('[AuthService] Role solicitado: $role');
    
    // IMPORTANTE: Enviar userRoles como STRING, no como array
    final signupData = {
      'userEmail': email,
      'userPassword': password,
      'userRoles': role ?? AppConstants.defaultRole,  // String en lugar de array
       //'userRoles': role != null ? [role] : [AppConstants.defaultRole]
    };
    
    print('[AuthService] Datos de registro a enviar:');
    print('[AuthService] ${jsonEncode(signupData)}');
    print('[AuthService] Endpoint de registro: ${AppConstants.registerEndpoint}');
    print('[AuthService] URL completa: ${AppConstants.apiBaseUrl}${AppConstants.registerEndpoint}');
    
    try {
      // PASO 1: CREAR EL USUARIO
      print('[AuthService] ----- PASO 1: CREAR USUARIO -----');
      final response = await _apiService.post(
        AppConstants.registerEndpoint,
        data: signupData,
      );
      
      print('[AuthService] Response status code: ${response.statusCode}');
      print('[AuthService] Response data type: ${response.data.runtimeType}');
      print('[AuthService] Response data: ${response.data}');
      
      // Verificar que la creación fue exitosa
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Error al crear usuario: ${response.data}');
      }
      
      if (response.data == null) {
        throw Exception('Respuesta vacía del servidor al crear usuario');
      }
      
      print('[AuthService] Usuario creado exitosamente en el backend');
      print('[AuthService] ----- FIN PASO 1 -----');
      
      // PASO 2: HACER LOGIN AUTOMÁTICO
      print('[AuthService] ----- PASO 2: LOGIN AUTOMÁTICO -----');
      // Esperar un momento antes de hacer login
      await Future.delayed(const Duration(milliseconds: 800));
      
      print('[AuthService] Iniciando login automático con las mismas credenciales...');
      final user = await login(email: email, password: password);
      
      print('[AuthService] Login automático exitoso');
      print('[AuthService] ========== FIN REGISTRO ==========');
      
      return user;
      
    } catch (e, stackTrace) {
      print('[AuthService] ========== ERROR EN REGISTRO ==========');
      print('[AuthService] Error: $e');
      print('[AuthService] Stack trace: $stackTrace');
      print('[AuthService] ========================================');
      rethrow;
    }
  }
  
  // Obtener usuario actual desde el endpoint /auth/token
  Future<User> getCurrentUser() async {
    print('[AuthService] Obteniendo usuario actual del servidor...');
    print('[AuthService] Endpoint: ${AppConstants.tokenEndpoint}');
    
    try {
      final response = await _apiService.get(AppConstants.tokenEndpoint);
      
      print('[AuthService] Response status: ${response.statusCode}');
      print('[AuthService] Respuesta del servidor: ${response.data}');
      
      // El endpoint /auth/token devuelve { token: '...', user: {...} }
      if (response.data is Map && response.data.containsKey('user')) {
        final userData = response.data['user'];
        print('[AuthService] Datos del usuario extraídos: $userData');
        
        final user = User.fromJson(userData);
        
        // Actualizar cache
        await _storage.write(
          key: AppConstants.userDataKey,
          value: jsonEncode(user.toJson()),
        );
        print('[AuthService] Cache de usuario actualizado');
        
        return user;
      }
      
      throw Exception('Formato de respuesta inválido al obtener usuario: ${response.data}');
    } catch (e, stackTrace) {
      print('[AuthService] Error al obtener usuario actual: $e');
      print('[AuthService] Stack trace: $stackTrace');
      rethrow;
    }
  }
  
  // Verificar cookie con el endpoint /auth/check-cookie
  Future<bool> checkCookie() async {
    try {
      print('[AuthService] Verificando cookie...');
      final response = await _apiService.get(AppConstants.checkCookieEndpoint);
      
      if (response.data is Map && response.data['ok'] == true) {
        print('[AuthService] Cookie válida');
        return true;
      }
      return false;
    } catch (e) {
      print('[AuthService] Cookie inválida o error: $e');
      return false;
    }
  }
  
  // Actualizar usuario
  Future<User> updateUser({
    required String email,
    String? newPassword,
    String? newRole,  // Cambiado de List<String>? a String?
  }) async {
    print('[AuthService] Actualizando usuario: $email');
    
    final data = <String, dynamic>{};
    if (newPassword != null) data['userPassword'] = newPassword;
    if (newRole != null) data['userRoles'] = newRole;  // String en lugar de array
    
    print('[AuthService] Datos de actualización: $data');
    
    final response = await _apiService.patch(
      '${AppConstants.updateUserEndpoint}/$email',
      data: data,
    );
    
    print('[AuthService] Usuario actualizado');
    
    final user = User.fromJson(response.data);
    
    // Actualizar cache
    await _storage.write(
      key: AppConstants.userDataKey,
      value: jsonEncode(user.toJson()),
    );
    
    return user;
  }
  
  // Logout
  Future<void> logout() async {
    print('[AuthService] Cerrando sesión...');
    
    try {
      // Limpiar storage local
      await _storage.delete(key: AppConstants.accessTokenKey);
      await _storage.delete(key: AppConstants.userDataKey);
      
      // Limpiar cookies
      await _apiService.clearCookies();
      
      print('[AuthService] Logout exitoso');
    } catch (e) {
      print('[AuthService] Error al hacer logout: $e');
      // Continuar con el logout local aunque falle
      await _storage.deleteAll();
    }
  }
  
  // Verificar si está autenticado
  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    final isAuth = token != null && token.isNotEmpty;
    print('[AuthService] Usuario autenticado: $isAuth');
    return isAuth;
  }
  
  // Obtener usuario desde cache
  Future<User?> getCachedUser() async {
    try {
      final userData = await _storage.read(key: AppConstants.userDataKey);
      if (userData != null) {
        print('[AuthService] Usuario obtenido del cache');
        return User.fromJson(jsonDecode(userData));
      }
    } catch (e) {
      print('[AuthService] Error al obtener usuario del cache: $e');
    }
    return null;
  }
  
  // Obtener access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: AppConstants.accessTokenKey);
  }
}
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthController with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  AuthState _state = AuthState.initial;
  String? _error;
  
  // Getters
  User? get user => _user;
  AuthState get state => _state;
  String? get error => _error;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;
  
  // Getters para roles
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isCustomer => _user?.isCustomer ?? false;
  bool get isManager => _user?.isManager ?? false;
  
  // Verificar si el usuario tiene un rol específico
  bool hasRole(String role) {
    return _user?.userRoles.contains(role) ?? false;
  }
  
  // Verificar si el usuario tiene alguno de los roles especificados
  bool hasAnyRole(List<String> roles) {
    if (_user == null) return false;
    return roles.any((role) => _user!.userRoles.contains(role));
  }
  
  // Inicializar controller
  Future<void> initialize() async {
    print('[AuthController] Inicializando...');
    _setState(AuthState.loading);
    
    try {
      print('[AuthController] Verificando autenticación...');
      final isAuth = await _authService.isAuthenticated();
      print('[AuthController] Autenticado: $isAuth');
      
      if (isAuth) {
        // Intentar obtener usuario del cache primero
        print('[AuthController] Obteniendo usuario del cache...');
        _user = await _authService.getCachedUser();
        
        if (_user != null) {
          print('[AuthController] Usuario cargado del cache: ${_user?.userEmail}');
          _setState(AuthState.authenticated);
          
          // Actualizar desde el servidor en background
          print('[AuthController] Actualizando desde servidor en background...');
          _authService.getCurrentUser().then((user) {
            _user = user;
            print('[AuthController] Usuario actualizado desde servidor');
            notifyListeners();
          }).catchError((e) {
            print('[AuthController] Error al actualizar usuario: $e');
          });
        } else {
          // Si no hay cache, obtener del servidor
          print('[AuthController] Cache vacío, obteniendo del servidor...');
          try {
            _user = await _authService.getCurrentUser();
            print('[AuthController] Usuario obtenido del servidor: ${_user?.userEmail}');
            _setState(AuthState.authenticated);
          } catch (e) {
            // Si falla obtener del servidor, limpiar token y marcar como no autenticado
            print('[AuthController] Error al obtener usuario: $e');
            await _authService.logout();
            _setState(AuthState.unauthenticated);
          }
        }
      } else {
        print('[AuthController] No hay sesión activa');
        _setState(AuthState.unauthenticated);
      }
    } catch (e, stackTrace) {
      print('[AuthController] Error al inicializar: $e');
      print('[AuthController] Stack trace: $stackTrace');
      _error = e.toString();
      _setState(AuthState.unauthenticated);
    }
  }
  
  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    print('[AuthController] Iniciando login para: $email');
    _setState(AuthState.loading);
    _error = null;
    
    try {
      _user = await _authService.login(
        email: email,
        password: password,
      );
      
      print('[AuthController] Login exitoso: ${_user?.userEmail}');
      print('[AuthController] Roles: ${_user?.userRoles}');
      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      print('[AuthController] Error en login: $e');
      _error = e.toString();
      _setState(AuthState.error);
      
      // Volver a unauthenticated después de un error
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_state == AuthState.error) {
          _setState(AuthState.unauthenticated);
        }
      });
      return false;
    }
  }
  
  // Signup - Cambiado para aceptar String en lugar de List<String>
  Future<bool> signup({
    required String email,
    required String password,
    String? role,  // Cambiado de List<String>? a String?
  }) async {
    print('[AuthController] Iniciando registro para: $email');
    _setState(AuthState.loading);
    _error = null;
    
    try {
      _user = await _authService.signup(
        email: email,
        password: password,
        role: role,  // Pasamos String en lugar de List
      );
      
      print('[AuthController] Registro exitoso: ${_user?.userEmail}');
      print('[AuthController] Roles: ${_user?.userRoles}');
      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      print('[AuthController] Error en registro: $e');
      _error = e.toString();
      _setState(AuthState.error);
      
      // Volver a unauthenticated después de un error
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_state == AuthState.error) {
          _setState(AuthState.unauthenticated);
        }
      });
      return false;
    }
  }
  
  // Logout
  Future<void> logout() async {
    print('[AuthController] Cerrando sesión...');
    _setState(AuthState.loading);
    
    try {
      await _authService.logout();
      print('[AuthController] Logout exitoso');
    } catch (e) {
      print('[AuthController] Error al hacer logout: $e');
    } finally {
      _user = null;
      _error = null;
      _setState(AuthState.unauthenticated);
    }
  }
  
  // Actualizar usuario
  Future<void> refreshUser() async {
    if (_state != AuthState.authenticated) {
      print('[AuthController] No se puede refrescar, no autenticado');
      return;
    }
    
    try {
      print('[AuthController] Refrescando datos del usuario...');
      _user = await _authService.getCurrentUser();
      print('[AuthController] Usuario actualizado');
      notifyListeners();
    } catch (e) {
      print('[AuthController] Error al actualizar usuario: $e');
    }
  }
  
  // Limpiar error
  void clearError() {
    print('[AuthController] Limpiando errores');
    _error = null;
    if (_state == AuthState.error) {
      _setState(AuthState.unauthenticated);
    }
  }
  
  void _setState(AuthState newState) {
    print('[AuthController] Estado: ${_state.name} -> ${newState.name}');
    _state = newState;
    notifyListeners();
  }
}
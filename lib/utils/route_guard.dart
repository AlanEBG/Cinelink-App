import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../app/constant.dart';

class RouteGuard {
  // Verificar si el usuario está autenticado
  static bool requiresAuth(BuildContext context) {
    final authController = context.read<AuthController>();
    
    if (!authController.isAuthenticated) {
      // Redirigir a login
      Navigator.of(context).pushReplacementNamed('/login');
      return false;
    }
    
    return true;
  }
  
  // Verificar si el usuario tiene un rol específico
  static bool requiresRole(BuildContext context, String role) {
    final authController = context.read<AuthController>();
    
    if (!authController.isAuthenticated) {
      Navigator.of(context).pushReplacementNamed('/login');
      return false;
    }
    
    if (!authController.hasRole(role)) {
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No tienes permisos para acceder a esta sección'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
      return false;
    }
    
    return true;
  }
  
  // Verificar si el usuario tiene alguno de los roles especificados
  static bool requiresAnyRole(BuildContext context, List<String> roles) {
    final authController = context.read<AuthController>();
    
    if (!authController.isAuthenticated) {
      Navigator.of(context).pushReplacementNamed('/login');
      return false;
    }
    
    if (!authController.hasAnyRole(roles)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No tienes permisos para acceder a esta sección'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
      return false;
    }
    
    return true;
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        elevation: 0,
      ),
      body: Consumer<AuthController>(
        builder: (context, authController, child) {
          final user = authController.user;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header con gradiente
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        child: Text(
                          user?.initials ?? 'U',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.displayName ?? 'Usuario',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?.userEmail ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: user?.userRoles.map((role) {
                              return Chip(
                                label: Text(role),
                                backgroundColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                              );
                            }).toList() ??
                            [],
                      ),
                    ],
                  ),
                ),

                // Opciones del perfil
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: Text(
                          'Cuenta',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _ProfileOption(
                        icon: Icons.person_outline,
                        title: 'Editar Perfil',
                        subtitle: 'Actualiza tu información personal',
                        color: Colors.blue,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Editar Perfil - En construcción'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      _ProfileOption(
                        icon: Icons.lock_outline,
                        title: 'Cambiar Contraseña',
                        subtitle: 'Actualiza tu contraseña',
                        color: Colors.orange,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Cambiar Contraseña - En construcción'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      _ProfileOption(
                        icon: Icons.payment,
                        title: 'Métodos de Pago',
                        subtitle: 'Administra tus tarjetas',
                        color: Colors.green,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Métodos de Pago - En construcción'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: Text(
                          'Preferencias',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _ProfileOption(
                        icon: Icons.notifications_outlined,
                        title: 'Notificaciones',
                        subtitle: 'Configura tus alertas',
                        color: Colors.purple,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Notificaciones - En construcción'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      _ProfileOption(
                        icon: Icons.language,
                        title: 'Idioma',
                        subtitle: 'Español',
                        color: Colors.teal,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Idioma - En construcción'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      _ProfileOption(
                        icon: Icons.dark_mode_outlined,
                        title: 'Tema',
                        subtitle: 'Claro / Oscuro',
                        color: Colors.indigo,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tema - En construcción'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: Text(
                          'Más',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _ProfileOption(
                        icon: Icons.history,
                        title: 'Historial de Compras',
                        subtitle: 'Ver todas tus transacciones',
                        color: Colors.amber,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Historial de Compras - En construcción'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      _ProfileOption(
                        icon: Icons.help_outline,
                        title: 'Ayuda y Soporte',
                        subtitle: 'Preguntas frecuentes',
                        color: Colors.blueGrey,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Ayuda y Soporte - En construcción'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      // Botón de cerrar sesión
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: () => _showLogoutDialog(context),
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text(
                            'Cerrar Sesión',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthController>().logout();
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}
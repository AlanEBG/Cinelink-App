import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/auth_controller.dart';
import '../../app/theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: AppColors.primary, // AppBar del color primario para unirse al header
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        // Eliminamos la sombra y el color blanco del AppBar para que se fusione con el header cuadrado
        title: Text(
          'Mi Perfil',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Texto blanco sobre fondo azul
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white), // Iconos blancos
      ),
      body: Consumer<AuthController>(
        builder: (context, authController, child) {
          final user = authController.user;

          return SingleChildScrollView(
            child: Column(
              children: [
                // ==========================================
                // HEADER CON GRADIENTE (CUADRADO)
                // ==========================================
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                      ],
                    ),
                    // SE ELIMINÓ EL BORDER RADIUS AQUÍ PARA HACERLO CUADRADO
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 40), // Reduje un poco el padding superior
                  child: Column(
                    children: [
                      // Avatar con borde
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.white,
                          child: Text(
                            user?.initials ?? 'U',
                            style: GoogleFonts.poppins(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Nombre
                      Text(
                        user?.displayName ?? 'Usuario',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // Email
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user?.userEmail ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Roles (Chips)
                      Wrap(
                        spacing: 8,
                        children: user?.userRoles.map((role) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  role.toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              );
                            }).toList() ??
                            [],
                      ),
                    ],
                  ),
                ),

                // ==========================================
                // OPCIONES DEL PERFIL
                // ==========================================
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SECCIÓN CUENTA
                      const _SectionHeader(title: 'Cuenta'),
                      
                      _ProfileOption(
                        icon: Icons.person_outline_rounded,
                        title: 'Editar Perfil',
                        subtitle: 'Actualiza tu información personal',
                        iconColor: AppColors.info, // Azul
                        onTap: () => _showSnackBar(context, 'Editar Perfil - En construcción'),
                      ),
                      
                      _ProfileOption(
                        icon: Icons.lock_outline_rounded,
                        title: 'Cambiar Contraseña',
                        subtitle: 'Actualiza tu contraseña',
                        iconColor: AppColors.warning, // Naranja/Amarillo
                        onTap: () => _showSnackBar(context, 'Cambiar Contraseña - En construcción'),
                      ),
                      
                      _ProfileOption(
                        icon: Icons.credit_card_rounded,
                        title: 'Métodos de Pago',
                        subtitle: 'Administra tus tarjetas',
                        iconColor: AppColors.success, // Verde
                        onTap: () => _showSnackBar(context, 'Métodos de Pago - En construcción'),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // SECCIÓN PREFERENCIAS
                      const _SectionHeader(title: 'Preferencias'),
                      
                      _ProfileOption(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notificaciones',
                        subtitle: 'Configura tus alertas',
                        iconColor: AppColors.secondary, // Rosa/Rojo
                        onTap: () => _showSnackBar(context, 'Notificaciones - En construcción'),
                      ),
                      
                      _ProfileOption(
                        icon: Icons.language_rounded,
                        title: 'Idioma',
                        subtitle: 'Español (México)',
                        iconColor: Colors.teal,
                        onTap: () => _showSnackBar(context, 'Idioma - En construcción'),
                      ),
                      
                      _ProfileOption(
                        icon: Icons.dark_mode_outlined,
                        title: 'Tema',
                        subtitle: 'Claro / Oscuro',
                        iconColor: Colors.indigo,
                        onTap: () => _showSnackBar(context, 'Tema - En construcción'),
                      ),

                      const SizedBox(height: AppSpacing.lg),
                      
                      // SECCIÓN MÁS
                      const _SectionHeader(title: 'Más'),

                      _ProfileOption(
                        icon: Icons.history_rounded,
                        title: 'Historial de Compras',
                        subtitle: 'Ver todas tus transacciones',
                        iconColor: Colors.amber.shade700,
                        onTap: () => _showSnackBar(context, 'Historial - En construcción'),
                      ),
                      
                      _ProfileOption(
                        icon: Icons.help_outline_rounded,
                        title: 'Ayuda y Soporte',
                        subtitle: 'Preguntas frecuentes',
                        iconColor: AppColors.grey600,
                        onTap: () => _showSnackBar(context, 'Ayuda - En construcción'),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ==========================================
                      // BOTÓN CERRAR SESIÓN
                      // ==========================================
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showLogoutDialog(context),
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text('Cerrar Sesión'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: BorderSide(color: AppColors.error.withOpacity(0.3)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            textStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      
                      // Versión (Footer pequeño)
                      const SizedBox(height: AppSpacing.lg),
                      Center(
                        child: Text(
                          'CineLink v1.0.0',
                          style: GoogleFonts.poppins(
                            color: AppColors.grey400,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
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

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
            const SizedBox(width: 12),
            Text(
              'Cerrar sesión',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de que quieres cerrar sesión en CineLink?',
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.error.withOpacity(0.1),
            ),
            child: Text(
              'Cerrar sesión',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
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

// ==========================================================
// WIDGETS AUXILIARES ADAPTADOS
// ==========================================================

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs, 
        bottom: AppSpacing.sm, 
        top: AppSpacing.sm
      ),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.grey200),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, 
          vertical: 4
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: AppColors.grey400,
          size: 20,
        ),
      ),
    );
  }
}
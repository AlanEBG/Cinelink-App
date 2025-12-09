import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        // Sombra sutil debajo del AppBar (consistente con MovieListPage)
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        title: Text(
          'Más Opciones',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            color: AppColors.textPrimary,
            onPressed: () {
              _showSnackBar(context, 'Búsqueda - No implementado');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // ==========================================
          // SECCIÓN 1: CINELINK REWARDS (Estilo Premium)
          // ==========================================
          const _SectionHeader(title: 'CineLink Rewards'),

          _MoreCard(
            icon: Icons.stars_rounded,
            title: 'Nivel Platino',
            subtitle: '12,450 Puntos acumulados',
            // Gradiente Azul Corporativo (Primary)
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: () => _showSnackBar(context, 'Rewards - Próximamente'),
          ),

          _MoreCard(
            icon: Icons.account_balance_wallet_rounded,
            title: 'CinePass Wallet',
            subtitle: 'Saldo actual: \$150.00 MXN',
            // Gradiente Oscuro (TextPrimary) para simular tarjeta Black
            gradient: const LinearGradient(
              colors: [
                AppColors.textPrimary,
                Color(0xFF2C3E63),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: () => _showSnackBar(context, 'Wallet - Próximamente'),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ==========================================
          // SECCIÓN 2: ACTIVIDAD DEL USUARIO
          // ==========================================
          const _SectionHeader(title: 'Tu Actividad'),

          _MoreCard(
            icon: Icons.history_rounded,
            title: 'Historial de Compras',
            subtitle: 'Revisa tus últimas 10 visitas',
            // Color Info (Azul claro)
            gradient: LinearGradient(
              colors: [
                AppColors.info,
                AppColors.info.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: () => _showSnackBar(context, 'Historial - Vacío por ahora'),
          ),

          _MoreCard(
            icon: Icons.local_activity_rounded,
            title: 'Mis Cupones',
            subtitle: 'Tienes 3 cupones por vencer',
            // Color Secondary (Rosa/Rojo) para urgencia
            gradient: LinearGradient(
              colors: [
                AppColors.secondary,
                AppColors.secondary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: () =>
                _showSnackBar(context, 'Cupones - No tienes cupones reales'),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ==========================================
          // SECCIÓN 3: AJUSTES DE LA APP
          // ==========================================
          const _SectionHeader(title: 'Ajustes de la App'),

          _MoreOption(
            icon: Icons.notifications_outlined,
            title: 'Notificaciones',
            subtitle: 'Estrenos y preventas activadas',
            iconColor: AppColors.warning,
            onTap: () {},
          ),

          _MoreOption(
            icon: Icons.fingerprint_rounded,
            title: 'Seguridad',
            subtitle: 'Biometría habilitada',
            iconColor: AppColors.primary,
            onTap: () => _showSnackBar(context, 'Biometría - Simulación'),
          ),

          _MoreOption(
            icon: Icons.language_rounded,
            title: 'Idioma',
            subtitle: 'Español (México)',
            iconColor: AppColors.success,
            onTap: () {},
          ),

          _MoreOption(
            icon: Icons.dark_mode_outlined,
            title: 'Tema',
            subtitle: 'Modo Claro',
            iconColor: AppColors.textSecondary,
            onTap: () {},
          ),

          const SizedBox(height: AppSpacing.lg),

          // ==========================================
          // SECCIÓN 4: SOPORTE Y LEGAL
          // ==========================================
          const _SectionHeader(title: 'Soporte y Legal'),

          _MoreOption(
            icon: Icons.help_outline_rounded,
            title: 'Ayuda y Soporte',
            subtitle: 'Preguntas frecuentes',
            iconColor: AppColors.info,
            onTap: () {},
          ),

          _MoreOption(
            icon: Icons.policy_outlined,
            title: 'Términos y Privacidad',
            subtitle: 'Legal y datos',
            iconColor: AppColors.grey600,
            onTap: () => _showAboutDialog(context),
          ),

          // ==========================================
          // FOOTER: CERRAR SESIÓN Y VERSIÓN
          // ==========================================
          Container(
            margin: const EdgeInsets.only(
              top: AppSpacing.md,
              bottom: AppSpacing.xl,
            ),
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showSnackBar(context, 'Cerrando sesión...'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.error.withOpacity(0.3)),
                foregroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                textStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Cerrar Sesión'),
            ),
          ),

          Center(
            child: Column(
              children: [
                Text(
                  'CineLink v1.0.0',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hecho con amor en Flutter 💙',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.grey400,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Métodos Auxiliares ---

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

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(Icons.movie_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Text(
              'CineLink',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versión: 1.0.0 Beta',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Desarrollado por: AlanEBG',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Text(
              'Aplicación de demostración con diseño Material y paleta personalizada.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// WIDGETS PRIVADOS (REUTILIZABLES EN ESTE ARCHIVO)
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
        top: AppSpacing.sm,
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

class _MoreCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  const _MoreCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MoreOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  const _MoreOption({
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
          vertical: 4,
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
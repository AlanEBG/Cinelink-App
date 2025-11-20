import 'package:flutter/material.dart';
import '../../utils/route_guard.dart';
import '../../app/constant.dart';


class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;
  
  // Paleta de colores moderna
  static const Color _primaryBlue = Color(0xFF1E40AF);
  static const Color _darkBg = Color(0xFF0F172A);
  static const Color _cardBg = Color(0xFF1E293B);
  static const Color _surfaceBg = Color(0xFF334155);
  static const Color _textLight = Color(0xFFF8FAFC);
  static const Color _textMuted = Color(0xFF94A3B8);
  static const Color _accent1 = Color(0xFF06B6D4); // Cyan
  static const Color _accent2 = Color(0xFF10B981); // Emerald
  static const Color _accent3 = Color(0xFFF59E0B); // Amber
  static const Color _accent4 = Color(0xFFEF4444); // Red
  static const Color _accent5 = Color(0xFF8B5CF6); // Violet

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RouteGuard.requiresRole(context, AppConstants.roleAdmin);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AdminSection> get _sections => [
    AdminSection(
      icon: Icons.movie,
      title: 'Cartelera',
      subtitle: 'Gestionar películas',
      color: _primaryBlue,
      route: '/admin/movies',
    ),
    AdminSection(
      icon: Icons.schedule,
      title: 'Funciones',
      subtitle: 'Horarios y salas',
      color: _accent1,
      route: '/admin/showtimes',
    ),
    AdminSection(
      icon: Icons.confirmation_number,
      title: 'Boletos',
      subtitle: 'Ventas y reservas',
      color: _accent2,
      route: '/admin/tickets',
    ),
    AdminSection(
      icon: Icons.meeting_room,
      title: 'Salas',
      subtitle: 'Configuración',
      color: _accent3,
      route: '/admin/rooms',
    ),
    AdminSection(
      icon: Icons.people,
      title: 'Usuarios',
      subtitle: 'Gestionar cuentas',
      color: _accent5,
      route: '/admin/users',
    ),
  ];

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryBlue,
            _primaryBlue.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Panel de Administración',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Cinelink Management System',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // Configuraciones/perfil
                },
                icon: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Stats rápidas
          Row(
            children: [
              _buildQuickStat('12', 'Películas', Icons.movie),
              const SizedBox(width: 16),
              _buildQuickStat('4', 'Salas', Icons.meeting_room),
              const SizedBox(width: 16),
              _buildQuickStat('28', 'Funciones', Icons.schedule),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String count, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              count,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionGrid() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Módulos del Sistema',
            style: TextStyle(
              color: _textLight,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona una sección para gestionar',
            style: TextStyle(
              color: _textMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: _sections.length,
            itemBuilder: (context, index) {
              final section = _sections[index];
              return _buildSectionCard(section);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(AdminSection section) {
    return GestureDetector(
      onTap: () => _navigateToSection(section),
      child: Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: section.color.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: section.color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: section.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  section.icon,
                  color: section.color,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                section.title,
                style: const TextStyle(
                  color: _textLight,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                section.subtitle,
                style: TextStyle(
                  color: _textMuted,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on, color: _accent3, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Acciones Rápidas',
                style: TextStyle(
                  color: _textLight,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildQuickActionButton(
                'Nueva Película',
                Icons.add_circle,
                _accent2,
                () => Navigator.pushNamed(context, '/admin/movies'),
              ),
              _buildQuickActionButton(
                'Programar Función',
                Icons.schedule,
                _accent1,
                () => Navigator.pushNamed(context, '/admin/showtimes'),
              ),
              _buildQuickActionButton(
                'Gestionar Usuarios',
                Icons.people,
                _accent5,
                () => Navigator.pushNamed(context, '/admin/users'),
              ),
              _buildQuickActionButton(
                'Ver Tickets',
                Icons.confirmation_number,
                _accent2,
                () => Navigator.pushNamed(context, '/admin/tickets'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
    );
  }

  void _navigateToSection(AdminSection section) {
    Navigator.pushNamed(context, section.route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildWelcomeHeader(),
              const SizedBox(height: 24),
              _buildSectionGrid(),
              _buildQuickActions(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminSection {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String route;

  AdminSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.route,
  });
}
import 'package:flutter/material.dart';
import '../../utils/route_guard.dart';
import '../../app/constant.dart';
import '../../services/movie_service.dart';
import '../../services/room_service.dart';
import '../../services/showtime_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;
  late AnimationController _animationController;
  
  // Services
  final MovieService _movieService = MovieService();
  final RoomService _roomService = RoomService();
  final ShowtimeService _showtimeService = ShowtimeService();
  
  // Data
  int _totalMovies = 0;
  int _totalRooms = 0;
  int _totalShowtimes = 0;
  bool _isLoadingStats = true;
  
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
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RouteGuard.requiresRole(context, AppConstants.roleAdmin);
      _loadDashboardStats();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardStats() async {
    setState(() {
      _isLoadingStats = true;
    });

    try {
      final movies = await _movieService.getAllMovies();
      final rooms = await _roomService.getAllRooms();
      final showtimes = await _showtimeService.getAllShowtimes();

      setState(() {
        _totalMovies = movies.length;
        _totalRooms = rooms.length;
        _totalShowtimes = showtimes.length;
        _isLoadingStats = false;
      });
    } catch (e) {
      print('Error cargando estadísticas: $e');
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.settings, color: _primaryBlue, size: 24),
            const SizedBox(width: 12),
            const Text(
              'Configuración',
              style: TextStyle(color: _textLight, fontSize: 20),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.person, color: _textMuted),
              title: Text('Perfil', style: TextStyle(color: _textLight)),
              trailing: Icon(Icons.arrow_forward_ios, color: _textMuted, size: 16),
              onTap: () {
                Navigator.pop(context);
                // Navegar a perfil
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications, color: _textMuted),
              title: Text('Notificaciones', style: TextStyle(color: _textLight)),
              trailing: Icon(Icons.arrow_forward_ios, color: _textMuted, size: 16),
              onTap: () {
                Navigator.pop(context);
                // Navegar a notificaciones
              },
            ),
            ListTile(
              leading: Icon(Icons.security, color: _textMuted),
              title: Text('Seguridad', style: TextStyle(color: _textLight)),
              trailing: Icon(Icons.arrow_forward_ios, color: _textMuted, size: 16),
              onTap: () {
                Navigator.pop(context);
                // Navegar a seguridad
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: _accent4),
              title: Text('Cerrar Sesión', style: TextStyle(color: _accent4)),
              onTap: () {
                Navigator.pop(context);
                // Cerrar sesión
              },
            ),
          ],
        ),
      ),
    );
  }

  List<AdminSection> get _sections => [
    AdminSection(
      icon: Icons.movie_outlined,
      title: 'Cartelera',
      subtitle: 'Gestionar películas',
      description: 'Agregar, editar y eliminar películas en cartelera',
      color: _primaryBlue,
      route: '/admin/movies',
    ),
    AdminSection(
      icon: Icons.schedule_outlined,
      title: 'Funciones',
      subtitle: 'Horarios y salas',
      description: 'Programar y gestionar horarios de proyección',
      color: _accent1,
      route: '/admin/showtimes',
    ),
    AdminSection(
      icon: Icons.confirmation_number_outlined,
      title: 'Boletos',
      subtitle: 'Ventas y reservas',
      description: 'Administrar ventas y reservaciones',
      color: _accent2,
      route: '/admin/tickets',
    ),
    AdminSection(
      icon: Icons.meeting_room_outlined,
      title: 'Salas',
      subtitle: 'Configuración',
      description: 'Gestionar salas de cine y capacidades',
      color: _accent3,
      route: '/admin/rooms',
    ),
    AdminSection(
      icon: Icons.people_outline,
      title: 'Usuarios',
      subtitle: 'Gestionar cuentas',
      description: 'Administrar usuarios y permisos',
      color: _accent5,
      route: '/admin/users',
    ),
  ];

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
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
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.white,
                  size: 32,
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
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cinelink Management System',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _showSettingsDialog,
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          // Stats rápidas con datos reales
          _isLoadingStats
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                )
              : Row(
                  children: [
                    _buildQuickStat(
                      _totalMovies.toString(),
                      'Películas',
                      Icons.movie_outlined,
                    ),
                    const SizedBox(width: 12),
                    _buildQuickStat(
                      _totalRooms.toString(),
                      'Salas',
                      Icons.meeting_room_outlined,
                    ),
                    const SizedBox(width: 12),
                    _buildQuickStat(
                      _totalShowtimes.toString(),
                      'Funciones',
                      Icons.schedule_outlined,
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String count, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              count,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.dashboard_outlined,
                  color: _primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Módulos del Sistema',
                style: TextStyle(
                  color: _textLight,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Desliza hacia abajo para actualizar',
            style: TextStyle(
              color: _textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _sections.length,
            itemBuilder: (context, index) {
              final section = _sections[index];
              return _buildSectionCard(section, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(AdminSection section, int index) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1,
            0.5 + (index * 0.1),
            curve: Curves.easeOut,
          ),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              index * 0.1,
              0.5 + (index * 0.1),
              curve: Curves.easeOut,
            ),
          ),
        ),
        child: GestureDetector(
          onTap: () => _navigateToSection(section),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: section.color.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: section.color.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: section.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: section.color.withOpacity(0.2),
                      ),
                    ),
                    child: Icon(
                      section.icon,
                      color: section.color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.title,
                          style: const TextStyle(
                            color: _textLight,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          section.subtitle,
                          style: TextStyle(
                            color: _textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          section.description,
                          style: TextStyle(
                            color: _textMuted.withOpacity(0.8),
                            fontSize: 12,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: _textMuted,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivitySection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _surfaceBg,
            _surfaceBg.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _accent2.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: _accent2,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumen del Sistema',
                      style: TextStyle(
                        color: _textLight,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Estadísticas cargadas desde el servidor',
                      style: TextStyle(
                        color: _textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildActivityItem(
            'Total de Películas',
            '$_totalMovies películas en cartelera',
            Icons.movie_outlined,
            _primaryBlue,
            'Activo',
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            'Salas Disponibles',
            '$_totalRooms salas configuradas',
            Icons.meeting_room_outlined,
            _accent3,
            'Activo',
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            'Funciones Programadas',
            '$_totalShowtimes horarios activos',
            Icons.schedule_outlined,
            _accent1,
            'Activo',
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            'Sistema Operativo',
            'Todos los servicios funcionando',
            Icons.check_circle_outline,
            _accent2,
            'Online',
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String description,
    IconData icon,
    Color color,
    String time,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _textLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: _textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              time,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
        child: RefreshIndicator(
          onRefresh: _loadDashboardStats,
          color: _primaryBlue,
          backgroundColor: _cardBg,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildWelcomeHeader(),
                    _buildSectionsList(),
                    const SizedBox(height: 16),
                    _buildActivitySection(),
                  ],
                ),
              ),
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
  final String description;
  final Color color;
  final String route;

  AdminSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    required this.route,
  });
}
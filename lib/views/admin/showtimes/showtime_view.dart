import 'package:flutter/material.dart';
import '../../../models/showtime.dart';
import '../../../models/movie.dart';
import '../../../models/room.dart';
import '../../../services/showtime_service.dart';
import '../../../services/movie_service.dart';
import '../../../services/room_service.dart';

class ShowtimesAdminPage extends StatefulWidget {
  const ShowtimesAdminPage({super.key});

  @override
  State<ShowtimesAdminPage> createState() => _ShowtimesAdminPageState();
}

class _ShowtimesAdminPageState extends State<ShowtimesAdminPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ShowtimeService _showtimeService = ShowtimeService();
  final MovieService _movieService = MovieService();
  final RoomService _roomService = RoomService();
  
  String _searchQuery = '';
  DateTime _selectedDate = DateTime.now();
  bool _isSearchFocused = false;
  
  // Colores modernos
  static const Color _darkBg = Color(0xFF0F172A);
  static const Color _cardBg = Color(0xFF1E293B);
  static const Color _surfaceBg = Color(0xFF334155);
  static const Color _primaryBlue = Color(0xFF3B82F6);
  static const Color _successGreen = Color(0xFF10B981);
  static const Color _warningAmber = Color(0xFFF59E0B);
  static const Color _dangerRed = Color(0xFFEF4444);
  static const Color _textLight = Color(0xFFF8FAFC);
  static const Color _textMuted = Color(0xFF94A3B8);

  List<Showtime> _showtimes = [];
  List<Movie> _movies = [];
  List<Room> _rooms = [];
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> _languageOptions = ['Español', 'Ingles', 'Subtitulado'];
  String? _quickFilter;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupSearchListener();
    _setupFocusListener();
    _loadData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  void _setupSearchListener() {
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  void _setupFocusListener() {
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final showtimes = await _showtimeService.getAllShowtimes();
      final movies = await _movieService.getAllMovies();
      final rooms = await _roomService.getAllRooms();
      
      setState(() {
        _showtimes = showtimes;
        _movies = movies;
        _rooms = rooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar datos: $e';
      });
    }
  }

  Future<void> _addShowtime(Showtime showtime) async {
    try {
      await _showtimeService.createShowtime(showtime);
      await _loadData();
      _showSuccessSnackBar('Función agregada correctamente');
    } catch (e) {
      _showErrorSnackBar('Error al agregar función: $e');
    }
  }

  Future<void> _updateShowtime(Showtime showtime) async {
    try {
      await _showtimeService.updateShowtime(showtime.id!, showtime);
      await _loadData();
      _showSuccessSnackBar('Función actualizada correctamente');
    } catch (e) {
      _showErrorSnackBar('Error al actualizar función: $e');
    }
  }

  Future<void> _deleteShowtime(String showtimeId) async {
    try {
      await _showtimeService.deleteShowtime(showtimeId);
      await _loadData();
      _showSuccessSnackBar('Función eliminada correctamente');
    } catch (e) {
      _showErrorSnackBar('Error al eliminar función: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _dangerRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<Showtime> get _filteredShowtimes {
    if (_searchQuery.isEmpty) return _showtimes;
    
    return _showtimes.where((showtime) {
      final movie = _getMovieById(showtime.movieId);
      final room = showtime.room ?? _getRoomById(showtime.roomId);
      
      return movie?.movieTitle.toLowerCase().contains(_searchQuery) == true ||
             room?.roomName.toLowerCase().contains(_searchQuery) == true ||
             showtime.lenguage.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  Movie? _getMovieById(int? movieId) {
    if (movieId == null) return null;
    try {
      return _movies.firstWhere((m) => m.movieId == movieId);
    } catch (e) {
      return null;
    }
  }

  Room? _getRoomById(int? roomId) {
    if (roomId == null) return null;
    try {
      return _rooms.firstWhere((r) => r.roomId == roomId);
    } catch (e) {
      return null;
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryBlue,
            _primaryBlue.withOpacity(0.85),
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
              // Botón de retroceso
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                  tooltip: 'Volver',
                ),
              ),
              const SizedBox(width: 16),
              // Título y subtítulo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gestión de Funciones',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Administrar horarios y disponibilidad',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Botón agregar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showShowtimeDialog(
                      title: 'Nueva Función',
                    ),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_circle,
                            color: _primaryBlue,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Agregar',
                            style: TextStyle(
                              color: _primaryBlue,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Barra de búsqueda
          _buildSearchBar(),
          
          // Filtros rápidos (opcional)
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickFilter('Todas', null),
                  const SizedBox(width: 8),
                  _buildQuickFilter('Hoy', 'today'),
                  const SizedBox(width: 8),
                  _buildQuickFilter('Esta Semana', 'week'),
                  const SizedBox(width: 8),
                  _buildQuickFilter('Español', 'español'),
                  const SizedBox(width: 8),
                  _buildQuickFilter('Inglés', 'ingles'),
                  const SizedBox(width: 8),
                  _buildQuickFilter('Subtitulado', 'subtitulado'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Nuevo método para filtros rápidos
  Widget _buildQuickFilter(String label, String? filter) {
    final isActive = _quickFilter == filter;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _quickFilter = filter;
          if (filter != null) {
            _searchController.text = label;
          } else {
            _searchController.clear();
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (filter != null) ...[
              Icon(
                _getFilterIcon(filter),
                size: 16,
                color: isActive ? _primaryBlue : Colors.white,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isActive ? _primaryBlue : Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'today':
        return Icons.today;
      case 'week':
        return Icons.calendar_month;
      case 'español':
      case 'ingles':
      case 'subtitulado':
        return Icons.language;
      default:
        return Icons.filter_list;
    }
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: const TextStyle(
          color: Color(0xFF1E2A47),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Buscar por película, sala o idioma...',
          hintStyle: TextStyle(
            color: _textMuted.withOpacity(0.5),
            fontSize: 15,
            fontWeight: FontWeight.normal,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.search_rounded,
              color: _textMuted.withOpacity(0.6),
              size: 24,
            ),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: _textMuted,
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _searchFocusNode.unfocus();
                  },
                  tooltip: 'Limpiar búsqueda',
                )
              : null,
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: _primaryBlue.withOpacity(0.5),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final today = DateTime.now();
    final todayShowtimes = _showtimes.where((s) => 
      s.dateTime.year == today.year &&
      s.dateTime.month == today.month &&
      s.dateTime.day == today.day
    ).length;

    final totalSeats = _showtimes.fold(0, (sum, s) => sum + s.remainingSeats);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          _buildStatCard('Total', _showtimes.length.toString(), Icons.movie, _primaryBlue),
          const SizedBox(width: 12),
          _buildStatCard('Hoy', todayShowtimes.toString(), Icons.today, _successGreen),
          const SizedBox(width: 12),
          _buildStatCard('Asientos', totalSeats.toString(), Icons.event_seat, _warningAmber),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: _textLight,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: _textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShowtimesList() {
    if (_isLoading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(color: _primaryBlue),
        ),
      );
    }

    if (_errorMessage != null) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: _dangerRed, size: 64),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(color: _dangerRed),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredShowtimes.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, color: _textMuted, size: 64),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isNotEmpty ? 'No se encontraron funciones' : 'No hay funciones disponibles',
                style: TextStyle(color: _textMuted, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isNotEmpty ? 'Intenta con otra búsqueda' : 'Agrega tu primera función',
                style: TextStyle(color: _textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: _primaryBlue,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            itemCount: _filteredShowtimes.length,
            itemBuilder: (context, index) {
              final showtime = _filteredShowtimes[index];
              return _buildShowtimeCard(showtime, index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildShowtimeCard(Showtime showtime, int index) {
    final movie = showtime.movie ?? _getMovieById(showtime.movieId);
    final room = showtime.room ?? _getRoomById(showtime.roomId);
    
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 400 + (index * 50)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _primaryBlue.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _primaryBlue.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _primaryBlue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.movie,
                            color: _primaryBlue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movie?.movieTitle ?? 'Película no encontrada',
                                style: const TextStyle(
                                  color: _textLight,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                room?.roomName ?? 'Sala no encontrada',
                                style: TextStyle(
                                  color: _textMuted,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: _textMuted),
                          color: _surfaceBg,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          onSelected: (value) => _handleMenuAction(value, showtime),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.visibility, color: _primaryBlue, size: 18),
                                  const SizedBox(width: 12),
                                  Text('Ver Detalles', style: TextStyle(color: _textLight)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: _successGreen, size: 18),
                                  const SizedBox(width: 12),
                                  Text('Editar', style: TextStyle(color: _textLight)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: _dangerRed, size: 18),
                                  const SizedBox(width: 12),
                                  Text('Eliminar', style: TextStyle(color: _textLight)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Contenido
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoItem(
                                'Fecha y Hora',
                                '${showtime.dateTime.day}/${showtime.dateTime.month}/${showtime.dateTime.year} ${showtime.dateTime.hour}:${showtime.dateTime.minute.toString().padLeft(2, '0')}',
                                Icons.schedule,
                              ),
                            ),
                            Expanded(
                              child: _buildInfoItem(
                                'Precio',
                                '\$${showtime.price.toStringAsFixed(2)}',
                                Icons.attach_money,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoItem(
                                'Asientos',
                                '${showtime.remainingSeats} disponibles',
                                Icons.event_seat,
                              ),
                            ),
                            Expanded(
                              child: _buildInfoItem(
                                'Idioma',
                                showtime.lenguage,
                                Icons.language,
                              ),
                            ),
                          ],
                        ),
                        if (movie?.movieGenre != null) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              _buildChip(movie!.movieGenre, _primaryBlue),
                              _buildChip('${movie.movieDurationMinutes} min', Colors.orange),
                              _buildChip(showtime.lenguage, Colors.purple),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        );
        },
      );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: _textMuted, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: _textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: _textLight,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _handleMenuAction(String action, Showtime showtime) {
    switch (action) {
      case 'view':
        _showShowtimeDetails(showtime);
        break;
      case 'edit':
        _showEditShowtimeDialog(showtime);
        break;
      case 'delete':
        _showDeleteConfirmation(showtime);
        break;
    }
  }

  void _showAddShowtimeDialog() {
    _showShowtimeDialog(title: 'Agregar Función');
  }

  void _showEditShowtimeDialog(Showtime showtime) {
    _showShowtimeDialog(title: 'Editar Función', showtime: showtime);
  }

  void _showShowtimeDialog({required String title, Showtime? showtime}) {
    int? selectedMovieId = showtime?.movieId ?? (_movies.isNotEmpty ? _movies.first.movieId : null);
    int? selectedRoomId = showtime?.roomId ?? (_rooms.isNotEmpty ? _rooms.first.roomId : null);
    DateTime selectedDateTime = showtime?.dateTime ?? DateTime.now();
    final priceController = TextEditingController(text: showtime?.price.toString() ?? '');
    final seatsController = TextEditingController(text: showtime?.remainingSeats.toString() ?? '');
    String selectedLanguage = showtime?.lenguage ?? _languageOptions.first;

    if (_movies.isEmpty || _rooms.isEmpty) {
      _showErrorSnackBar('No hay películas o salas disponibles');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: _cardBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_primaryBlue, _primaryBlue.withOpacity(0.8)],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          showtime == null ? Icons.add_circle_outline : Icons.edit,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  // Form Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Película
                          _buildFormLabel('Película *'),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: _surfaceBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _textMuted.withOpacity(0.3)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: selectedMovieId,
                                isExpanded: true,
                                style: const TextStyle(color: _textLight, fontSize: 16),
                                dropdownColor: _surfaceBg,
                                icon: Icon(Icons.arrow_drop_down, color: _textMuted),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                items: _movies.map((movie) => DropdownMenuItem(
                                  value: movie.movieId,
                                  child: Row(
                                    children: [
                                      Icon(Icons.movie, color: _textMuted, size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          movie.movieTitle,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                )).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedMovieId = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Sala
                          _buildFormLabel('Sala *'),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: _surfaceBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _textMuted.withOpacity(0.3)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: selectedRoomId,
                                isExpanded: true,
                                style: const TextStyle(color: _textLight, fontSize: 16),
                                dropdownColor: _surfaceBg,
                                icon: Icon(Icons.arrow_drop_down, color: _textMuted),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                items: _rooms.map((room) => DropdownMenuItem(
                                  value: room.roomId,
                                  child: Row(
                                    children: [
                                      Icon(Icons.meeting_room, color: _textMuted, size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          room.roomName,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                )).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedRoomId = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Fecha y Hora
                          _buildFormLabel('Fecha y Hora *'),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: selectedDateTime,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.dark(
                                        primary: _primaryBlue,
                                        surface: _cardBg,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              
                              if (date != null) {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.dark(
                                          primary: _primaryBlue,
                                          surface: _cardBg,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                
                                if (time != null) {
                                  setState(() {
                                    selectedDateTime = DateTime(
                                      date.year,
                                      date.month,
                                      date.day,
                                      time.hour,
                                      time.minute,
                                    );
                                  });
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: _surfaceBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _textMuted.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, color: _textMuted, size: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${selectedDateTime.day.toString().padLeft(2, '0')}/${selectedDateTime.month.toString().padLeft(2, '0')}/${selectedDateTime.year} ${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(color: _textLight, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Precio y Asientos
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFormLabel('Precio *'),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: priceController,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(color: _textLight, fontSize: 16),
                                      decoration: _buildInputDecoration('10.00', Icons.attach_money),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFormLabel('Asientos *'),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: seatsController,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(color: _textLight, fontSize: 16),
                                      decoration: _buildInputDecoration('50', Icons.event_seat),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // Idioma
                          _buildFormLabel('Idioma *'),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: _surfaceBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _textMuted.withOpacity(0.3)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedLanguage,
                                isExpanded: true,
                                style: const TextStyle(color: _textLight, fontSize: 16),
                                dropdownColor: _surfaceBg,
                                icon: Icon(Icons.arrow_drop_down, color: _textMuted),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                items: _languageOptions.map((lang) => DropdownMenuItem(
                                  value: lang,
                                  child: Row(
                                    children: [
                                      Icon(Icons.language, color: _textMuted, size: 20),
                                      const SizedBox(width: 12),
                                      Text(lang),
                                    ],
                                  ),
                                )).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedLanguage = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '* Campos obligatorios',
                            style: TextStyle(
                              color: _textMuted,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Footer Actions
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _surfaceBg.withOpacity(0.5),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(color: _textMuted, fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            if (_validateShowtimeForm(
                              selectedMovieId,
                              selectedRoomId,
                              priceController.text,
                              seatsController.text,
                            )) {
                              Navigator.pop(context);
                              _saveShowtime(
                                showtime,
                                selectedMovieId!,
                                selectedRoomId!,
                                selectedDateTime,
                                double.tryParse(priceController.text) ?? 0.0,
                                int.tryParse(seatsController.text) ?? 0,
                                selectedLanguage,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(showtime == null ? Icons.add : Icons.save, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                showtime == null ? 'Agregar' : 'Guardar',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: _textLight,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: _textMuted.withOpacity(0.5), fontSize: 14),
      prefixIcon: Icon(icon, color: _textMuted, size: 20),
      filled: true,
      fillColor: _surfaceBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _textMuted.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryBlue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  bool _validateShowtimeForm(int? movieId, int? roomId, String price, String seats) {
    if (movieId == null || roomId == null) {
      _showErrorSnackBar('Todos los campos son requeridos');
      return false;
    }
    if (price.trim().isEmpty || double.tryParse(price) == null || double.parse(price) <= 0) {
      _showErrorSnackBar('El precio debe ser un número válido mayor a 0');
      return false;
    }
    if (seats.trim().isEmpty || int.tryParse(seats) == null || int.parse(seats) <= 0) {
      _showErrorSnackBar('Los asientos deben ser un número válido mayor a 0');
      return false;
    }
    return true;
  }

  void _saveShowtime(Showtime? existingShowtime, int movieId, int roomId, 
      DateTime dateTime, double price, int seats, String language) async {
    
    final showtimeData = Showtime(
      id: existingShowtime?.id,
      dateTime: dateTime,
      price: price,
      remainingSeats: seats,
      lenguage: language,
      movieId: movieId,
      roomId: roomId,
    );

    if (existingShowtime == null) {
      await _addShowtime(showtimeData);
    } else {
      await _updateShowtime(showtimeData);
    }
  }

  void _showDeleteConfirmation(Showtime showtime) {
    final movie = showtime.movie ?? _getMovieById(showtime.movieId);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: _dangerRed, size: 28),
            const SizedBox(width: 12),
            const Text('Confirmar eliminación', style: TextStyle(color: _textLight)),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar la función de "${movie?.movieTitle ?? 'Película desconocida'}"? Esta acción no se puede deshacer.',
          style: TextStyle(color: _textMuted, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: _textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (showtime.id != null) {
                await _deleteShowtime(showtime.id!);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _dangerRed,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Eliminar', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showShowtimeDetails(Showtime showtime) {
    final movie = showtime.movie ?? _getMovieById(showtime.movieId);
    final room = showtime.room ?? _getRoomById(showtime.roomId);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(movie?.movieTitle ?? 'Función', style: const TextStyle(color: _textLight, fontSize: 22)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Sala', room?.roomName ?? 'Desconocida', Icons.meeting_room),
              _buildDetailRow('Fecha', '${showtime.dateTime.day}/${showtime.dateTime.month}/${showtime.dateTime.year}', Icons.calendar_today),
              _buildDetailRow('Hora', '${showtime.dateTime.hour}:${showtime.dateTime.minute.toString().padLeft(2, '0')}', Icons.schedule),
              _buildDetailRow('Precio', '\$${showtime.price.toStringAsFixed(2)}', Icons.attach_money),
              _buildDetailRow('Asientos Disponibles', showtime.remainingSeats.toString(), Icons.event_seat),
              _buildDetailRow('Idioma', showtime.lenguage, Icons.language),
              if (movie?.movieGenre != null)
                _buildDetailRow('Género', movie!.movieGenre, Icons.category),
              if (movie?.movieDurationMinutes != null)
                _buildDetailRow('Duración', '${movie!.movieDurationMinutes} minutos', Icons.access_time),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: _primaryBlue, size: 18),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(color: _textMuted, fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: _textLight),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStatsCards(),
            _buildShowtimesList(),
          ],
        ),
      ),
    );
  }
}
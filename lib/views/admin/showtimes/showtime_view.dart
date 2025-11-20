import 'package:flutter/material.dart';

class ShowtimesAdminPage extends StatefulWidget {
  const ShowtimesAdminPage({super.key});

  @override
  State<ShowtimesAdminPage> createState() => _ShowtimesAdminPageState();
}

class _ShowtimesAdminPageState extends State<ShowtimesAdminPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Todas';
  DateTime _selectedDate = DateTime.now();
  
  // Colores modernos
  static const Color _darkBg = Color(0xFF0F172A);
  static const Color _cardBg = Color(0xFF1E293B);
  static const Color _surfaceBg = Color(0xFF334155);
  static const Color _primaryBlue = Color(0xFF3B82F6);
  static const Color _successGreen = Color(0xFF10B981);
  static const Color _warningAmber = Color(0xFFF59E0B);
  static const Color _dangerRed = Color(0xFFEF4444);
  static const Color _purpleAccent = Color(0xFF8B5CF6);
  static const Color _textLight = Color(0xFFF8FAFC);
  static const Color _textMuted = Color(0xFF94A3B8);

  // Lista simulada de funciones (reemplazar con API call)
  List<Showtime> _showtimes = [
    Showtime(
      id: 1,
      movieTitle: 'Avatar: El Camino del Agua',
      movieGenre: 'Ciencia Ficción',
      roomName: 'Sala Premium 1',
      roomCapacity: 80,
      startTime: DateTime(2024, 1, 20, 14, 30),
      endTime: DateTime(2024, 1, 20, 17, 45),
      price: 12.50,
      availableSeats: 65,
      status: 'Activa',
      language: 'Español',
      subtitles: true,
    ),
    Showtime(
      id: 2,
      movieTitle: 'Top Gun: Maverick',
      movieGenre: 'Acción',
      roomName: 'Sala VIP 2',
      roomCapacity: 40,
      startTime: DateTime(2024, 1, 20, 19, 00),
      endTime: DateTime(2024, 1, 20, 21, 30),
      price: 18.00,
      availableSeats: 28,
      status: 'Activa',
      language: 'Inglés',
      subtitles: true,
    ),
    Showtime(
      id: 3,
      movieTitle: 'Dune: Parte Dos',
      movieGenre: 'Ciencia Ficción',
      roomName: 'Sala IMAX',
      roomCapacity: 120,
      startTime: DateTime(2024, 1, 21, 21, 15),
      endTime: DateTime(2024, 1, 22, 0, 30),
      price: 15.75,
      availableSeats: 0,
      status: 'Agotada',
      language: 'Inglés',
      subtitles: true,
    ),
    Showtime(
      id: 4,
      movieTitle: 'Spider-Man: No Way Home',
      movieGenre: 'Acción',
      roomName: 'Sala Estándar 3',
      roomCapacity: 100,
      startTime: DateTime(2024, 1, 22, 16, 00),
      endTime: DateTime(2024, 1, 22, 18, 30),
      price: 10.00,
      availableSeats: 85,
      status: 'Programada',
      language: 'Español',
      subtitles: false,
    ),
  ];

  final List<String> _filterOptions = ['Todas', 'Activa', 'Programada', 'Agotada', 'Cancelada'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Showtime> get _filteredShowtimes {
    List<Showtime> filtered = _showtimes;
    
    if (_selectedFilter != 'Todas') {
      filtered = filtered.where((showtime) => showtime.status == _selectedFilter).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((showtime) =>
        showtime.movieTitle.toLowerCase().contains(_searchQuery) ||
        showtime.roomName.toLowerCase().contains(_searchQuery) ||
        showtime.movieGenre.toLowerCase().contains(_searchQuery)
      ).toList();
    }
    
    return filtered;
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryBlue, _primaryBlue.withOpacity(0.8)],
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
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 8),
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
                      ),
                    ),
                    Text(
                      'Administrar horarios y programación',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              FloatingActionButton(
                onPressed: () => _showAddShowtimeDialog(),
                backgroundColor: _successGreen,
                heroTag: "addShowtime",
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSearchAndFilters(),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar funciones...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.8)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                value: _selectedFilter,
                dropdownColor: _surfaceBg,
                underline: const SizedBox(),
                icon: Icon(Icons.filter_list, color: Colors.white.withOpacity(0.8)),
                style: const TextStyle(color: Colors.white),
                items: _filterOptions.map((filter) => DropdownMenuItem(
                  value: filter,
                  child: Text(filter, style: const TextStyle(color: Colors.white)),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDateSelector(),
      ],
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;
          
          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'][date.weekday % 7],
                    style: TextStyle(
                      color: isSelected ? _primaryBlue : Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected ? _primaryBlue : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  Widget _buildStatsCards() {
    final activeShowtimes = _showtimes.where((s) => s.status == 'Activa').length;
    final soldOutShowtimes = _showtimes.where((s) => s.status == 'Agotada').length;
    final totalRevenue = _showtimes.fold<double>(0.0, (sum, showtime) => 
      sum + (showtime.price * (showtime.roomCapacity - showtime.availableSeats))
    );

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          _buildStatCard('Activas', activeShowtimes.toString(), Icons.play_circle, _successGreen),
          const SizedBox(width: 12),
          _buildStatCard('Agotadas', soldOutShowtimes.toString(), Icons.event_busy, _dangerRed),
          const SizedBox(width: 12),
          _buildStatCard('Ingresos', '\$${totalRevenue.toStringAsFixed(0)}', Icons.attach_money, _warningAmber),
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
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShowtimesList() {
    return Expanded(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          itemCount: _filteredShowtimes.length,
          itemBuilder: (context, index) {
            final showtime = _filteredShowtimes[index];
            return _buildShowtimeCard(showtime, index);
          },
        ),
      ),
    );
  }

  Widget _buildShowtimeCard(Showtime showtime, int index) {
    final occupancyRate = ((showtime.roomCapacity - showtime.availableSeats) / showtime.roomCapacity * 100);
    
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getStatusColor(showtime.status).withOpacity(0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header de la función
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _getStatusColor(showtime.status).withOpacity(0.1),
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
                            color: _getStatusColor(showtime.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.movie,
                            color: _getStatusColor(showtime.status),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                showtime.movieTitle,
                                style: const TextStyle(
                                  color: _textLight,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _primaryBlue.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      showtime.movieGenre,
                                      style: TextStyle(
                                        color: _primaryBlue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(showtime.status),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      showtime.status,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${showtime.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: _warningAmber,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: _textMuted),
                          color: _surfaceBg,
                          onSelected: (value) => _handleMenuAction(value, showtime),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: _primaryBlue, size: 18),
                                  const SizedBox(width: 8),
                                  Text('Editar', style: TextStyle(color: _textLight)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'duplicate',
                              child: Row(
                                children: [
                                  Icon(Icons.copy, color: _successGreen, size: 18),
                                  const SizedBox(width: 8),
                                  Text('Duplicar', style: TextStyle(color: _textLight)),
                                ],
                              ),
                            ),
                            if (showtime.status != 'Cancelada')
                              PopupMenuItem(
                                value: 'cancel',
                                child: Row(
                                  children: [
                                    Icon(Icons.cancel, color: _dangerRed, size: 18),
                                    const SizedBox(width: 8),
                                    Text('Cancelar', style: TextStyle(color: _textLight)),
                                  ],
                                ),
                              ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: _dangerRed, size: 18),
                                  const SizedBox(width: 8),
                                  Text('Eliminar', style: TextStyle(color: _textLight)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Contenido de la función
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoItem('Sala', showtime.roomName, Icons.meeting_room),
                            ),
                            Expanded(
                              child: _buildInfoItem(
                                'Horario',
                                '${showtime.startTime.hour}:${showtime.startTime.minute.toString().padLeft(2, '0')} - ${showtime.endTime.hour}:${showtime.endTime.minute.toString().padLeft(2, '0')}',
                                Icons.schedule,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoItem('Idioma', showtime.language, Icons.language),
                            ),
                            Expanded(
                              child: _buildInfoItem('Subtítulos', showtime.subtitles ? 'Sí' : 'No', Icons.closed_caption),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Barra de ocupación
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Ocupación',
                                  style: TextStyle(color: _textMuted, fontSize: 14),
                                ),
                                Text(
                                  '${showtime.roomCapacity - showtime.availableSeats}/${showtime.roomCapacity} (${occupancyRate.toStringAsFixed(1)}%)',
                                  style: const TextStyle(color: _textLight, fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: occupancyRate / 100,
                              backgroundColor: _textMuted.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                occupancyRate > 80 ? _dangerRed :
                                occupancyRate > 50 ? _warningAmber : _successGreen,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Activa': return _successGreen;
      case 'Programada': return _primaryBlue;
      case 'Agotada': return _warningAmber;
      case 'Cancelada': return _dangerRed;
      default: return _textMuted;
    }
  }

  void _handleMenuAction(String action, Showtime showtime) {
    switch (action) {
      case 'edit':
        _showEditShowtimeDialog(showtime);
        break;
      case 'duplicate':
        _duplicateShowtime(showtime);
        break;
      case 'cancel':
        _cancelShowtime(showtime);
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
    final movieController = TextEditingController(text: showtime?.movieTitle ?? '');
    final roomController = TextEditingController(text: showtime?.roomName ?? '');
    final priceController = TextEditingController(text: showtime?.price.toString() ?? '');
    DateTime selectedDateTime = showtime?.startTime ?? DateTime.now();
    String selectedLanguage = showtime?.language ?? 'Español';
    bool hasSubtitles = showtime?.subtitles ?? true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(color: _textLight)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: movieController,
                style: const TextStyle(color: _textLight),
                decoration: InputDecoration(
                  labelText: 'Película',
                  labelStyle: TextStyle(color: _textMuted),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _textMuted.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _primaryBlue),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: roomController,
                style: const TextStyle(color: _textLight),
                decoration: InputDecoration(
                  labelText: 'Sala',
                  labelStyle: TextStyle(color: _textMuted),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _textMuted.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _primaryBlue),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: _textLight),
                decoration: InputDecoration(
                  labelText: 'Precio',
                  labelStyle: TextStyle(color: _textMuted),
                  prefixText: '\$',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _textMuted.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _primaryBlue),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedLanguage,
                style: const TextStyle(color: _textLight),
                decoration: InputDecoration(
                  labelText: 'Idioma',
                  labelStyle: TextStyle(color: _textMuted),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _textMuted.withOpacity(0.3)),
                  ),
                ),
                dropdownColor: _surfaceBg,
                items: ['Español', 'Inglés', 'Subtitulado']
                    .map((lang) => DropdownMenuItem(
                          value: lang,
                          child: Text(lang, style: const TextStyle(color: _textLight)),
                        ))
                    .toList(),
                onChanged: (value) => selectedLanguage = value!,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: Text('Subtítulos', style: TextStyle(color: _textLight)),
                value: hasSubtitles,
                activeColor: _primaryBlue,
                onChanged: (value) => hasSubtitles = value ?? false,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: _textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveShowtime(
                showtime,
                movieController.text,
                roomController.text,
                double.tryParse(priceController.text) ?? 0.0,
                selectedDateTime,
                selectedLanguage,
                hasSubtitles,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(showtime == null ? 'Agregar' : 'Guardar'),
          ),
        ],
      ),
    );
  }

  void _saveShowtime(Showtime? existingShowtime, String movieTitle, String roomName, 
      double price, DateTime startTime, String language, bool subtitles) {
    if (existingShowtime == null) {
      // Agregar nueva función
      final newShowtime = Showtime(
        id: DateTime.now().millisecondsSinceEpoch,
        movieTitle: movieTitle,
        movieGenre: 'Drama', // Por defecto
        roomName: roomName,
        roomCapacity: 80, // Por defecto
        startTime: startTime,
        endTime: startTime.add(const Duration(hours: 2, minutes: 30)),
        price: price,
        availableSeats: 80,
        status: 'Programada',
        language: language,
        subtitles: subtitles,
      );
      setState(() {
        _showtimes.add(newShowtime);
      });
    } else {
      // Editar función existente
      setState(() {
        existingShowtime.movieTitle = movieTitle;
        existingShowtime.roomName = roomName;
        existingShowtime.price = price;
        existingShowtime.startTime = startTime;
        existingShowtime.language = language;
        existingShowtime.subtitles = subtitles;
      });
    }
  }

  void _duplicateShowtime(Showtime showtime) {
    final newShowtime = Showtime(
      id: DateTime.now().millisecondsSinceEpoch,
      movieTitle: showtime.movieTitle,
      movieGenre: showtime.movieGenre,
      roomName: showtime.roomName,
      roomCapacity: showtime.roomCapacity,
      startTime: showtime.startTime.add(const Duration(days: 1)),
      endTime: showtime.endTime.add(const Duration(days: 1)),
      price: showtime.price,
      availableSeats: showtime.roomCapacity,
      status: 'Programada',
      language: showtime.language,
      subtitles: showtime.subtitles,
    );
    setState(() {
      _showtimes.add(newShowtime);
    });
  }

  void _cancelShowtime(Showtime showtime) {
    setState(() {
      showtime.status = 'Cancelada';
    });
  }

  void _showDeleteConfirmation(Showtime showtime) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirmar eliminación', style: TextStyle(color: _textLight)),
        content: Text(
          '¿Estás seguro de que deseas eliminar la función de "${showtime.movieTitle}"?',
          style: TextStyle(color: _textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: _textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteShowtime(showtime);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _dangerRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _deleteShowtime(Showtime showtime) {
    setState(() {
      _showtimes.removeWhere((s) => s.id == showtime.id);
    });
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

class Showtime {
  int id;
  String movieTitle;
  String movieGenre;
  String roomName;
  int roomCapacity;
  DateTime startTime;
  DateTime endTime;
  double price;
  int availableSeats;
  String status;
  String language;
  bool subtitles;

  Showtime({
    required this.id,
    required this.movieTitle,
    required this.movieGenre,
    required this.roomName,
    required this.roomCapacity,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.availableSeats,
    required this.status,
    required this.language,
    required this.subtitles,
  });
}
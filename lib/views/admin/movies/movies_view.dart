import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../app/constant.dart';

class MoviesAdminPage extends StatefulWidget {
  const MoviesAdminPage({super.key});

  @override
  State<MoviesAdminPage> createState() => _MoviesAdminPageState();
}

class _MoviesAdminPageState extends State<MoviesAdminPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Todas';
  
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

  // Lista de películas desde API
  List<Movie> _movies = [];
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> _filterOptions = ['Todas', 'En Cartelera', 'Próximamente', 'Finalizada'];
  final List<String> _genreOptions = ['Acción', 'Drama', 'Comedia', 'Terror', 'Ciencia Ficción', 'Romance', 'Aventura'];
  final List<String> _ratingOptions = ['G', 'PG', 'PG-13', 'R', 'NC-17'];

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

    // Cargar películas desde API
    _loadMovies();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Cargar películas desde la API
  Future<void> _loadMovies() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      print('🎬 Cargando películas desde: ${AppConstants.baseUrl}${AppConstants.moviesEndpoint}');

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.moviesEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📡 Movies API Response Status: ${response.statusCode}');
      print('📡 Movies API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['status'] == true && data['data'] != null) {
          final List<dynamic> moviesJson = data['data'];
          final List<Movie> loadedMovies = moviesJson.map((movieData) => Movie.fromJson(movieData)).toList();
          
          setState(() {
            _movies = loadedMovies;
            _isLoading = false;
          });
          print('✅ Películas cargadas: ${_movies.length}');
        } else {
          throw Exception(data['message'] ?? 'Error en la respuesta de la API');
        }
      } else {
        throw Exception('Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('❌ Error cargando películas: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar películas: $e';
      });
    }
  }

  // Agregar nueva película
  Future<void> _addMovie(Movie movie) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.moviesEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(movie.toJson()),
      );

      print('📡 Add Movie Response: ${response.statusCode}');
      print('📡 Add Movie Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true) {
          // Recargar la lista
          await _loadMovies();
          _showSuccessSnackBar('Película agregada correctamente');
        } else {
          throw Exception(data['message'] ?? 'Error al agregar película');
        }
      } else {
        throw Exception('Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('❌ Error agregando película: $e');
      _showErrorSnackBar('Error al agregar película: $e');
    }
  }

  // Actualizar película
  Future<void> _updateMovie(Movie movie) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.moviesEndpoint}/${movie.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(movie.toJson()),
      );

      print('📡 Update Movie Response: ${response.statusCode}');
      print('📡 Update Movie Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true) {
          // Recargar la lista
          await _loadMovies();
          _showSuccessSnackBar('Película actualizada correctamente');
        } else {
          throw Exception(data['message'] ?? 'Error al actualizar película');
        }
      } else {
        throw Exception('Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('❌ Error actualizando película: $e');
      _showErrorSnackBar('Error al actualizar película: $e');
    }
  }

  // Eliminar película
  Future<void> _deleteMovieFromAPI(int movieId) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.moviesEndpoint}/$movieId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📡 Delete Movie Response: ${response.statusCode}');
      print('📡 Delete Movie Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true) {
          // Recargar la lista
          await _loadMovies();
          _showSuccessSnackBar('Película eliminada correctamente');
        } else {
          throw Exception(data['message'] ?? 'Error al eliminar película');
        }
      } else {
        throw Exception('Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('❌ Error eliminando película: $e');
      _showErrorSnackBar('Error al eliminar película: $e');
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

  List<Movie> get _filteredMovies {
    List<Movie> filtered = _movies;
    
    if (_selectedFilter != 'Todas') {
      filtered = filtered.where((movie) => movie.status == _selectedFilter).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((movie) =>
        movie.title.toLowerCase().contains(_searchQuery) ||
        movie.director.toLowerCase().contains(_searchQuery) ||
        movie.genre.toLowerCase().contains(_searchQuery)
      ).toList();
    }
    
    return filtered;
  }

  Widget _buildSearchAndFilters() {
    return Row(
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
                hintText: 'Buscar películas...',
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
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: _loadMovies,
            icon: Icon(Icons.refresh, color: Colors.white.withOpacity(0.8)),
            tooltip: 'Recargar películas',
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    final activeMovies = _movies.where((m) => m.status == 'En Cartelera').length;
    final upcomingMovies = _movies.where((m) => m.status == 'Próximamente').length;
    final totalRevenue = _movies.fold<double>(0.0, (sum, movie) => sum + movie.revenue);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          _buildStatCard('En Cartelera', activeMovies.toString(), Icons.movie, _successGreen),
          const SizedBox(width: 12),
          _buildStatCard('Próximamente', upcomingMovies.toString(), Icons.upcoming, _warningAmber),
          const SizedBox(width: 12),
          _buildStatCard('Ingresos', '\$${totalRevenue.toStringAsFixed(0)}', Icons.attach_money, _primaryBlue),
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

  Widget _buildMoviesList() {
    if (_isLoading) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: _primaryBlue),
              const SizedBox(height: 16),
              Text(
                'Cargando películas...',
                style: TextStyle(color: _textMuted),
              ),
            ],
          ),
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
              ElevatedButton(
                onPressed: _loadMovies,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_movies.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.movie_outlined, color: _textMuted, size: 64),
              const SizedBox(height: 16),
              Text(
                'No hay películas disponibles',
                style: TextStyle(color: _textMuted, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Agrega tu primera película',
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
          onRefresh: _loadMovies,
          color: _primaryBlue,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            itemCount: _filteredMovies.length,
            itemBuilder: (context, index) {
              final movie = _filteredMovies[index];
              return _buildMovieCard(movie, index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMovieCard(Movie movie, int index) {
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
                  color: _getStatusColor(movie.status).withOpacity(0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Poster placeholder
                  Container(
                    width: 120,
                    height: 180,
                    decoration: BoxDecoration(
                      color: _getStatusColor(movie.status).withOpacity(0.2),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        movie.posterUrl,
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                  ),
                  // Información de la película
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  movie.title,
                                  style: const TextStyle(
                                    color: _textLight,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(movie.status),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  movie.status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert, color: _textMuted),
                                color: _surfaceBg,
                                onSelected: (value) => _handleMenuAction(value, movie),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'view',
                                    child: Row(
                                      children: [
                                        Icon(Icons.visibility, color: _primaryBlue, size: 18),
                                        const SizedBox(width: 8),
                                        Text('Ver Detalles', style: TextStyle(color: _textLight)),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, color: _successGreen, size: 18),
                                        const SizedBox(width: 8),
                                        Text('Editar', style: TextStyle(color: _textLight)),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'showtimes',
                                    child: Row(
                                      children: [
                                        Icon(Icons.schedule, color: _warningAmber, size: 18),
                                        const SizedBox(width: 8),
                                        Text('Funciones', style: TextStyle(color: _textLight)),
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
                          const SizedBox(height: 8),
                          Text(
                            'Dir. ${movie.director}',
                            style: TextStyle(
                              color: _textMuted,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              _buildChip(movie.genre, _primaryBlue),
                              _buildChip('${movie.duration} min', _textMuted),
                              _buildChip(movie.rating, _warningAmber),
                              _buildChip(movie.language, _purpleAccent),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            movie.description,
                            style: TextStyle(
                              color: _textMuted,
                              fontSize: 13,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildMovieStat('Precio', '\$${movie.price.toStringAsFixed(2)}', Icons.attach_money),
                              ),
                              Expanded(
                                child: _buildMovieStat('Funciones', movie.totalShows.toString(), Icons.movie_creation),
                              ),
                              Expanded(
                                child: _buildMovieStat('Tickets', movie.ticketsSold.toString(), Icons.confirmation_number),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
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

  Widget _buildMovieStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: _textMuted, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: _textLight,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: _textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'En Cartelera': return _successGreen;
      case 'Próximamente': return _warningAmber;
      case 'Finalizada': return _textMuted;
      default: return _primaryBlue;
    }
  }

  void _handleMenuAction(String action, Movie movie) {
    switch (action) {
      case 'view':
        _showMovieDetails(movie);
        break;
      case 'edit':
        _showEditMovieDialog(movie);
        break;
      case 'showtimes':
        _showShowtimesDialog(movie);
        break;
      case 'delete':
        _showDeleteConfirmation(movie);
        break;
    }
  }

  void _showAddMovieDialog() {
    _showMovieDialog(title: 'Agregar Película');
  }

  void _showEditMovieDialog(Movie movie) {
    _showMovieDialog(title: 'Editar Película', movie: movie);
  }

  void _showMovieDialog({required String title, Movie? movie}) {
    final titleController = TextEditingController(text: movie?.title ?? '');
    final directorController = TextEditingController(text: movie?.director ?? '');
    final durationController = TextEditingController(text: movie?.duration.toString() ?? '');
    final priceController = TextEditingController(text: movie?.price.toString() ?? '');
    final descriptionController = TextEditingController(text: movie?.description ?? '');
    String selectedGenre = movie?.genre ?? 'Acción';
    String selectedRating = movie?.rating ?? 'PG-13';
    String selectedStatus = movie?.status ?? 'Próximamente';
    String selectedLanguage = movie?.language ?? 'Español';
    DateTime selectedDate = movie?.releaseDate ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(color: _textLight)),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: _textLight),
                  decoration: _buildInputDecoration('Título'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: directorController,
                  style: const TextStyle(color: _textLight),
                  decoration: _buildInputDecoration('Director'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: durationController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: _textLight),
                        decoration: _buildInputDecoration('Duración (min)'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: _textLight),
                        decoration: _buildInputDecoration('Precio'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedGenre,
                        style: const TextStyle(color: _textLight),
                        decoration: _buildInputDecoration('Género'),
                        dropdownColor: _surfaceBg,
                        items: _genreOptions.map((genre) => DropdownMenuItem(
                          value: genre,
                          child: Text(genre, style: const TextStyle(color: _textLight)),
                        )).toList(),
                        onChanged: (value) => selectedGenre = value!,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedRating,
                        style: const TextStyle(color: _textLight),
                        decoration: _buildInputDecoration('Clasificación'),
                        dropdownColor: _surfaceBg,
                        items: _ratingOptions.map((rating) => DropdownMenuItem(
                          value: rating,
                          child: Text(rating, style: const TextStyle(color: _textLight)),
                        )).toList(),
                        onChanged: (value) => selectedRating = value!,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedStatus,
                        style: const TextStyle(color: _textLight),
                        decoration: _buildInputDecoration('Estado'),
                        dropdownColor: _surfaceBg,
                        items: ['En Cartelera', 'Próximamente', 'Finalizada'].map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status, style: const TextStyle(color: _textLight)),
                        )).toList(),
                        onChanged: (value) => selectedStatus = value!,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedLanguage,
                        style: const TextStyle(color: _textLight),
                        decoration: _buildInputDecoration('Idioma'),
                        dropdownColor: _surfaceBg,
                        items: ['Español', 'Inglés', 'Subtitulado'].map((lang) => DropdownMenuItem(
                          value: lang,
                          child: Text(lang, style: const TextStyle(color: _textLight)),
                        )).toList(),
                        onChanged: (value) => selectedLanguage = value!,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  style: const TextStyle(color: _textLight),
                  maxLines: 3,
                  decoration: _buildInputDecoration('Descripción'),
                ),
              ],
            ),
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
              _saveMovie(
                movie,
                titleController.text,
                directorController.text,
                int.tryParse(durationController.text) ?? 0,
                double.tryParse(priceController.text) ?? 0.0,
                descriptionController.text,
                selectedGenre,
                selectedRating,
                selectedStatus,
                selectedLanguage,
                selectedDate,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(movie == null ? 'Agregar' : 'Guardar'),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
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
    );
  }

  // Actualizar _saveMovie para usar API
  void _saveMovie(Movie? existingMovie, String title, String director, int duration,
      double price, String description, String genre, String rating,
      String status, String language, DateTime releaseDate) async {
    
    final movieData = Movie(
      id: existingMovie?.id ?? 0,
      title: title,
      genre: genre,
      director: director,
      duration: duration,
      rating: rating,
      releaseDate: releaseDate,
      description: description,
      posterUrl: existingMovie?.posterUrl ?? '🎬',
      status: status,
      language: language,
      price: price,
      totalShows: existingMovie?.totalShows ?? 0,
      ticketsSold: existingMovie?.ticketsSold ?? 0,
      revenue: existingMovie?.revenue ?? 0.0,
    );

    if (existingMovie == null) {
      await _addMovie(movieData);
    } else {
      await _updateMovie(movieData);
    }
  }

  // Actualizar _deleteMovie para usar API
  void _showDeleteConfirmation(Movie movie) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirmar eliminación', style: TextStyle(color: _textLight)),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${movie.title}"?',
          style: TextStyle(color: _textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: _textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteMovieFromAPI(movie.id);
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

  void _showMovieDetails(Movie movie) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(movie.posterUrl, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(child: Text(movie.title, style: const TextStyle(color: _textLight))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Director', movie.director),
              _buildDetailRow('Género', movie.genre),
              _buildDetailRow('Duración', '${movie.duration} minutos'),
              _buildDetailRow('Clasificación', movie.rating),
              _buildDetailRow('Idioma', movie.language),
              _buildDetailRow('Estado', movie.status),
              _buildDetailRow('Precio', '\$${movie.price.toStringAsFixed(2)}'),
              _buildDetailRow('Funciones', movie.totalShows.toString()),
              _buildDetailRow('Tickets vendidos', movie.ticketsSold.toString()),
              _buildDetailRow('Ingresos', '\$${movie.revenue.toStringAsFixed(2)}'),
              _buildDetailRow('Estreno', '${movie.releaseDate.day}/${movie.releaseDate.month}/${movie.releaseDate.year}'),
              const SizedBox(height: 12),
              Text('Descripción:', style: TextStyle(color: _textMuted, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(movie.description, style: const TextStyle(color: _textLight)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(color: _textMuted, fontWeight: FontWeight.w500),
            ),
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

  void _showShowtimesDialog(Movie movie) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.schedule, color: _warningAmber),
            const SizedBox(width: 8),
            Text('Funciones - ${movie.title}', style: const TextStyle(color: _textLight)),
          ],
        ),
        content: Text(
          'Aquí se mostrarían las funciones programadas para esta película.',
          style: TextStyle(color: _textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navegar a gestión de funciones
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _warningAmber,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Gestionar Funciones'),
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
            _buildMoviesList(),
          ],
        ),
      ),
    );
  }
  Widget _buildHeader() {
  return const Padding(
    padding: EdgeInsets.all(16),
    child: Text(
      "Administración de Películas",
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

}

// Actualizar la clase Movie con métodos de serialización
class Movie {
  int id;
  String title;
  String genre;
  String director;
  int duration;
  String rating;
  DateTime releaseDate;
  String description;
  String posterUrl;
  String status;
  String language;
  double price;
  int totalShows;
  int ticketsSold;
  double revenue;

  Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.director,
    required this.duration,
    required this.rating,
    required this.releaseDate,
    required this.description,
    required this.posterUrl,
    required this.status,
    required this.language,
    required this.price,
    required this.totalShows,
    required this.ticketsSold,
    required this.revenue,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      genre: json['genre'] ?? '',
      director: json['director'] ?? '',
      duration: json['duration'] ?? 0,
      rating: json['rating'] ?? '',
      releaseDate: json['release_date'] != null 
        ? DateTime.tryParse(json['release_date']) ?? DateTime.now()
        : DateTime.now(),
      description: json['description'] ?? '',
      posterUrl: json['poster_url'] ?? '🎬',
      status: json['status'] ?? 'Próximamente',
      language: json['language'] ?? 'Español',
      price: (json['price'] ?? 0).toDouble(),
      totalShows: json['total_shows'] ?? 0,
      ticketsSold: json['tickets_sold'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'genre': genre,
      'director': director,
      'duration': duration,
      'rating': rating,
      'release_date': releaseDate.toIso8601String().split('T')[0],
      'description': description,
      'poster_url': posterUrl,
      'status': status,
      'language': language,
      'price': price,
      'total_shows': totalShows,
      'tickets_sold': ticketsSold,
      'revenue': revenue,
    };
  }
}
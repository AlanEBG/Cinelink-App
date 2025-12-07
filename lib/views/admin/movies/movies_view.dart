import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../models/movie.dart';
import '../../../services/movie_service.dart';

class MoviesAdminPage extends StatefulWidget {
  const MoviesAdminPage({super.key});

  @override
  State<MoviesAdminPage> createState() => _MoviesAdminPageState();
}

class _MoviesAdminPageState extends State<MoviesAdminPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  final MovieService _movieService = MovieService();
  
  String _searchQuery = '';
  bool _isSearchFocused = false;
  final FocusNode _searchFocusNode = FocusNode();
  
  // Colores modernos
  static const Color _darkBg = Color(0xFF0F172A);
  static const Color _cardBg = Color(0xFF1E293B);
  static const Color _surfaceBg = Color(0xFF334155);
  static const Color _primaryBlue = Color(0xFF3B82F6);
  static const Color _successGreen = Color(0xFF10B981);
  static const Color _dangerRed = Color(0xFFEF4444);
  static const Color _textLight = Color(0xFFF8FAFC);
  static const Color _textMuted = Color(0xFF94A3B8);

  List<Movie> _movies = [];
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> _genreOptions = [
    'Acción', 'Drama', 'Comedia', 'Terror', 'Ciencia Ficción', 
    'Romance', 'Aventura', 'Suspenso', 'Animación', 'Documental'
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupSearchListener();
    _setupFocusListener();
    _loadMovies();
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

  Future<void> _loadMovies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final movies = await _movieService.getAllMovies();
      setState(() {
        _movies = movies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar películas: $e';
      });
    }
  }

  Future<void> _addMovie(Movie movie) async {
    try {
      await _movieService.createMovie(movie);
      await _loadMovies();
      _showSuccessSnackBar('Película agregada correctamente');
    } catch (e) {
      _showErrorSnackBar('Error al agregar película: $e');
    }
  }

  Future<void> _updateMovie(Movie movie) async {
    try {
      if (movie.movieId == null) {
        _showErrorSnackBar('Error: ID de película no encontrado');
        return;
      }
      
      await _movieService.updateMovie(movie.movieId!, movie);
      await _loadMovies();
      _showSuccessSnackBar('Película actualizada correctamente');
    } catch (e) {
      _showErrorSnackBar('Error al actualizar película: $e');
      print('Error detallado al actualizar: $e');
    }
  }

  Future<void> _deleteMovie(int movieId) async {
    try {
      await _movieService.deleteMovie(movieId);
      await _loadMovies();
      _showSuccessSnackBar('Película eliminada correctamente');
    } catch (e) {
      _showErrorSnackBar('Error al eliminar película: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: _successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: _dangerRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  List<Movie> get _filteredMovies {
    if (_searchQuery.isEmpty) return _movies;
    
    return _movies.where((movie) =>
      movie.movieTitle.toLowerCase().contains(_searchQuery) ||
      movie.movieGenre.toLowerCase().contains(_searchQuery) ||
      movie.movieDescription.toLowerCase().contains(_searchQuery)
    ).toList();
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
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gestión de Películas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Administrar cartelera de cine',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: _successGreen,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _successGreen.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showAddMovieDialog(),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: _isSearchFocused
            ? [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: TextStyle(
          color: _darkBg,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Buscar películas por título, género o descripción...',
          hintStyle: TextStyle(
            color: _textMuted.withOpacity(0.6),
            fontSize: 15,
            fontWeight: FontWeight.normal,
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(14),
            child: Icon(
              Icons.search_rounded,
              color: _isSearchFocused ? _primaryBlue : _textMuted.withOpacity(0.6),
              size: 26,
            ),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _dangerRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: _dangerRed,
                      size: 22,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _searchFocusNode.unfocus();
                    },
                  ),
                )
              : _isSearchFocused
                  ? Padding(
                      padding: const EdgeInsets.all(14),
                      child: Icon(
                        Icons.keyboard_rounded,
                        color: _primaryBlue.withOpacity(0.5),
                        size: 22,
                      ),
                    )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final totalMovies = _movies.length;
    final uniqueGenres = _movies.map((m) => m.movieGenre).toSet().length;
    final totalDuration = _movies.fold(0, (sum, m) => sum + m.movieDurationMinutes);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          _buildStatCard('Total', totalMovies.toString(), Icons.movie, _primaryBlue),
          const SizedBox(width: 12),
          _buildStatCard('Géneros', uniqueGenres.toString(), Icons.category, _successGreen),
          const SizedBox(width: 12),
          _buildStatCard('Horas', '${(totalDuration / 60).toStringAsFixed(1)}h', Icons.access_time, Colors.purple),
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
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: _textLight,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: _textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
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
              ElevatedButton.icon(
                onPressed: _loadMovies,
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

    if (_filteredMovies.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _searchQuery.isNotEmpty ? Icons.search_off : Icons.movie_outlined,
                color: _textMuted,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isNotEmpty ? 'No se encontraron películas' : 'No hay películas disponibles',
                style: TextStyle(color: _textMuted, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isNotEmpty ? 'Intenta con otra búsqueda' : 'Agrega tu primera película',
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
              child: Row(
                children: [
                  // Poster
                  Container(
                    width: 120,
                    height: 180,
                    decoration: BoxDecoration(
                      color: _primaryBlue.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    child: movie.movieImageUrl != null && movie.movieImageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                            child: Image.network(
                              movie.movieImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Icon(Icons.movie, size: 48, color: Colors.white54),
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.movie, size: 48, color: Colors.white54),
                          ),
                  ),
                  // Información
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
                                  movie.movieTitle,
                                  style: const TextStyle(
                                    color: _textLight,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: PopupMenuButton<String>(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 160,
                                    maxWidth: 200,
                                  ),
                                  icon: Icon(Icons.more_vert, color: _textMuted, size: 20),
                                  color: _surfaceBg,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  onSelected: (value) => _handleMenuAction(value, movie),
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'view',
                                      height: 48,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.visibility, color: _primaryBlue, size: 18),
                                          const SizedBox(width: 12),
                                          Flexible(
                                            child: Text(
                                              'Ver Detalles',
                                              style: TextStyle(color: _textLight, fontSize: 14),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'edit',
                                      height: 48,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.edit, color: _successGreen, size: 18),
                                          const SizedBox(width: 12),
                                          Flexible(
                                            child: Text(
                                              'Editar',
                                              style: TextStyle(color: _textLight, fontSize: 14),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      height: 48,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.delete, color: _dangerRed, size: 18),
                                          const SizedBox(width: 12),
                                          Flexible(
                                            child: Text(
                                              'Eliminar',
                                              style: TextStyle(color: _textLight, fontSize: 14),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              _buildChip(movie.movieGenre, _primaryBlue),
                              _buildChip('${movie.movieDurationMinutes} min', Colors.orange),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            movie.movieDescription,
                            style: TextStyle(
                              color: _textMuted,
                              fontSize: 13,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
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

  void _handleMenuAction(String action, Movie movie) {
    switch (action) {
      case 'view':
        _showMovieDetails(movie);
        break;
      case 'edit':
        _showEditMovieDialog(movie);
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
    final titleController = TextEditingController(text: movie?.movieTitle ?? '');
    final descriptionController = TextEditingController(text: movie?.movieDescription ?? '');
    final durationController = TextEditingController(
      text: movie != null && movie.movieDurationMinutes > 0 
        ? movie.movieDurationMinutes.toString() 
        : ''
    );
    final imageUrlController = TextEditingController(text: movie?.movieImageUrl ?? '');
    final trailerController = TextEditingController(text: movie?.movieTrailer ?? '');
    String selectedGenre = movie?.movieGenre ?? _genreOptions.first;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
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
                        movie == null ? Icons.add_circle_outline : Icons.edit,
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
                        onPressed: () => Navigator.pop(dialogContext),
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
                        _buildFormLabel('Título de la película *'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: titleController,
                          style: const TextStyle(color: _textLight, fontSize: 16),
                          decoration: _buildInputDecoration('Ej: Avatar', Icons.movie),
                        ),
                        const SizedBox(height: 20),
                        
                        _buildFormLabel('Descripción *'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: descriptionController,
                          style: const TextStyle(color: _textLight, fontSize: 16),
                          maxLines: 4,
                          decoration: _buildInputDecoration(
                            'Describe la trama de la película...',
                            Icons.description,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        _buildFormLabel('Duración (min) *'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: durationController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: _textLight, fontSize: 16),
                          decoration: _buildInputDecoration('120', Icons.access_time),
                        ),
                        const SizedBox(height: 20),
                        
                        _buildFormLabel('Género *'),
                        const SizedBox(height: 8),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              final result = await showDialog<String>(
                                context: dialogContext,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: _cardBg,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  title: const Text('Seleccionar Género', style: TextStyle(color: _textLight)),
                                  content: SizedBox(
                                    width: double.maxFinite,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: _genreOptions.length,
                                      itemBuilder: (context, index) {
                                        final genre = _genreOptions[index];
                                        final isSelected = genre == selectedGenre;
                                        return ListTile(
                                          leading: Icon(
                                            Icons.category,
                                            color: isSelected ? _primaryBlue : _textMuted,
                                          ),
                                          title: Text(
                                            genre,
                                            style: TextStyle(
                                              color: isSelected ? _primaryBlue : _textLight,
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                          trailing: isSelected 
                                            ? Icon(Icons.check_circle, color: _primaryBlue)
                                            : null,
                                          onTap: () => Navigator.pop(ctx, genre),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                              
                              if (result != null) {
                                setDialogState(() {
                                  selectedGenre = result;
                                });
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: _surfaceBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _textMuted.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.category, color: _textMuted, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      selectedGenre,
                                      style: const TextStyle(
                                        color: _textLight,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.arrow_drop_down, color: _textMuted),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        _buildFormLabel('URL de la imagen'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: imageUrlController,
                          style: const TextStyle(color: _textLight, fontSize: 16),
                          decoration: _buildInputDecoration(
                            'https://ejemplo.com/poster.jpg',
                            Icons.image,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        _buildFormLabel('URL del trailer'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: trailerController,
                          style: const TextStyle(color: _textLight, fontSize: 16),
                          decoration: _buildInputDecoration(
                            'https://youtube.com/watch?v=...',
                            Icons.play_circle_outline,
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
                        onPressed: () => Navigator.pop(dialogContext),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(color: _textMuted, fontSize: 15),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_validateMovieForm(
                              titleController.text,
                              descriptionController.text,
                              durationController.text,
                            )) {
                              Navigator.pop(dialogContext);
                              _saveMovie(
                                movie,
                                titleController.text,
                                descriptionController.text,
                                int.tryParse(durationController.text) ?? 0,
                                selectedGenre,
                                imageUrlController.text.isNotEmpty ? imageUrlController.text : null,
                                trailerController.text.isNotEmpty ? trailerController.text : null,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(movie == null ? Icons.add : Icons.save, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                movie == null ? 'Agregar' : 'Guardar',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      )
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

  void _saveMovie(Movie? existingMovie, String title, String description, 
      int duration, String genre, String? imageUrl, String? trailer) async {
    
    final movieData = Movie(
      movieId: existingMovie?.movieId,
      movieTitle: title,
      movieDescription: description,
      movieDurationMinutes: duration,
      movieGenre: genre,
      movieImageUrl: imageUrl,
      movieTrailer: trailer,
    );

    if (existingMovie == null) {
      await _addMovie(movieData);
    } else {
      await _updateMovie(movieData);
    }
  }

  bool _validateMovieForm(String title, String description, String duration) {
    if (title.trim().isEmpty) {
      _showErrorSnackBar('El título es requerido');
      return false;
    }
    if (description.trim().isEmpty) {
      _showErrorSnackBar('La descripción es requerida');
      return false;
    }
    if (duration.trim().isEmpty || int.tryParse(duration) == null || int.parse(duration) <= 0) {
      _showErrorSnackBar('La duración debe ser un número válido mayor a 0');
      return false;
    }
    return true;
  }

  void _showDeleteConfirmation(Movie movie) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: _dangerRed, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Confirmar eliminación',
                style: TextStyle(color: _textLight, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${movie.movieTitle}"? Esta acción no se puede deshacer.',
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
              if (movie.movieId != null) {
                await _deleteMovie(movie.movieId!);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _dangerRed,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Eliminar', style: TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }

  void _showMovieDetails(Movie movie) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
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
                    Icon(Icons.movie, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        movie.movieTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (movie.movieImageUrl != null && movie.movieImageUrl!.isNotEmpty) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            movie.movieImageUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 200,
                              color: _surfaceBg,
                              child: const Center(
                                child: Icon(Icons.broken_image, size: 48, color: Colors.white54),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      _buildDetailRow('Género', movie.movieGenre, Icons.category),
                      const SizedBox(height: 12),
                      _buildDetailRow('Duración', '${movie.movieDurationMinutes} minutos', Icons.access_time),
                      const SizedBox(height: 20),
                      Text(
                        'Descripción:',
                        style: TextStyle(
                          color: _textMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        movie.movieDescription,
                        style: TextStyle(
                          color: _textLight,
                          height: 1.5,
                          fontSize: 14,
                        ),
                      ),
                      if (movie.movieTrailer != null && movie.movieTrailer!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _openTrailer(movie.movieTrailer!),
                            icon: const Icon(Icons.play_circle_outline, size: 22),
                            label: const Text('Ver Trailer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Footer
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
                        'Cerrar',
                        style: TextStyle(color: _textMuted, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  Future<void> _openTrailer(String trailerUrl) async {
    try {
      // Extraer el ID del video de YouTube
      String? videoId = YoutubePlayer.convertUrlToId(trailerUrl);
      
      if (videoId == null) {
        _showErrorSnackBar('URL de YouTube inválida');
        return;
      }

      // Crear el controlador del reproductor
      final YoutubePlayerController controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: true,
        ),
      );

      // Mostrar el reproductor en un diálogo
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.play_circle_outline, color: _primaryBlue, size: 24),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Trailer',
                        style: TextStyle(
                          color: _textLight,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        controller.dispose();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close, color: _textMuted),
                    ),
                  ],
                ),
              ),
              // Player
              YoutubePlayer(
                controller: controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: _primaryBlue,
                progressColors: ProgressBarColors(
                  playedColor: _primaryBlue,
                  handleColor: _primaryBlue,
                  bufferedColor: _textMuted,
                  backgroundColor: _surfaceBg,
                ),
                onReady: () {
                  print('Player listo');
                },
                onEnded: (data) {
                  controller.dispose();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ).then((_) {
        // Asegurarse de que el controlador se limpie cuando se cierra el diálogo
        controller.dispose();
      });
    } catch (e) {
      print('Error al abrir trailer: $e');
      _showErrorSnackBar('Error al reproducir el trailer: ${e.toString()}');
    }
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceBg.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _primaryBlue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _primaryBlue, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: _textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: _textLight,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
            _buildMoviesList(),
          ],
        ),
      ),
    );
  }
}
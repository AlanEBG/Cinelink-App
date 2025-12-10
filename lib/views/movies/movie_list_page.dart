import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../services/movie_service.dart';
import '../../models/movie.dart';
import '../../app/theme.dart';
import 'movie_detail_page.dart';

class MovieListPage extends StatefulWidget {
  const MovieListPage({super.key});

  @override
  State<MovieListPage> createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage>
    with TickerProviderStateMixin {
  final MovieService _movieService = MovieService();
  late Future<List<Movie>> _moviesFuture;
  final TextEditingController _searchController = TextEditingController();
  final Map<String, PageController> _controllers = {};
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadMovies();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim().toLowerCase();
      });
    });
  }

  void _loadMovies() {
    setState(() {
      _moviesFuture = _movieService.getMovies();
    });
  }

  Future<void> _refresh() async {
    _loadMovies();
    await _moviesFuture;
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _searchController.dispose();
    super.dispose();
  }

  /// Estrategia estilo Netflix: Una película aparece en múltiples categorías
  /// Si una película es "Terror, Ciencia Ficción", aparecerá en ambas secciones
  Map<String, List<Movie>> _groupByGenre(List<Movie> movies) {
    final Map<String, List<Movie>> grouped = {};

    for (final movie in movies) {
      // Obtener todos los géneros de la película (separados por comas)
      final genresString = movie.movieGenre.trim();

      // Separar por comas y limpiar espacios
      final genresList = genresString
          .split(',')
          .map((g) => g.trim())
          .where((g) => g.isNotEmpty)
          .toList();

      // Agregar la película a cada categoría de género
      for (final genre in genresList) {
        grouped.putIfAbsent(genre, () => []).add(movie);
      }
    }

    // Ordenar las categorías alfabéticamente (opcional)
    final sortedKeys = grouped.keys.toList()..sort();
    final sortedMap = <String, List<Movie>>{};
    for (final key in sortedKeys) {
      sortedMap[key] = grouped[key]!;
    }

    return sortedMap;
  }

  List<Movie> _filterMovies(List<Movie> movies) {
    if (_query.isEmpty) return movies;

    return movies.where((m) {
      final title = m.movieTitle.toLowerCase();
      final genre = m.movieGenre.toLowerCase();
      return title.contains(_query) || genre.contains(_query);
    }).toList();
  }

  // Función auxiliar para obtener solo el primer género
  String _getFirstGenre(String genre) {
    if (genre.isEmpty) return '';
    // Si hay comas, tomar solo la primera palabra
    if (genre.contains(',')) {
      return genre.split(',')[0].trim();
    }
    return genre.trim();
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.local_movies,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Cinelink',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.grey300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          filled: false,
          hintText: 'Buscar películas...',
          hintStyle: GoogleFonts.poppins(
            color: AppColors.textTertiary,
            fontSize: 15,
          ),
          prefixIcon: Icon(Icons.search, color: AppColors.primary, size: 22),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close, color: AppColors.grey500, size: 20),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
        ),
      ),
    );
  }

  Widget _movieCard(Movie movie, double scale, double opacity) {
    final title = movie.movieTitle;
    final genre = movie.movieGenre;
    final firstGenre = _getFirstGenre(
      genre,
    ); // Solo el primer género para el badge
    final duration = movie.movieDurationMinutes;
    final image = movie.movieImageUrl;

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailPage(movie: movie),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: AspectRatio(
                aspectRatio: 0.65,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Imagen de fondo
                    image != null && image.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: image,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => _placeholder(title),
                            errorWidget: (context, url, error) =>
                                _placeholder(title),
                          )
                        : _placeholder(title),

                    // Gradiente oscuro en la parte inferior
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.8),
                          ],
                          stops: const [0.5, 0.75, 1.0],
                        ),
                      ),
                    ),

                    // Contenido inferior
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Título
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Información (género y duración)
                            Row(
                              children: [
                                // Badge de género (solo primer género)
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.sm,
                                      ),
                                    ),
                                    child: Text(
                                      firstGenre.toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Duración
                                Icon(
                                  Icons.access_time,
                                  color: Colors.white.withOpacity(0.9),
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$duration min',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Botón de detalles
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          MovieDetailPage(movie: movie),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.textPrimary,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.md,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Ver detalles',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder(String title) {
    final initials = title
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0] : '')
        .join();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildGenreSection(String genre, List<Movie> movies) {
    _controllers.putIfAbsent(
      genre,
      () => PageController(viewportFraction: 0.55),
    );

    final controller = _controllers[genre]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  genre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${movies.length}',
                  style: GoogleFonts.poppins(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 380,
          child: PageView.builder(
            controller: controller,
            itemCount: movies.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  double scale = 1.0;
                  double opacity = 1.0;

                  if (controller.hasClients) {
                    double page =
                        controller.page ?? controller.initialPage.toDouble();
                    double distance = (page - index).abs();
                    scale = (1.0 - (distance * 0.1)).clamp(0.85, 1.0);
                    opacity = (1.0 - (distance * 0.3)).clamp(0.7, 1.0);
                  }

                  return _movieCard(movies[index], scale, opacity);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Skeleton loader para el estado de carga de películas
  Widget _buildMovieSkeletonLoader() {
    return Column(
      children: [
        _buildAppBar(),
        const SizedBox(height: 16),
        _buildSearchBar(),
        const SizedBox(height: 24),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // Skeleton para sección de género
              _buildSkeletonGenreSection('Películas'),
              const SizedBox(height: 24),
              _buildSkeletonGenreSection('Más películas'),
            ],
          ),
        ),
      ],
    );
  }

  // Skeleton para una sección de género
  Widget _buildSkeletonGenreSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 24,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Tarjetas de películas skeleton
        SizedBox(
          height: 420,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 260,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Placeholder para imagen (proporción 0.65)
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(AppRadius.xl),
                            ),
                          ),
                        ),
                      ),
                      // Placeholder para contenido inferior
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título
                            Container(
                              height: 20,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 20,
                              width: 180,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Género y duración
                            Row(
                              children: [
                                Container(
                                  height: 24,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.sm,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  height: 16,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Botón
                            Container(
                              height: 40,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: SafeArea(
        child: FutureBuilder<List<Movie>>(
          future: _moviesFuture,
          builder: (context, snapshot) {
            // Loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildMovieSkeletonLoader();
            }

            // Error
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar películas',
                        style: GoogleFonts.poppins(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadMovies,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Empty
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refresh,
                color: AppColors.primary,
                child: ListView(
                  children: [
                    _buildAppBar(),
                    const SizedBox(height: 100),
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.movie_outlined,
                            size: 80,
                            color: AppColors.grey400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay películas disponibles',
                            style: GoogleFonts.poppins(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            // Success
            final movies = snapshot.data!;
            final filtered = _filterMovies(movies);
            final grouped = _groupByGenre(filtered);

            // Sin resultados de búsqueda
            if (filtered.isEmpty && _query.isNotEmpty) {
              return RefreshIndicator(
                onRefresh: _refresh,
                color: AppColors.primary,
                child: ListView(
                  children: [
                    _buildAppBar(),
                    _buildSearchBar(),
                    const SizedBox(height: 100),
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: AppColors.grey400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No se encontraron películas',
                            style: GoogleFonts.poppins(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Intenta con otro término',
                            style: GoogleFonts.poppins(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.primary,
              child: ListView(
                children: [
                  _buildAppBar(),
                  _buildSearchBar(),
                  ...grouped.entries
                      .map((e) => _buildGenreSection(e.key, e.value))
                      .toList(),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'package:cinelink_app/views/movies/movie_detail_page.dart';
import 'package:flutter/material.dart';
import '../../services/movie_service.dart';
import '../../models/movie.dart';

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

  // Paleta de colores moderna
  static const Color _bg = Color(0xFF0F0F23);
  static const Color _cardBg = Color(0xFF1A1A2E);
  static const Color _accent = Color(0xFF6C63FF);
  static const Color _accentLight = Color(0xFF9C88FF);
  static const Color _orange = Color(0xFFFF6B35);
  static const Color _textPrimary = Color(0xFFE8E8E8);
  static const Color _textSecondary = Color(0xFF9A9A9A);

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

  Map<String, List<Movie>> _groupByGenre(List<Movie> movies) {
    final Map<String, List<Movie>> grouped = {};
    for (final m in movies) {
      final genre = (m.movieGenre ?? 'Populares').trim();
      grouped.putIfAbsent(genre, () => []).add(m);
    }
    return grouped;
  }

  List<Movie> _filterMovies(List<Movie> movies) {
    if (_query.isEmpty) return movies;

    return movies.where((m) {
      final title = (m.movieTitle ?? '').toLowerCase();
      final genre = (m.movieGenre ?? '').toLowerCase();
      return title.contains(_query) || genre.contains(_query);
    }).toList();
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_bg, _bg.withOpacity(0.9)],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_accent, _accentLight]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_movies,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Cinelink',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.person_outline,
                color: _textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: _textPrimary),
        decoration: InputDecoration(
          filled: true,
          fillColor: _cardBg,
          hintText: 'Buscar películas...',
          hintStyle: const TextStyle(color: _textSecondary),
          prefixIcon: const Icon(Icons.search, color: _accent),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: _textSecondary),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
        ),
      ),
    );
  }

  Widget _movieCard(Movie movie, double scale, double opacity) {
    final title = movie.movieTitle ?? 'Sin título';
    final genre = movie.movieGenre ?? '';
    final image = movie.movieImageUrl;

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _accent.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 0.65,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagen
                  image != null && image.isNotEmpty
                      ? Image.network(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(title),
                        )
                      : _placeholder(title),

                  // Gradiente
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),

                  // Contenido
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              genre,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
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
                                // TODO: Navegar a detalles de película
                                print('Ver detalles: $title');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _accent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'Detalles',
                                style: TextStyle(fontWeight: FontWeight.w600),
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
    );
  }

  Widget _placeholder(String title) {
    final initials = title
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0] : '')
        .join();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_accent, _accentLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
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
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 15),
          child: Text(
            genre,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: FutureBuilder<List<Movie>>(
          future: _moviesFuture,
          builder: (context, snapshot) {
            // Loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: _accent),
                    const SizedBox(height: 16),
                    Text(
                      'Cargando películas...',
                      style: TextStyle(color: _textSecondary),
                    ),
                  ],
                ),
              );
            }

            // Error
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: _orange, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar películas',
                      style: TextStyle(color: _textPrimary, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      style: TextStyle(color: _textSecondary, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadMovies,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Empty
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refresh,
                color: _accent,
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
                            color: _textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay películas disponibles',
                            style: TextStyle(
                              color: _textSecondary,
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
                color: _accent,
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
                            color: _textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No se encontraron películas',
                            style: TextStyle(color: _textPrimary, fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Intenta con otro término',
                            style: TextStyle(
                              color: _textSecondary,
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
              color: _accent,
              child: ListView(
                children: [
                  _buildAppBar(),
                  _buildSearchBar(),
                  ...grouped.entries
                      .map((e) => _buildGenreSection(e.key, e.value))
                      .toList(),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

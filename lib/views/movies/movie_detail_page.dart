import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/movie.dart';
import '../../controllers/showtime_controller.dart';
import '../showtimes/showtime_list_page.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;

  const MovieDetailPage({super.key, required this.movie});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showWhiteBackground = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Cambia a fondo blanco cuando el scroll supera los 400 píxeles
    // (aproximadamente donde termina el degradado)
    if (_scrollController.offset > 400 && !_showWhiteBackground) {
      setState(() {
        _showWhiteBackground = true;
      });
    } else if (_scrollController.offset <= 400 && _showWhiteBackground) {
      setState(() {
        _showWhiteBackground = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background fijo (no hace scroll) con imagen difuminada
          Positioned.fill(child: _buildBlurredBackground()),
          // Contenido scrolleable
          SafeArea(
            child: Column(
              children: [
                // AppBar personalizado
                _buildAppBar(context),
                // Contenido scrolleable
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        // Poster principal con badge de "Preventa"
                        _buildHeroPoster(context),
                        const SizedBox(height: 24),
                        // Título de la película
                        _buildMovieTitle(context),
                        const SizedBox(height: 16),
                        // Información básica (año, duración)
                        _buildBasicInfo(context),
                        const SizedBox(height: 12),
                        // Género
                        _buildGenreInfo(context),
                        const SizedBox(height: 20),
                        // Formatos disponibles (4DX, IMAX, etc.)
                        _buildFormatsSection(context),
                        const SizedBox(height: 24),
                        // Botón "Ver horarios"
                        _buildHorariosButton(context),
                        const SizedBox(height: 16),
                        // Botón "Ver tráiler"
                        _buildTrailerButton(context),
                        const SizedBox(height: 32),
                        // Sinopsis (con fondo para mejor legibilidad)
                        _buildSynopsisSection(context),
                        const SizedBox(height: 32),
                        // Dirigida por
                        _buildDirectorSection(context),
                        const SizedBox(height: 32),
                        // Reparto
                        _buildCastSection(context),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurredBackground() {
    // Si se ha hecho scroll suficiente, muestra solo fondo blanco
    if (_showWhiteBackground) {
      return Container(color: Colors.white);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Imagen con blur aplicado directamente
        if (widget.movie.movieImageUrl != null &&
            widget.movie.movieImageUrl!.isNotEmpty)
          ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: 25,
              sigmaY: 25,
              tileMode: TileMode.decal,
            ),
            child: CachedNetworkImage(
              imageUrl: widget.movie.movieImageUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, url) => Container(color: Colors.grey[300]),
              errorWidget: (context, url, error) =>
                  Container(color: Colors.grey[300]),
            ),
          )
        else
          Container(color: Colors.grey[300]),
        // Degradado sutil para integrar con el contenido
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.02),
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.7),
                Colors.white.withOpacity(0.95),
                Colors.white,
              ],
              stops: const [0.0, 0.25, 0.45, 0.65, 0.85, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroPoster(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Poster principal
          Container(
            width: 240,
            height: 360,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                  spreadRadius: -5,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child:
                  widget.movie.movieImageUrl != null &&
                      widget.movie.movieImageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: widget.movie.movieImageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF4F7DF3),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) {
                        return _buildPosterPlaceholder();
                      },
                    )
                  : _buildPosterPlaceholder(),
            ),
          ),
          // Badge "Preventa" (opcional - puedes agregar lógica condicional)
          //  Positioned(
          //  top: -10,
          //  left: -10,
          //  child: Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          // decoration: BoxDecoration(
          //  color: const Color(0xFF00D9FF),
          //  borderRadius: BorderRadius.circular(20),
          //  boxShadow: [
          //  BoxShadow(
          //    color: const Color(0xFF00D9FF).withOpacity(0.4),
          //     blurRadius: 8,
          //     offset: const Offset(0, 4),
          //   ),
        ],
      ),
      // child: Text(
      //  'Preventa',
      // style: GoogleFonts.poppins(
      //   fontSize: 12,
      // fontWeight: FontWeight.bold,
      // color: Colors.black87,
      //     ),
      //  ),
      // ),
      // ),
      //  ],
      //  ),
    );
  }

  Widget _buildPosterPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(Icons.movie, size: 80, color: Colors.white54),
      ),
    );
  }

  Widget _buildMovieTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        widget.movie.movieTitle,
        style: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1E2A47),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBasicInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            '2025',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('|', style: TextStyle(color: Colors.grey[400])),
          ),
          Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            '${widget.movie.movieDurationMinutes} min',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_movies, size: 16, color: Colors.black54),
          const SizedBox(width: 6),
          Text(
            widget.movie.movieGenre.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatsSection(BuildContext context) {
    final formats = [
      {'name': '4DX', 'available': true},
      {'name': 'IMAX', 'available': true},
      {'name': 'MACRO XE', 'available': false},
      {'name': 'PLUUS', 'available': false},
      {'name': 'SCREEN X', 'available': false},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: formats.map((format) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: format['available'] as bool
                  ? Colors.white
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: format['available'] as bool
                    ? Colors.grey[300]!
                    : Colors.grey[300]!,
              ),
            ),
            child: Text(
              format['name'] as String,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: format['available'] as bool
                    ? const Color(0xFF1E2A47)
                    : Colors.grey[400],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHorariosButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ElevatedButton(
        onPressed: () {
          if (widget.movie.movieId != null) {
            context.read<ShowtimeController>().clear();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShowtimeListPage(movie: widget.movie),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error: ID de película no disponible'),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4F7DF3),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: const Color(0xFF4F7DF3).withOpacity(0.3),
        ),
        child: Text(
          'Ver horarios',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildTrailerButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: OutlinedButton(
        onPressed: () {
          if (widget.movie.movieTrailer != null &&
              widget.movie.movieTrailer!.isNotEmpty) {
            _showTrailerDialog(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tráiler no disponible'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1E2A47),
          padding: const EdgeInsets.symmetric(vertical: 18),
          side: BorderSide(color: Colors.grey[300]!, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ver tráiler',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFF4F7DF3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSynopsisSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sinopsis',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E2A47),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.movie.movieDescription,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectorSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dirigida por',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E2A47),
              ),
            ),
            const SizedBox(height: 16),
            _buildDirectorCard(name: 'Director Name', imageUrl: null),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectorCard({required String name, String? imageUrl}) {
    return Row(
      children: [
        Container(
          width: 80,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPersonPlaceholder();
                    },
                  ),
                )
              : _buildPersonPlaceholder(),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E2A47),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCastSection(BuildContext context) {
    // Datos de ejemplo - reemplazar con datos reales
    final cast = [
      {'name': 'Actor 1', 'imageUrl': null},
      {'name': 'Actor 2', 'imageUrl': null},
      {'name': 'Actor 3', 'imageUrl': null},
      {'name': 'Actor 4', 'imageUrl': null},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reparto',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E2A47),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: cast.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _buildCastMemberCard(
                      name: cast[index]['name'] as String,
                      imageUrl: cast[index]['imageUrl'] as String?,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCastMemberCard({required String name, String? imageUrl}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 120,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPersonPlaceholder();
                    },
                  ),
                )
              : _buildPersonPlaceholder(),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 120,
          child: Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1E2A47),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonPlaceholder() {
    return Center(child: Icon(Icons.person, size: 50, color: Colors.grey[400]));
  }

  // Extraer video ID de YouTube de la URL
  String? _extractYouTubeId(String url) {
    return YoutubePlayer.convertUrlToId(url);
  }

  // Mostrar diálogo con reproductor de YouTube
  void _showTrailerDialog(BuildContext context) {
    final videoId = _extractYouTubeId(widget.movie.movieTrailer!);

    if (videoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'URL de YouTube inválida. Debe ser una URL válida de YouTube.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        controlsVisibleAtStart: true,
        hideControls: false,
        loop: false,
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Encabezado del diálogo
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.play_circle_outline,
                            color: Color(0xFF4F7DF3),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tráiler',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            controller.pause();
                            controller.dispose();
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Reproductor de YouTube
                Container(
                  color: Colors.black,
                  child: YoutubePlayer(
                    controller: controller,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: const Color(0xFF4F7DF3),
                    progressColors: const ProgressBarColors(
                      playedColor: Color(0xFF4F7DF3),
                      handleColor: Color(0xFF4F7DF3),
                      bufferedColor: Colors.grey,
                      backgroundColor: Colors.white24,
                    ),
                    onReady: () {
                      print('Reproductor listo: $videoId');
                    },
                    onEnded: (metadata) {
                      controller.dispose();
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) {
      // Asegurarse de limpiar el controlador al cerrar
      if (controller.value.isReady) {
        controller.pause();
      }
      controller.dispose();
    });
  }
}

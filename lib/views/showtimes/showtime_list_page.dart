import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/movie.dart';
import '../../models/showtime.dart';
import '../../controllers/showtime_controller.dart';
import '../../controllers/seat_controller.dart';
import '../../widgets/showtime_card.dart';
import '../seats/seat_selection_page.dart';

class ShowtimeListPage extends StatefulWidget {
  final Movie movie;

  const ShowtimeListPage({super.key, required this.movie});

  @override
  State<ShowtimeListPage> createState() => _ShowtimeListPageState();
}

class _ShowtimeListPageState extends State<ShowtimeListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('=== DEBUG SHOWTIME_LIST_PAGE - INIT ===');
      print('Movie: ${widget.movie.movieTitle}');
      print('Movie ID: ${widget.movie.movieId}');
      print('Movie Image URL: ${widget.movie.movieImageUrl}');
      print('=======================================');

      if (widget.movie.movieId != null) {
        context.read<ShowtimeController>().loadShowtimesByMovie(
          widget.movie.movieId!,
        );
      } else {
        print('!!! ERROR: movieId es NULL !!!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background con degradado
          Positioned.fill(child: _buildBlurredBackground()),
          // Contenido
          SafeArea(
            child: Consumer<ShowtimeController>(
              builder: (context, controller, child) {
                if (controller.isLoading && !controller.hasShowtimes) {
                  return _buildLoadingState();
                }

                if (controller.hasError) {
                  return _buildErrorState(controller);
                }

                if (!controller.hasShowtimes) {
                  return _buildEmptyState();
                }

                return Column(
                  children: [
                    _buildAppBar(context, controller),
                    _buildMovieInfo(),
                    _buildFilters(controller),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return RefreshIndicator(
                            onRefresh: () => controller.refresh(),
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: Container(
                                  color: Colors.white,
                                  child: _buildShowtimesList(controller),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurredBackground() {
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

  Widget _buildAppBar(BuildContext context, ShowtimeController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          Text(
            'Funciones',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          GestureDetector(
            onTap: () => controller.refresh(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.refresh, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.movie.movieTitle,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 18,
                color: Colors.white.withOpacity(0.9),
              ),
              const SizedBox(width: 6),
              Text(
                '${widget.movie.movieDurationMinutes} min',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '|',
                  style: TextStyle(color: Colors.white.withOpacity(0.6)),
                ),
              ),
              Icon(
                Icons.theaters,
                size: 18,
                color: Colors.white.withOpacity(0.9),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.movie.movieGenre.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(ShowtimeController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filtro de fecha
          Text(
            'Fecha',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E2A47),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (controller.availableDates.isNotEmpty)
                  _buildDateChip(
                    label: 'Hoy',
                    isSelected:
                        controller.selectedDate != null &&
                        _isSameDay(
                          controller.selectedDate!,
                          controller.availableDates.first,
                        ),
                    onTap: () => controller.filterByDate(
                      controller.availableDates.first,
                    ),
                  ),
                if (controller.availableDates.isNotEmpty)
                  const SizedBox(width: 8),
                ...controller.availableDates.skip(1).map((date) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildDateChip(
                      label: _formatDate(date),
                      isSelected:
                          controller.selectedDate != null &&
                          _isSameDay(controller.selectedDate!, date),
                      onTap: () => controller.filterByDate(date),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Filtro de idioma
          Text(
            'Idioma',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E2A47),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildLanguageChip(
                  label: 'Todos',
                  isSelected: controller.selectedLanguage == null,
                  onTap: () => controller.filterByLanguage(null),
                ),
                const SizedBox(width: 8),
                ...controller.availableLanguages.map((language) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildLanguageChip(
                      label: _getLanguageLabel(language),
                      isSelected: controller.selectedLanguage == language,
                      onTap: () => controller.filterByLanguage(language),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F7DF3) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF4F7DF3) : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4F7DF3).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildDateChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF3B6D).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF3B6D) : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xFFFF3B6D) : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildShowtimesList(ShowtimeController controller) {
    final showtimes = controller.getAvailableShowtimes();

    print('=== DEBUG _buildShowtimesList ===');
    print('Total showtimes disponibles: ${showtimes.length}');
    if (showtimes.isNotEmpty) {
      print('Primeros 3 showtimes:');
      for (var showtime in showtimes.take(3)) {
        print(
          '  - movieId: ${showtime.movieId}, hora: ${DateFormat('HH:mm').format(showtime.dateTime)}',
        );
      }
    }
    print('================================');

    if (showtimes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No hay funciones disponibles',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Intenta con otros filtros',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    // Agrupar por fecha
    final groupedShowtimes = controller.getGroupedByDate();
    final sortedDates = groupedShowtimes.keys.toList()..sort();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sortedDates.map((date) {
          final dateShowtimes = groupedShowtimes[date]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado de fecha
              Padding(
                padding: const EdgeInsets.only(bottom: 16, top: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F7DF3).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Color(0xFF4F7DF3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _formatDateHeader(date),
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E2A47),
                      ),
                    ),
                  ],
                ),
              ),
              // Grid de horarios
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.8,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: dateShowtimes.length,
                itemBuilder: (context, showtimeIndex) {
                  final showtime = dateShowtimes[showtimeIndex];
                  return ShowtimeCard(
                    showtime: showtime,
                    onTap: () => _onShowtimeSelected(showtime),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _onShowtimeSelected(Showtime showtime) {
    if (showtime.remainingSeats == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta función no tiene asientos disponibles'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Limpiar estado anterior de asientos
    context.read<SeatController>().clear();

    // Navegar a selección de asientos
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SeatSelectionPage(movie: widget.movie, showtime: showtime),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Cargando funciones...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(ShowtimeController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error al cargar funciones',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage ?? 'Error desconocido',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                controller.clearError();
                controller.refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay funciones disponibles',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text('Intenta más tarde', style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  String _getLanguageLabel(String language) {
    switch (language.toLowerCase()) {
      case 'ingles':
        return 'Inglés';
      case 'subtitulado':
        return 'Subtitulado';
      case 'español':
        return 'Español';
      default:
        return language;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Hoy';
    } else if (targetDate == tomorrow) {
      return 'Mañana';
    } else {
      return DateFormat('dd/MM').format(date);
    }
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Hoy - ${DateFormat('d MMM').format(date)}';
    } else if (targetDate == tomorrow) {
      return 'Mañana - ${DateFormat('d MMM').format(date)}';
    } else {
      return DateFormat('EEEE, d MMMM').format(date);
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

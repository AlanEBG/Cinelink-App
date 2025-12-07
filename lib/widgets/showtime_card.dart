import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/showtime.dart';

class ShowtimeCard extends StatelessWidget {
  final Showtime showtime;
  final VoidCallback? onTap;
  final bool isSelected;

  const ShowtimeCard({
    super.key,
    required this.showtime,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final time = timeFormat.format(showtime.dateTime);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF4F7DF3) : Colors.grey[200]!,
            width: isSelected ? 2.5 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF4F7DF3).withOpacity(0.25)
                  : Colors.black.withOpacity(0.06),
              blurRadius: isSelected ? 12 : 8,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hora
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4F7DF3).withOpacity(0.15)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.access_time,
                    size: 18,
                    color: isSelected
                        ? const Color(0xFF4F7DF3)
                        : const Color(0xFF1E2A47),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? const Color(0xFF4F7DF3)
                        : const Color(0xFF1E2A47),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Idioma y asientos en la misma línea
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Idioma
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getLanguageColor().withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getLanguageColor().withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    showtime.lenguage,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _getLanguageColor(),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                // Asientos disponibles
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getAvailabilityColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event_seat,
                        size: 14,
                        color: _getAvailabilityColor(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${showtime.remainingSeats}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _getAvailabilityColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getLanguageColor() {
    switch (showtime.lenguage.toLowerCase()) {
      case 'ingles':
        return const Color(0xFF4F7DF3);
      case 'subtitulado':
        return const Color(0xFF9B59B6);
      case 'español':
        return const Color(0xFFFF8C42);
      default:
        return Colors.grey;
    }
  }

  Color _getAvailabilityColor() {
    if (showtime.remainingSeats == 0) {
      return Colors.red;
    } else if (showtime.remainingSeats <= 10) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}

// Widget para mostrar horarios agrupados por fecha
class ShowtimeListByDate extends StatelessWidget {
  final Map<DateTime, List<Showtime>> groupedShowtimes;
  final Function(Showtime) onShowtimeSelected;
  final Showtime? selectedShowtime;

  const ShowtimeListByDate({
    super.key,
    required this.groupedShowtimes,
    required this.onShowtimeSelected,
    this.selectedShowtime,
  });

  @override
  Widget build(BuildContext context) {
    final sortedDates = groupedShowtimes.keys.toList()..sort();

    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final showtimes = groupedShowtimes[date]!;
        final dateFormat = DateFormat('EEEE, d MMMM');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado de fecha
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                dateFormat.format(date),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Lista de horarios
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: showtimes.length,
              itemBuilder: (context, showtimeIndex) {
                final showtime = showtimes[showtimeIndex];
                return ShowtimeCard(
                  showtime: showtime,
                  onTap: () => onShowtimeSelected(showtime),
                  isSelected: selectedShowtime?.id == showtime.id,
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

// Widget compacto para horarios en línea
class ShowtimeChip extends StatelessWidget {
  final Showtime showtime;
  final VoidCallback? onTap;
  final bool isSelected;

  const ShowtimeChip({
    super.key,
    required this.showtime,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final time = timeFormat.format(showtime.dateTime);

    return GestureDetector(
      onTap: showtime.remainingSeats > 0 ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: showtime.remainingSeats == 0
              ? Colors.grey[300]
              : isSelected
              ? Theme.of(context).primaryColor
              : Colors.white,
          border: Border.all(
            color: showtime.remainingSeats == 0
                ? Colors.grey[400]!
                : isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          time,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: showtime.remainingSeats == 0
                ? Colors.grey[600]
                : isSelected
                ? Colors.white
                : Colors.black87,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/seat.dart';

/// Widget para un asiento individual con diseño minimalista
class SeatWidget extends StatelessWidget {
  final Seat seat;
  final bool isSelected;
  final VoidCallback? onTap;
  final double size;

  const SeatWidget({
    super.key,
    required this.seat,
    this.isSelected = false,
    this.onTap,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    Color seatColor;
    Color borderColor;

    if (seat.isReserved) {
      seatColor = const Color(0xFF424242);
      borderColor = const Color(0xFF424242);
    } else if (isSelected) {
      seatColor = const Color(0xFF1a237e);
      borderColor = const Color(0xFF1a237e);
    } else {
      seatColor = Colors.white;
      borderColor = Colors.grey[300]!;
    }

    return GestureDetector(
      onTap: seat.isReserved ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: seatColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}

/// Leyenda de estados de asientos con diseño minimalista
class SeatLegend extends StatelessWidget {
  const SeatLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(
            color: const Color(0xFF1a237e),
            label: 'Seleccionado',
          ),
          _buildLegendItem(
            color: Colors.white,
            label: 'Disponible',
            hasBorder: true,
          ),
          _buildLegendItem(color: const Color(0xFF424242), label: 'Reservado'),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    bool hasBorder = false,
  }) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            border: hasBorder
                ? Border.all(color: Colors.grey[300]!, width: 1.5)
                : null,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

/// Widget para la pantalla del cine con diseño moderno
class CinemaScreen extends StatelessWidget {
  const CinemaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 60),
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.grey[200]!, Colors.white],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.elliptical(200, 50),
              bottomRight: Radius.elliptical(200, 50),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[300]!,
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: -5,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Widget para mostrar una fila de asientos
class SeatRow extends StatelessWidget {
  final String rowLabel;
  final List<Seat> seats;
  final List<Seat> selectedSeats;
  final Function(Seat) onSeatTap;
  final double seatSize;

  const SeatRow({
    super.key,
    required this.rowLabel,
    required this.seats,
    required this.selectedSeats,
    required this.onSeatTap,
    this.seatSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Label izquierdo
          SizedBox(
            width: 20,
            child: Text(
              rowLabel,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Asientos
          Expanded(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: seats.map((seat) {
                final isSelected = selectedSeats.any(
                  (s) => s.seatNumber == seat.seatNumber,
                );
                return SeatWidget(
                  seat: seat,
                  size: seatSize,
                  isSelected: isSelected,
                  onTap: () => onSeatTap(seat),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 10),
          // Label derecho
          SizedBox(
            width: 20,
            child: Text(
              rowLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

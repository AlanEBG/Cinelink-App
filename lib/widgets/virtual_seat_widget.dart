import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/virtual_seat.dart';

/// Widget para un asiento virtual individual con diseño minimalista
class VirtualSeatWidget extends StatelessWidget {
  final VirtualSeat seat;
  final VoidCallback? onTap;
  final double size;

  const VirtualSeatWidget({
    super.key,
    required this.seat,
    this.onTap,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    Color seatColor;
    Color borderColor;

    if (seat.isOccupied) {
      seatColor = const Color(0xFF424242);
      borderColor = const Color(0xFF424242);
    } else if (seat.isSelected) {
      seatColor = const Color(0xFF1a237e);
      borderColor = const Color(0xFF1a237e);
    } else {
      seatColor = Colors.white;
      borderColor = Colors.grey[300]!;
    }

    return GestureDetector(
      onTap: seat.isOccupied ? null : onTap,
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

/// Widget para mostrar una fila de asientos virtuales
class VirtualSeatRow extends StatelessWidget {
  final String rowLabel;
  final List<VirtualSeat> seats;
  final Function(VirtualSeat) onSeatTap;
  final double seatSize;

  const VirtualSeatRow({
    super.key,
    required this.rowLabel,
    required this.seats,
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
                return VirtualSeatWidget(
                  seat: seat,
                  size: seatSize,
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
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para la pantalla del cine con diseño moderno
class ModernCinemaScreen extends StatelessWidget {
  const ModernCinemaScreen({super.key});

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

/// Leyenda de estados de asientos con diseño minimalista
class ModernSeatLegend extends StatelessWidget {
  const ModernSeatLegend({super.key});

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
          _buildLegendItem(color: const Color(0xFF424242), label: 'Ocupado'),
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

/// Widget para mostrar el contador de selección
class SeatSelectionCounter extends StatelessWidget {
  final int selectedCount;
  final int maxSeats;

  const SeatSelectionCounter({
    super.key,
    required this.selectedCount,
    this.maxSeats = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: GoogleFonts.poppins(fontSize: 24, color: Colors.black),
          children: [
            TextSpan(
              text: selectedCount.toString(),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 36),
            ),
            TextSpan(
              text: ' de ',
              style: TextStyle(color: Colors.grey[600]),
            ),
            TextSpan(
              text: maxSeats.toString(),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 36),
            ),
            TextSpan(
              text: ' asientos seleccionados.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para la instrucción de clic
class TapInstruction extends StatelessWidget {
  const TapInstruction({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.touch_app, size: 28, color: const Color(0xFF424242)),
        const SizedBox(width: 12),
        Text(
          'Por favor selecciona tus asientos dando clic.',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
        ),
      ],
    );
  }
}

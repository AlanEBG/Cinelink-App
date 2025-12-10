import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/virtual_seat_controller.dart';
import '../../models/movie.dart';
import '../../models/showtime.dart';
import '../../models/booking_data.dart';
import '../payments/payment_booking_page.dart';

class SeatSelectionPage extends StatefulWidget {
  final Movie movie;
  final Showtime showtime;

  const SeatSelectionPage({
    super.key,
    required this.movie,
    required this.showtime,
  });

  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  Timer? _timer;
  int _remainingSeconds = 300; // 5 minutos = 300 segundos

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VirtualSeatController>().generateSeatsForShowtime(
        widget.showtime,
        seatsPerRow: 10,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        _showTimeoutDialog();
      }
    });
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Tiempo agotado'),
        content: const Text(
          'El tiempo para seleccionar asientos ha expirado. Por favor, intenta nuevamente.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background con imagen borrosa
          Positioned.fill(child: _buildBlurredBackground()),
          // Contenido
          SafeArea(
            child: Consumer<VirtualSeatController>(
              builder: (context, controller, child) {
                if (controller.isLoading && !controller.hasSeats) {
                  return _buildLoadingState();
                }

                if (controller.hasError) {
                  return _buildErrorState(controller);
                }

                if (!controller.hasSeats) {
                  return _buildEmptyState();
                }

                return Column(
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 20),
                    _buildTitle(),
                    const SizedBox(height: 16),
                    _buildMovieInfo(controller),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 40),
                            _buildCinemaScreen(),
                            const SizedBox(height: 0),
                            _buildSeatMap(controller),
                            const SizedBox(height: 40),
                            _buildLegend(),
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomSheet: Consumer<VirtualSeatController>(
        builder: (context, controller, child) {
          if (!controller.hasSeats) return const SizedBox.shrink();
          return _buildBottomBar(controller);
        },
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

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón de atrás
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          // Timer y página
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, size: 18, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    _formatTime(_remainingSeconds),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SELECCIONA',
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                height: 1.0,
                letterSpacing: -1,
                color: Colors.white,
              ),
            ),
            Text(
              'TUS ASIENTOS',
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                height: 1.0,
                letterSpacing: -1,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieInfo(VirtualSeatController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información de la película
          Text(
            widget.movie.movieTitle,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.white.withOpacity(0.9),
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.movie.movieDurationMinutes} min',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.category,
                size: 16,
                color: Colors.white.withOpacity(0.9),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  widget.movie.movieGenre,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          // Asientos seleccionados
          if (controller.hasSelectedSeats) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.event_seat,
                  size: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    controller.getSelectedSeatNumbers().join(', '),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCinemaScreen() {
    return Column(
      children: [
        // Texto "PANTALLA"
        Text(
          'P A N T A L L A',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFFFFFFF),
            letterSpacing: 6,
          ),
        ),
        const SizedBox(height: 40),
        // Pantalla curva minimalista
        CustomPaint(
          size: const Size(double.infinity, 50),
          painter: CinemaScreenPainter(),
        ),
      ],
    );
  }

  Widget _buildSeatMap(VirtualSeatController controller) {
    final seatsByRow = controller.getSeatsByRow();
    final rows = controller.getRows();

    if (rows.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No hay asientos disponibles'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: rows.map((row) {
          final rowSeats = seatsByRow[row] ?? [];
          return _buildSeatRow(row, rowSeats, controller);
        }).toList(),
      ),
    );
  }

  Widget _buildSeatRow(
    String rowLabel,
    List<dynamic> seats,
    VirtualSeatController controller,
  ) {
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
                return _buildSeat(seat, controller);
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

  Widget _buildSeat(dynamic seat, VirtualSeatController controller) {
    final isOccupied = seat.isOccupied;
    final isSelected = seat.isSelected;

    Color seatColor;
    Color borderColor;

    if (isOccupied) {
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
      onTap: isOccupied
          ? null
          : () {
              controller.toggleSeatSelection(seat);
            },
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: seatColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 12,
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            border: hasBorder
                ? Border.all(color: Colors.grey[300]!, width: 1.5)
                : null,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(VirtualSeatController controller) {
    final hasSelection = controller.hasSelectedSeats;
    final totalPrice = controller.totalPrice;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Precio
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                '\$${totalPrice.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Botón continuar
            Expanded(
              child: ElevatedButton(
                onPressed: hasSelection ? () => _onContinue(controller) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[500],
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continuar',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onContinue(VirtualSeatController controller) async {
    // Calcular precio por asiento
    final pricePerSeat = controller.selectedSeatsCount > 0
        ? controller.totalPrice / controller.selectedSeatsCount
        : 0.0;

    // Debug: Verificar showtime ID antes de crear BookingData
    print('[SeatSelection] ===== DEBUG SHOWTIME =====');
    print('[SeatSelection] Showtime ID: ${widget.showtime.id}');
    print('[SeatSelection] Showtime dateTime: ${widget.showtime.dateTime}');
    print('[SeatSelection] Showtime price: ${widget.showtime.price}');
    print('[SeatSelection] Movie title: ${widget.movie.movieTitle}');
    print(
      '[SeatSelection] Selected seats: ${controller.getSelectedSeatNumbers()}',
    );
    print('[SeatSelection] Total price: ${controller.totalPrice}');
    print('[SeatSelection] =============================');

    // Validar que el showtime tenga ID antes de continuar
    if (widget.showtime.id == null || widget.showtime.id!.isEmpty) {
      print('[SeatSelection] ERROR: Showtime ID es null o vacío!');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: La función no tiene un ID válido. Por favor selecciona otra función.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    // Crear datos de reserva
    final bookingData = BookingData(
      movie: widget.movie,
      showtime: widget.showtime,
      selectedSeats: controller.getSelectedSeatNumbers(),
      roomName: controller.currentRoom?.roomName ?? "N/A",
      totalPrice: controller.totalPrice,
      pricePerSeat: pricePerSeat,
    );

    print('[SeatSelection] BookingData creado exitosamente');
    print(
      '[SeatSelection] BookingData showtime ID: ${bookingData.showtime.id}',
    );

    // Navegar directamente a la página de pagos
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentBookingPage(bookingData: bookingData),
        ),
      );
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.black),
          const SizedBox(height: 20),
          Text(
            'Generando sala...',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(VirtualSeatController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 20),
            Text(
              'Error al generar asientos',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              controller.errorMessage ?? 'Error desconocido',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                controller.clearError();
                controller.refresh();
              },
              icon: const Icon(Icons.refresh),
              label: Text(
                'Reintentar',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
          Icon(Icons.event_seat, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            'No hay asientos disponibles',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

// CustomPainter para dibujar la pantalla curva del cine
class CinemaScreenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Crear un gradiente lineal para el color de la línea
    // Este gradiente permite que la línea tenga diferentes intensidades de color
    final gradient = LinearGradient(
      // Define los colores del gradiente en orden
      colors: [
        // Color blanco con 30% de opacidad en el inicio (borde izquierdo)
        const Color(0xFFFFFFFF).withOpacity(0.3),
        // Color rosa con 100% de opacidad en el centro (más intenso)
        const Color(0xFFFFFFFF),
        // Color rosa con 30% de opacidad en el final (borde derecho)
        const Color(0xFFFFFFFF).withOpacity(0.3),
      ],
      // Define las posiciones donde cada color debe aplicarse (0.0 = inicio, 1.0 = final)
      // 0.0 = borde izquierdo, 0.5 = centro, 1.0 = borde derecho
      stops: const [0.0, 0.5, 1.0],
    );

    // Crear el objeto Paint que define cómo se dibujará la línea principal
    final paint = Paint()
      // Aplicar el gradiente como shader (relleno) para la línea
      // createShader convierte el gradiente en un shader utilizable
      // Rect.fromLTWH crea un rectángulo: Left=0, Top=0, Width=ancho total, Height=alto total
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      // Definir que solo se dibuje el contorno (línea), no el relleno
      ..style = PaintingStyle.stroke
      // Establecer el grosor de la línea en 3.0 píxeles
      ..strokeWidth = 5.0
      // Redondear los extremos de la línea para un acabado más suave
      ..strokeCap = StrokeCap.round;

    // Crear un objeto Path que define la forma/trayectoria que se dibujará
    final path = Path();

    // Definir las coordenadas para dibujar la curva
    // Punto de inicio en X: 20 píxeles desde el borde izquierdo
    final startX = 20.0;
    // Punto final en X: 20 píxeles antes del borde derecho
    final endX = size.width - 20;
    // Altura de la curvatura: 25 píxeles hacia arriba
    final curveHeight = 30.0;

    // Mover el "lápiz" al punto de inicio sin dibujar
    // Posición inicial: (startX, 0) = (20, 0)
    path.moveTo(startX, 0);

    // Dibujar una curva cuadrática de Bézier desde el punto actual hasta el punto final
    // Una curva de Bézier usa un "punto de control" para definir la curvatura
    path.quadraticBezierTo(
      // Punto de control X: centro horizontal del área disponible
      size.width / 2,
      // Punto de control Y: -25 (valor negativo = hacia arriba)
      // Este punto "jala" la línea hacia arriba, creando la curva
      -curveHeight,
      // Punto final X: cerca del borde derecho
      endX,
      // Punto final Y: volver a la línea horizontal base (Y=0)
      0,
    );
    // La curva resultante va de (20, 0) → (centro, -25) → (width-20, 0)
    // creando un arco suave hacia arriba

    // Primero dibujar la sombra gris debajo de la línea blanca
    final shadowPaint = Paint()
      // Color gris para la sombra (mismo color que los asientos ocupados)
      ..color = const Color(0xFF424242).withOpacity(0.6)
      // Solo dibujar el contorno
      ..style = PaintingStyle.stroke
      // Línea más gruesa para la sombra
      ..strokeWidth = 8.0
      // Extremos redondeados
      ..strokeCap = StrokeCap.round
      // Aplicar desenfoque para efecto de sombra suave
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Crear un path para la sombra (ligeramente desplazado hacia abajo)
    final shadowPath = Path();
    shadowPath.moveTo(startX, 3); // Desplazar 3px hacia abajo
    shadowPath.quadraticBezierTo(
      size.width / 2,
      -curveHeight + 3, // Desplazar 3px hacia abajo
      endX,
      3, // Desplazar 3px hacia abajo
    );

    // Dibujar la sombra primero (debe estar detrás)
    canvas.drawPath(shadowPath, shadowPaint);

    // Dibujar el path (la curva) en el canvas usando el paint configurado
    canvas.drawPath(path, paint);
  }

  @override
  // Indica si el painter necesita repintarse cuando cambia
  // false = nunca repintar (la pantalla es estática y no cambia)
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

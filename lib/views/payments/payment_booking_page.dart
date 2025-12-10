import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/booking_data.dart';
import '../../models/payment_card.dart';
import '../../models/payment_transaction.dart';
import '../../models/customer.dart';
import '../../services/payment_service.dart';
import '../../services/ticket_service.dart';
import '../../services/customer_service.dart';
import '../../services/auth_service.dart';
import '../../utils/card_validator.dart';
import '../../utils/card_formatters.dart';
import '../../app/theme.dart';
import '../tickets/tickets_page.dart';

class PaymentBookingPage extends StatefulWidget {
  final BookingData bookingData;

  const PaymentBookingPage({super.key, required this.bookingData});

  @override
  State<PaymentBookingPage> createState() => _PaymentBookingPageState();
}

class _PaymentBookingPageState extends State<PaymentBookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _paymentService = PaymentService();
  final _ticketService = TicketService();
  final _customerService = CustomerService();
  final _authService = AuthService();

  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();

  CardType _cardType = CardType.unknown;
  bool _isProcessing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _onCardNumberChanged(String value) {
    setState(() {
      _cardType = CardValidator.detectCardType(value);
    });
  }

  Future<void> _handlePayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final card = PaymentCard(
      cardNumber: _cardNumberController.text.replaceAll(' ', ''),
      cardHolderName: _cardHolderController.text.toUpperCase(),
      expiryDate: _expiryDateController.text,
      cvv: _cvvController.text,
      cardType: _cardType,
    );

    final isValid = await _paymentService.validateCard(card);

    if (!isValid) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tarjeta inválida o expirada',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      );
      return;
    }

    final transaction = await _paymentService.processPayment(
      card: card,
      amount: widget.bookingData.totalPrice,
    );

    if (!mounted) return;

    if (transaction.status == PaymentStatus.approved) {
      // Crear el ticket en el backend después del pago exitoso
      try {
        print('[PaymentBooking] Pago aprobado, creando ticket...');

        // Obtener el usuario actual
        final user = await _authService.getCurrentUser();
        print('[PaymentBooking] Usuario: ${user.userId}');

        // Obtener o crear el customer asociado
        final customers = await _customerService.getAllCustomers();
        Customer? customer;

        try {
          customer = customers.firstWhere((c) => c.user?.userId == user.userId);
          print('[PaymentBooking] Customer encontrado: ${customer.customerId}');
        } catch (e) {
          // No se encontró el customer, crear uno nuevo
          print('[PaymentBooking] Customer no encontrado, creando nuevo...');

          customer = await _customerService.createCustomerWithUserId(
            userId: user.userId,
            customerName: user.displayName,
            customerEmail: user.userEmail,
            customerLastName: '',
            customerPhoneNumber: '',
          );
          print('[PaymentBooking] Customer creado: ${customer.customerId}');
        }

        if (customer.customerId == null) {
          throw Exception('No se pudo obtener o crear el cliente');
        }

        print('[PaymentBooking] Customer ID: ${customer.customerId}');

        // Validar que el showtime tenga ID
        if (widget.bookingData.showtime.id == null) {
          throw Exception('El ID de la función (showtime) es nulo');
        }

        print(
          '[PaymentBooking] Showtime ID: ${widget.bookingData.showtime.id}',
        );
        print(
          '[PaymentBooking] Creando ticket con price: ${widget.bookingData.totalPrice}',
        );

        // Crear el ticket usando el método con IDs
        final createdTicket = await _ticketService.createTicketWithIds(
          price: widget.bookingData.totalPrice,
          customerId: customer.customerId!,
          showtimeId: widget.bookingData.showtime.id!,
        );

        print('[PaymentBooking] Ticket creado: ${createdTicket?.id}');

        // El backend devuelve el ticket con IDs (no objetos completos)
        // Hacer una segunda consulta para obtener el ticket con relaciones pobladas
        if (createdTicket?.id != null) {
          print(
            '[PaymentBooking] Obteniendo ticket con relaciones pobladas...',
          );
          final fullTicket = await _ticketService.getTicketById(
            createdTicket!.id!,
          );
          print(
            '[PaymentBooking] Ticket completo obtenido: ${fullTicket?.customer?.customerName}, ${fullTicket?.showtime?.movie?.movieTitle}',
          );
        }

        setState(() {
          _isProcessing = false;
        });

        _showSuccessDialog(transaction);
      } catch (e, stackTrace) {
        print('[PaymentBooking] Error al crear ticket: $e');
        print('[PaymentBooking] Stack trace: $stackTrace');
        setState(() {
          _isProcessing = false;
        });

        // Mostrar error detallado
        String errorMessage =
            'El pago fue exitoso pero hubo un error al generar el ticket.\n\n';

        if (e.toString().contains('No se pudo obtener o crear el cliente')) {
          errorMessage +=
              'Error: No se pudo crear tu perfil de cliente. Por favor contacta a soporte.';
        } else if (e.toString().contains('showtime') &&
            e.toString().contains('nulo')) {
          errorMessage +=
              'Error: La función seleccionada no tiene ID válido. Por favor selecciona otra función.';
        } else if (e.toString().contains('DioException')) {
          errorMessage +=
              'Error de conexión con el servidor. Verifica tu conexión a internet.';
        } else if (e.toString().contains('Null is not a subtype')) {
          errorMessage +=
              'Error: Datos incompletos. Algunos campos requeridos están vacíos.\nDetalles: ${e.toString()}';
        } else {
          errorMessage += 'Detalles: ${e.toString()}';
        }

        _showErrorDialog(errorMessage);
      }
    } else {
      setState(() {
        _isProcessing = false;
      });
      _showErrorDialog(transaction.errorMessage ?? 'El pago fue rechazado');
    }
  }

  void _showSuccessDialog(PaymentTransaction transaction) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '¡Pago Exitoso!',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tu reserva ha sido confirmada',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                children: [
                  _buildSuccessRow(
                    'Película',
                    widget.bookingData.movie.movieTitle,
                  ),
                  const SizedBox(height: 8),
                  _buildSuccessRow(
                    'Asientos',
                    widget.bookingData.seatsFormatted,
                  ),
                  const SizedBox(height: 8),
                  _buildSuccessRow(
                    'Total Pagado',
                    '\$${widget.bookingData.totalPrice.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Cerrar el diálogo
                Navigator.of(context).pop();

                // Navegar a la página de tickets
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const TicketsPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Ver mis boletos',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Pago Rechazado',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(message, style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Intentar de nuevo',
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCardIcon() {
    switch (_cardType) {
      case CardType.visa:
        return Icons.credit_card;
      case CardType.mastercard:
        return Icons.credit_card;
      case CardType.amex:
        return Icons.credit_card;
      case CardType.discover:
        return Icons.credit_card;
      default:
        return Icons.credit_card_outlined;
    }
  }

  Color _getCardColor() {
    switch (_cardType) {
      case CardType.visa:
        return const Color(0xFF1A1F71);
      case CardType.mastercard:
        return const Color(0xFFEB001B);
      case CardType.amex:
        return const Color(0xFF006FCF);
      case CardType.discover:
        return const Color(0xFFFF6000);
      default:
        return AppColors.grey700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background con imagen difuminada
          Positioned.fill(child: _buildBlurredBackground()),
          // Contenido
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildBookingSummary(),
                            const SizedBox(height: 32),
                            Text(
                              'Información de Pago',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildVirtualCard(),
                            const SizedBox(height: 24),
                            _buildCardForm(),
                            const SizedBox(height: 32),
                            _buildPaymentButton(),
                            const SizedBox(height: 16),
                            _buildSecurityBadge(),
                          ],
                        ),
                      ),
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
    return Stack(
      fit: StackFit.expand,
      children: [
        if (widget.bookingData.movie.movieImageUrl != null &&
            widget.bookingData.movie.movieImageUrl!.isNotEmpty)
          ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: 25,
              sigmaY: 25,
              tileMode: TileMode.decal,
            ),
            child: CachedNetworkImage(
              imageUrl: widget.bookingData.movie.movieImageUrl!,
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

  Widget _buildAppBar() {
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
          const SizedBox(width: 16),
          Text(
            'Pago',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.grey300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.confirmation_number_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Resumen de Reserva',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSummaryRow(
            Icons.movie_outlined,
            'Película',
            widget.bookingData.movie.movieTitle,
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            Icons.calendar_today,
            'Fecha',
            widget.bookingData.dateFormatted,
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            Icons.access_time,
            'Hora',
            widget.bookingData.timeFormatted,
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            Icons.language,
            'Idioma',
            widget.bookingData.language,
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            Icons.meeting_room_outlined,
            'Sala',
            widget.bookingData.roomName,
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            Icons.event_seat,
            'Asientos',
            widget.bookingData.seatsFormatted,
          ),
          const SizedBox(height: 20),
          Divider(color: AppColors.grey300, thickness: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total a Pagar',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '\$${widget.bookingData.totalPrice.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.grey600),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Flexible(
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVirtualCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_getCardColor(), _getCardColor().withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: _getCardColor().withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tarjeta de Crédito/Débito',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(_getCardIcon(), color: Colors.white, size: 32),
              ],
            ),
            Text(
              _cardNumberController.text.isEmpty
                  ? '**** **** **** ****'
                  : _cardNumberController.text,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w500,
                letterSpacing: 2,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TITULAR',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _cardHolderController.text.isEmpty
                          ? 'NOMBRE COMPLETO'
                          : _cardHolderController.text.toUpperCase(),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'VENCE',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _expiryDateController.text.isEmpty
                          ? 'MM/AA'
                          : _expiryDateController.text,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Column(
      children: [
        TextFormField(
          controller: _cardNumberController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          style: GoogleFonts.poppins(),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(19),
            CardNumberFormatter(),
          ],
          validator: CardValidator.validateCardNumber,
          onChanged: _onCardNumberChanged,
          decoration: InputDecoration(
            labelText: 'Número de Tarjeta',
            labelStyle: GoogleFonts.poppins(),
            hintText: '1234 5678 9012 3456',
            hintStyle: GoogleFonts.poppins(color: AppColors.textTertiary),
            prefixIcon: Icon(_getCardIcon(), color: AppColors.primary),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _cardHolderController,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.characters,
          style: GoogleFonts.poppins(),
          validator: CardValidator.validateCardHolderName,
          decoration: InputDecoration(
            labelText: 'Nombre del Titular',
            labelStyle: GoogleFonts.poppins(),
            hintText: 'NOMBRE COMPLETO',
            hintStyle: GoogleFonts.poppins(color: AppColors.textTertiary),
            prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _expiryDateController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                style: GoogleFonts.poppins(),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  ExpiryDateFormatter(),
                ],
                validator: CardValidator.validateExpiryDate,
                decoration: InputDecoration(
                  labelText: 'Vencimiento',
                  labelStyle: GoogleFonts.poppins(),
                  hintText: 'MM/AA',
                  hintStyle: GoogleFonts.poppins(color: AppColors.textTertiary),
                  prefixIcon: Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.primary,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: BorderSide(color: AppColors.grey300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: BorderSide(color: AppColors.grey300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                obscureText: true,
                style: GoogleFonts.poppins(),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (value) =>
                    CardValidator.validateCVV(value, _cardType),
                decoration: InputDecoration(
                  labelText: 'CVV',
                  labelStyle: GoogleFonts.poppins(),
                  hintText: '123',
                  hintStyle: GoogleFonts.poppins(color: AppColors.textTertiary),
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: AppColors.primary,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: BorderSide(color: AppColors.grey300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: BorderSide(color: AppColors.grey300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _handlePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.grey300,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
        child: _isProcessing
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Procesando pago...',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                'Pagar \$${widget.bookingData.totalPrice.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildSecurityBadge() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline, size: 16, color: AppColors.grey600),
        const SizedBox(width: 4),
        Text(
          'Pago seguro y encriptado',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/payment_card.dart';
import '../../models/payment_transaction.dart';
import '../../services/payment_service.dart';
import '../../utils/card_validator.dart';
import '../../utils/card_formatters.dart';

class PaymentPage extends StatefulWidget {
  final double amount;
  final String description;
  final Function(PaymentTransaction) onPaymentSuccess;

  const PaymentPage({
    super.key,
    required this.amount,
    required this.description,
    required this.onPaymentSuccess,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _paymentService = PaymentService();

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
        const SnackBar(
          content: Text('Tarjeta inválida o expirada'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final transaction = await _paymentService.processPayment(
      card: card,
      amount: widget.amount,
    );

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    if (transaction.status == PaymentStatus.approved) {
      widget.onPaymentSuccess(transaction);
      Navigator.of(context).pop(transaction);
    } else {
      _showErrorDialog(
        transaction.errorMessage ?? 'El pago fue rechazado',
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pago Rechazado'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Intentar de nuevo'),
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
        return Colors.blue;
      case CardType.mastercard:
        return Colors.orange;
      case CardType.amex:
        return Colors.green;
      case CardType.discover:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Método de Pago'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: _getCardColor(),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tarjeta de Crédito/Débito',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            _getCardIcon(),
                            color: Colors.white,
                            size: 32,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(
                        _cardNumberController.text.isEmpty
                            ? '**** **** **** ****'
                            : _cardNumberController.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TITULAR',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _cardHolderController.text.isEmpty
                                    ? 'NOMBRE COMPLETO'
                                    : _cardHolderController.text.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'VENCE',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _expiryDateController.text.isEmpty
                                    ? 'MM/AA'
                                    : _expiryDateController.text,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
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
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(19),
                  CardNumberFormatter(),
                ],
                validator: CardValidator.validateCardNumber,
                onChanged: _onCardNumberChanged,
                decoration: InputDecoration(
                  labelText: 'Número de Tarjeta',
                  hintText: '1234 5678 9012 3456',
                  prefixIcon: Icon(_getCardIcon()),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cardHolderController,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.characters,
                validator: CardValidator.validateCardHolderName,
                decoration: InputDecoration(
                  labelText: 'Nombre del Titular',
                  hintText: 'NOMBRE COMPLETO',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        ExpiryDateFormatter(),
                      ],
                      validator: CardValidator.validateExpiryDate,
                      decoration: InputDecoration(
                        labelText: 'Vencimiento',
                        hintText: 'MM/AA',
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
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
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: (value) => 
                          CardValidator.validateCVV(value, _cardType),
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.description,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '\$${widget.amount.toStringAsFixed(2)} MXN',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _handlePayment,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isProcessing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Procesando pago...',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        )
                      : const Text(
                          'Pagar Ahora',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Pago seguro y encriptado',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
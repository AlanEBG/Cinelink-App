import 'dart:math';
import '../models/payment_card.dart';
import '../models/payment_transaction.dart';

class PaymentService {
  Future<PaymentTransaction> processPayment({
    required PaymentCard card,
    required double amount,
    String currency = 'MXN',
  }) async {
    print('[PaymentService] Procesando pago...');
    print('[PaymentService] Monto: \$$amount $currency');
    print('[PaymentService] Tarjeta: ${card.maskedCardNumber}');

    await Future.delayed(const Duration(seconds: 2));

    final random = Random();
    final shouldApprove = random.nextInt(100) < 90;

    final transactionId = _generateTransactionId();
    final lastFour = card.cardNumber.substring(card.cardNumber.length - 4);

    if (shouldApprove) {
      print('[PaymentService] Pago aprobado');
      return PaymentTransaction(
        transactionId: transactionId,
        amount: amount,
        currency: currency,
        status: PaymentStatus.approved,
        timestamp: DateTime.now(),
        cardLastFour: lastFour,
        cardType: card.cardType.name,
      );
    } else {
      print('[PaymentService] Pago rechazado');
      return PaymentTransaction(
        transactionId: transactionId,
        amount: amount,
        currency: currency,
        status: PaymentStatus.declined,
        timestamp: DateTime.now(),
        errorMessage: 'Fondos insuficientes',
        cardLastFour: lastFour,
        cardType: card.cardType.name,
      );
    }
  }

  String _generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return 'TXN${timestamp}${random.toString().padLeft(4, '0')}';
  }

  Future<bool> validateCard(PaymentCard card) async {
    print('[PaymentService] Validando tarjeta...');
    
    await Future.delayed(const Duration(seconds: 1));

    if (card.isExpired) {
      print('[PaymentService] Tarjeta expirada');
      return false;
    }

    print('[PaymentService] Tarjeta válida');
    return true;
  }
}
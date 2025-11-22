import '../models/payment_card.dart';

class CardValidator {
  static String? validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'El número de tarjeta es requerido';
    }

    final cleaned = value.replaceAll(RegExp(r'\s+'), '');
    
    if (cleaned.length < 13 || cleaned.length > 19) {
      return 'Número de tarjeta inválido';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(cleaned)) {
      return 'Solo números son permitidos';
    }

    if (!_luhnCheck(cleaned)) {
      return 'Número de tarjeta inválido';
    }

    return null;
  }

  static String? validateCardHolderName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre del titular es requerido';
    }

    if (value.length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }

    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value)) {
      return 'Solo letras y espacios son permitidos';
    }

    return null;
  }

  static String? validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'La fecha de expiración es requerida';
    }

    final parts = value.split('/');
    if (parts.length != 2) {
      return 'Formato inválido (MM/AA)';
    }

    try {
      final month = int.parse(parts[0]);
      final year = int.parse('20${parts[1]}');

      if (month < 1 || month > 12) {
        return 'Mes inválido';
      }

      final now = DateTime.now();
      final expiry = DateTime(year, month + 1, 0);

      if (now.isAfter(expiry)) {
        return 'Tarjeta expirada';
      }

      return null;
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  static String? validateCVV(String? value, CardType cardType) {
    if (value == null || value.isEmpty) {
      return 'El CVV es requerido';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Solo números son permitidos';
    }

    final expectedLength = cardType == CardType.amex ? 4 : 3;
    if (value.length != expectedLength) {
      return 'El CVV debe tener $expectedLength dígitos';
    }

    return null;
  }

  static CardType detectCardType(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\s+'), '');

    if (RegExp(r'^4').hasMatch(cleaned)) {
      return CardType.visa;
    } else if (RegExp(r'^5[1-5]').hasMatch(cleaned)) {
      return CardType.mastercard;
    } else if (RegExp(r'^3[47]').hasMatch(cleaned)) {
      return CardType.amex;
    } else if (RegExp(r'^6(?:011|5)').hasMatch(cleaned)) {
      return CardType.discover;
    }

    return CardType.unknown;
  }

  static bool _luhnCheck(String cardNumber) {
    int sum = 0;
    bool alternate = false;

    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }
}
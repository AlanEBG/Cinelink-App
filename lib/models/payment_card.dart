import 'package:json_annotation/json_annotation.dart';

part 'payment_card.g.dart';

enum CardType {
  visa,
  mastercard,
  amex,
  discover,
  unknown,
}

@JsonSerializable()
class PaymentCard {
  final String cardNumber;
  final String cardHolderName;
  final String expiryDate;
  final String cvv;
  final CardType cardType;

  PaymentCard({
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryDate,
    required this.cvv,
    required this.cardType,
  });

  String get maskedCardNumber {
    if (cardNumber.length < 4) return cardNumber;
    final lastFour = cardNumber.substring(cardNumber.length - 4);
    return '**** **** **** $lastFour';
  }

  String get formattedCardNumber {
    final cleaned = cardNumber.replaceAll(RegExp(r'\s+'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleaned[i]);
    }
    return buffer.toString();
  }

  bool get isExpired {
    try {
      final parts = expiryDate.split('/');
      if (parts.length != 2) return true;
      
      final month = int.parse(parts[0]);
      final year = int.parse('20${parts[1]}');
      
      final now = DateTime.now();
      final expiry = DateTime(year, month + 1, 0);
      
      return now.isAfter(expiry);
    } catch (e) {
      return true;
    }
  }

  factory PaymentCard.fromJson(Map<String, dynamic> json) => _$PaymentCardFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentCardToJson(this);
}
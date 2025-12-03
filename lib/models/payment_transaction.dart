import 'package:json_annotation/json_annotation.dart';

part 'payment_transaction.g.dart';

enum PaymentStatus {
  pending,
  processing,
  approved,
  declined,
  error,
}

@JsonSerializable()
class PaymentTransaction {
  final String transactionId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final DateTime timestamp;
  final String? errorMessage;
  final String? cardLastFour;
  final String? cardType;

  PaymentTransaction({
    required this.transactionId,
    required this.amount,
    this.currency = 'MXN',
    required this.status,
    required this.timestamp,
    this.errorMessage,
    this.cardLastFour,
    this.cardType,
  });

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) => 
      _$PaymentTransactionFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentTransactionToJson(this);
}
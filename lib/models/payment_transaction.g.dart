// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentTransaction _$PaymentTransactionFromJson(Map<String, dynamic> json) =>
    PaymentTransaction(
      transactionId: json['transactionId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'MXN',
      status: $enumDecode(_$PaymentStatusEnumMap, json['status']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      errorMessage: json['errorMessage'] as String?,
      cardLastFour: json['cardLastFour'] as String?,
      cardType: json['cardType'] as String?,
    );

Map<String, dynamic> _$PaymentTransactionToJson(PaymentTransaction instance) =>
    <String, dynamic>{
      'transactionId': instance.transactionId,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': _$PaymentStatusEnumMap[instance.status]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'errorMessage': instance.errorMessage,
      'cardLastFour': instance.cardLastFour,
      'cardType': instance.cardType,
    };

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.processing: 'processing',
  PaymentStatus.approved: 'approved',
  PaymentStatus.declined: 'declined',
  PaymentStatus.error: 'error',
};

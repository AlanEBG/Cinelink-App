// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentCard _$PaymentCardFromJson(Map<String, dynamic> json) => PaymentCard(
  cardNumber: json['cardNumber'] as String,
  cardHolderName: json['cardHolderName'] as String,
  expiryDate: json['expiryDate'] as String,
  cvv: json['cvv'] as String,
  cardType: $enumDecode(_$CardTypeEnumMap, json['cardType']),
);

Map<String, dynamic> _$PaymentCardToJson(PaymentCard instance) =>
    <String, dynamic>{
      'cardNumber': instance.cardNumber,
      'cardHolderName': instance.cardHolderName,
      'expiryDate': instance.expiryDate,
      'cvv': instance.cvv,
      'cardType': _$CardTypeEnumMap[instance.cardType]!,
    };

const _$CardTypeEnumMap = {
  CardType.visa: 'visa',
  CardType.mastercard: 'mastercard',
  CardType.amex: 'amex',
  CardType.discover: 'discover',
  CardType.unknown: 'unknown',
};

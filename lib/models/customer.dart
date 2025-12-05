import 'user.dart';

class Customer {
  final String? customerId;
  final String? customerName;
  final String? customerLastName;
  final String? customerEmail;
  final String? customerPhoneNumber;
  final User? user;

  Customer({
    this.customerId,
    this.customerName,
    this.customerLastName,
    this.customerEmail,
    this.customerPhoneNumber,
    this.user,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customerId'],
      customerName: json['customerName'],
      customerLastName: json['customerLastName'],
      customerEmail: json['customerEmail'],
      customerPhoneNumber: json['customerPhoneNumber'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerLastName': customerLastName,
      'customerEmail': customerEmail,
      'customerPhoneNumber': customerPhoneNumber,
      'user': user?.toJson(),
    };
  }

  String get fullName => '${customerName ?? ''} ${customerLastName ?? ''}'.trim();
}
import 'package:cinelink_app/models/showtime.dart';
import 'package:cinelink_app/models/customer.dart';

class Ticket {
  final String? id;
  final double price;
  final DateTime purchaseDate;
  final Customer? customer;
  final Showtime? showtime;

  Ticket({
    this.id,
    required this.price,
    required this.purchaseDate,
    this.customer,
    this.showtime,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    // Parsear customer: puede ser un Map (objeto completo) o un String (solo ID)
    Customer? customerObj;
    if (json['customer'] != null) {
      if (json['customer'] is Map<String, dynamic>) {
        customerObj = Customer.fromJson(json['customer']);
      }
      // Si es String (solo ID), customer queda null - el ticket se creó pero necesita población
    }

    // Parsear showtime: puede ser un Map (objeto completo) o un String (solo ID)
    Showtime? showtimeObj;
    if (json['showtime'] != null) {
      if (json['showtime'] is Map<String, dynamic>) {
        showtimeObj = Showtime.fromJson(json['showtime']);
      }
      // Si es String (solo ID), showtime queda null - el ticket se creó pero necesita población
    }

    return Ticket(
      id: json['id'],
      price: _parseDouble(json['price']),
      purchaseDate: DateTime.parse(json['purchaseDate']),
      customer: customerObj,
      showtime: showtimeObj,
    );
  }

  // Helper para convertir a double de forma segura
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'price': price,
      'purchaseDate': purchaseDate.toIso8601String(),
      'customer': customer?.toJson(),
      'showtime': showtime?.toJson(),
    };
  }

  // Getters útiles
  String get formattedDate {
    return '${purchaseDate.day.toString().padLeft(2, '0')}/'
        '${purchaseDate.month.toString().padLeft(2, '0')}/'
        '${purchaseDate.year}';
  }

  String get formattedTime {
    return '${purchaseDate.hour.toString().padLeft(2, '0')}:'
        '${purchaseDate.minute.toString().padLeft(2, '0')}';
  }

  String get customerName => customer?.customerName ?? 'N/A';
  String get customerEmail => customer?.customerEmail ?? 'N/A';
  String get customerPhone => customer?.customerPhoneNumber ?? 'N/A';
  String get movieTitle => showtime?.movie?.movieTitle ?? 'N/A';

  // Copiar el ticket con nuevos valores
  Ticket copyWith({
    String? id,
    double? price,
    DateTime? purchaseDate,
    Customer? customer,
    Showtime? showtime,
  }) {
    return Ticket(
      id: id ?? this.id,
      price: price ?? this.price,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      customer: customer ?? this.customer,
      showtime: showtime ?? this.showtime,
    );
  }
}

class Ticket {
  final String? id;
  final double price;
  final DateTime purchaseDate;
  final String? customerId;
  final String? showtimeId;

  Ticket({
    this.id,
    required this.price,
    required this.purchaseDate,
    this.customerId,
    this.showtimeId,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id']?.toString(),
      price: _parseDouble(json['price']),
      purchaseDate: DateTime.parse(json['purchaseDate']),
      customerId: json['customer']?.toString(),
      showtimeId: json['showtime']?.toString(),
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
      'customer': customerId,
      'showtime': showtimeId,
    };
  }

  // Helper para obtener la fecha formateada
  String get formattedDate {
    return '${purchaseDate.day.toString().padLeft(2, '0')}/${purchaseDate.month.toString().padLeft(2, '0')}/${purchaseDate.year}';
  }

  // Helper para obtener la hora formateada
  String get formattedTime {
    return '${purchaseDate.hour.toString().padLeft(2, '0')}:${purchaseDate.minute.toString().padLeft(2, '0')}';
  }

  // Copiar el ticket con nuevos valores
  Ticket copyWith({
    String? id,
    double? price,
    DateTime? purchaseDate,
    String? customerId,
    String? showtimeId,
  }) {
    return Ticket(
      id: id ?? this.id,
      price: price ?? this.price,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      customerId: customerId ?? this.customerId,
      showtimeId: showtimeId ?? this.showtimeId,
    );
  }
}

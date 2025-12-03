class Seat {
  final String seatNumber;
  final int showtimeId;
  final bool isReserved;

  Seat({
    required this.seatNumber,
    required this.showtimeId,
    required this.isReserved,
  });

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      seatNumber: json['seatNumber'] ?? '',
      showtimeId: _parseInt(json['showtimeId']),
      isReserved: json['isReserved'] ?? false,
    );
  }

  // Helper para convertir a int de forma segura
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'seatNumber': seatNumber,
      'showtimeId': showtimeId,
      'isReserved': isReserved,
    };
  }

  // Helper para obtener la fila del asiento (ej: "A1" -> "A")
  String get row {
    return seatNumber.replaceAll(RegExp(r'[0-9]'), '');
  }

  // Helper para obtener el número del asiento (ej: "A1" -> 1)
  int get number {
    final numberStr = seatNumber.replaceAll(RegExp(r'[A-Za-z]'), '');
    return int.tryParse(numberStr) ?? 0;
  }

  // Helper para verificar si está disponible
  bool get isAvailable => !isReserved;

  // Copiar el asiento con nuevos valores
  Seat copyWith({String? seatNumber, int? showtimeId, bool? isReserved}) {
    return Seat(
      seatNumber: seatNumber ?? this.seatNumber,
      showtimeId: showtimeId ?? this.showtimeId,
      isReserved: isReserved ?? this.isReserved,
    );
  }
}

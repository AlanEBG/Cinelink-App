import 'package:intl/intl.dart';
import 'movie.dart';
import 'showtime.dart';

/// Modelo para almacenar los datos de la reserva que se pasan a la página de pagos
class BookingData {
  final Movie movie;
  final Showtime showtime;
  final List<String> selectedSeats;
  final String roomName;
  final double totalPrice;
  final double pricePerSeat;

  BookingData({
    required this.movie,
    required this.showtime,
    required this.selectedSeats,
    required this.roomName,
    required this.totalPrice,
    required this.pricePerSeat,
  });

  /// Número de asientos seleccionados
  int get seatsCount => selectedSeats.length;

  /// Asientos en formato string separados por coma
  String get seatsFormatted => selectedSeats.join(', ');

  /// Fecha y hora formateada
  String get dateTimeFormatted {
    return DateFormat('dd/MM/yyyy HH:mm').format(showtime.dateTime);
  }

  /// Fecha formateada (solo día)
  String get dateFormatted {
    return DateFormat('dd/MM/yyyy').format(showtime.dateTime);
  }

  /// Hora formateada
  String get timeFormatted {
    return DateFormat('HH:mm').format(showtime.dateTime);
  }

  /// Idioma de la función
  String get language => showtime.lenguage;

  /// ID de la función
  String get showtimeId {
    if (showtime.id == null) {
      throw Exception(
        'El ID de la función (showtime) es nulo. Showtime: ${showtime.toString()}',
      );
    }
    return showtime.id!;
  }

  /// Descripción para el pago
  String get paymentDescription {
    return '${movie.movieTitle} - ${selectedSeats.length} asiento(s)';
  }

  /// Convertir a JSON para persistencia
  Map<String, dynamic> toJson() {
    return {
      'movie': movie.toJson(),
      'showtime': showtime.toJson(),
      'selectedSeats': selectedSeats,
      'roomName': roomName,
      'totalPrice': totalPrice,
      'pricePerSeat': pricePerSeat,
    };
  }

  /// Crear desde JSON
  factory BookingData.fromJson(Map<String, dynamic> json) {
    return BookingData(
      movie: Movie.fromJson(json['movie']),
      showtime: Showtime.fromJson(json['showtime']),
      selectedSeats: List<String>.from(json['selectedSeats']),
      roomName: json['roomName'],
      totalPrice: json['totalPrice'].toDouble(),
      pricePerSeat: json['pricePerSeat'].toDouble(),
    );
  }

  /// Copiar con modificaciones
  BookingData copyWith({
    Movie? movie,
    Showtime? showtime,
    List<String>? selectedSeats,
    String? roomName,
    double? totalPrice,
    double? pricePerSeat,
  }) {
    return BookingData(
      movie: movie ?? this.movie,
      showtime: showtime ?? this.showtime,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      roomName: roomName ?? this.roomName,
      totalPrice: totalPrice ?? this.totalPrice,
      pricePerSeat: pricePerSeat ?? this.pricePerSeat,
    );
  }

  @override
  String toString() {
    return 'BookingData(movie: ${movie.movieTitle}, showtime: $dateTimeFormatted, seats: $seatsFormatted, total: \$$totalPrice)';
  }
}

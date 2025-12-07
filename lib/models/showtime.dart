import 'package:cinelink_app/models/movie.dart';

import 'room.dart';

class Showtime {
  final String? id;
  final DateTime dateTime;
  final double price;
  final int remainingSeats;
  final String lenguage; // 'ingles', 'subtitulado', 'español'
  final int? movieId;
  final int? roomId;
  final Movie? movie;
  final Room? room;

  Showtime({
    this.id,
    required this.dateTime,
    required this.price,
    required this.remainingSeats,
    required this.lenguage,
    this.movieId,
    this.roomId,
    this.movie,
    this.room,
  });

  factory Showtime.fromJson(Map<String, dynamic> json) {
    print('=== DEBUG SHOWTIME.fromJson ===');
    print('Raw JSON: $json');
    print('json[\'room\']: ${json['room']}');
    print('json[\'room\'] type: ${json['room']?.runtimeType}');
    print('json[\'roomId\']: ${json['roomId']}');
    print('================================');

    // Parsear movie
    Movie? movieObj;
    int? movieIdValue;
    
    if (json['movie'] != null) {
      if (json['movie'] is Map<String, dynamic>) {
        print('DEBUG: movie es un Map, parseando objeto Movie');
        movieObj = Movie.fromJson(json['movie']);
        movieIdValue = movieObj.movieId;
      } else if (json['movie'] is int) {
        print('DEBUG: movie NO es un Map, es: ${json['movie'].runtimeType}');
        movieIdValue = json['movie'];
        print('DEBUG: movieId parseado directamente: $movieIdValue');
      }
    } else if (json['movieId'] != null) {
      movieIdValue = json['movieId'];
    }

    // Parsear room
    Room? roomObj;
    int? roomIdValue;
    
    if (json['room'] != null) {
      if (json['room'] is Map<String, dynamic>) {
        print('DEBUG: room es un Map, parseando objeto Room');
        roomObj = Room.fromJson(json['room']);
        roomIdValue = roomObj.roomId;
      } else if (json['room'] is int) {
        print('DEBUG: room NO es un Map, es: ${json['room'].runtimeType}');
        roomIdValue = json['room'];
        print('DEBUG: roomId parseado directamente: $roomIdValue');
      }
    } else if (json['roomId'] != null) {
      roomIdValue = json['roomId'];
    }

    print('DEBUG: roomId final: $roomIdValue');
    print('DEBUG: room object final: $roomObj');
    print('================================');

    return Showtime(
      id: json['id'],
      dateTime: DateTime.parse(json['dateTime']),
      price: _parseDouble(json['price']),
      remainingSeats: json['remainingSeats'] ?? 0,
      lenguage: json['lenguage'] ?? '',
      movieId: movieIdValue,
      roomId: roomIdValue,
      movie: movieObj,
      room: roomObj,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    // Para crear/actualizar, solo enviamos los IDs
    final json = {
      'dateTime': dateTime.toUtc().toIso8601String(),
      'price': price,
      'remainingSeats': remainingSeats,
      'lenguage': lenguage,
      'movie': movieId,  // El backend espera 'movie' con el ID
      'room': roomId,    // El backend espera 'room' con el ID
    };

    // Solo incluir ID si existe (para actualización)
    if (id != null) {
      json['id'] = id;
    }

    print('=== DEBUG SHOWTIME.toJson ===');
    print('Generated JSON: $json');
    print('================================');

    return json;
  }

  // Getters útiles
  String get formattedDate {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year}';
  }

  String get formattedTime {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String get formattedDateTime {
    return '$formattedDate $formattedTime';
  }

  Showtime copyWith({
    String? id,
    DateTime? dateTime,
    double? price,
    int? remainingSeats,
    String? lenguage,
    int? movieId,
    int? roomId,
    Movie? movie,
    Room? room,
  }) {
    return Showtime(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      price: price ?? this.price,
      remainingSeats: remainingSeats ?? this.remainingSeats,
      lenguage: lenguage ?? this.lenguage,
      movieId: movieId ?? this.movieId,
      roomId: roomId ?? this.roomId,
      movie: movie ?? this.movie,
      room: room ?? this.room,
    );
  }
}

import 'package:cinelink_app/models/movie.dart';

import 'room.dart';

class Showtime {
  final String? id;
  final DateTime dateTime;
  final double price;
  final int remainingSeats;
  final String lenguage; // 'ingles', 'subtitulado', 'español'
  final int? movieId;
  final Movie? movie;
  final int? roomId;
  final Room? room; // Objeto room completo si viene del backend

  Showtime({
    this.id,
    required this.dateTime,
    required this.price,
    required this.remainingSeats,
    required this.lenguage,
    this.movieId,
    this.movie,
    this.roomId,
    this.room,
  });

  factory Showtime.fromJson(Map<String, dynamic> json) {
    // DEBUG: Imprimir JSON completo
    print('=== DEBUG SHOWTIME.fromJson ===');
    print('Raw JSON: $json');
    print('json[\'room\']: ${json['room']}');
    print('json[\'room\'] type: ${json['room']?.runtimeType}');
    print('json[\'roomId\']: ${json['roomId']}');
    print('================================');

    // Parsear movieId (puede venir como objeto o como ID)
    int? movieId;
    if (json['movie'] != null) {
      if (json['movie'] is Map) {
        print('DEBUG: movie es un Map, intentando extraer movieId...');
        print('DEBUG: json[\'movie\'] keys: ${(json['movie'] as Map).keys}');
        final movieMap = json['movie'] as Map;
        movieId =
            _parseInt(movieMap['movieId']) ??
            _parseInt(movieMap['id']) ??
            _parseInt(movieMap['movie_id']) ??
            _parseInt(movieMap['MovieId']);
        print('DEBUG: movieId extraído del Map: $movieId');
      } else {
        print('DEBUG: movie NO es un Map, es: ${json['movie'].runtimeType}');
        movieId = _parseInt(json['movie']);
        print('DEBUG: movieId parseado directamente: $movieId');
      }
    } else if (json['movieId'] != null) {
      print('DEBUG: usando json[\'movieId\'] directamente');
      movieId = _parseInt(json['movieId']);
      print('DEBUG: movieId: $movieId');
    } else if (json['movie_id'] != null) {
      print('DEBUG: usando json[\'movie_id\'] directamente');
      movieId = _parseInt(json['movie_id']);
      print('DEBUG: movieId: $movieId');
    }

    // Parsear roomId y room (puede venir como objeto o como ID)
    int? roomId;
    Room? room;

    if (json['room'] != null) {
      if (json['room'] is Map) {
        print(
          'DEBUG: room es un Map, intentando extraer roomId y crear Room...',
        );
        print('DEBUG: json[\'room\'] keys: ${(json['room'] as Map).keys}');

        final roomMap = json['room'] as Map<String, dynamic>;

        // Intentar múltiples nombres de campo para roomId
        roomId =
            _parseInt(roomMap['roomId']) ??
            _parseInt(roomMap['id']) ??
            _parseInt(roomMap['room_id']) ??
            _parseInt(roomMap['RoomId']);

        print('DEBUG: roomId extraído del Map: $roomId');

        // Crear objeto Room desde el JSON
        try {
          room = Room.fromJson(roomMap);
          print(
            'DEBUG: Room object creado exitosamente: ${room.roomName}, capacity: ${room.roomCapacity}',
          );
        } catch (e) {
          print('DEBUG: Error al crear Room object: $e');
        }
      } else {
        print('DEBUG: room NO es un Map, es: ${json['room'].runtimeType}');
        roomId = _parseInt(json['room']);
        print('DEBUG: roomId parseado directamente: $roomId');
      }
    } else if (json['roomId'] != null) {
      print('DEBUG: usando json[\'roomId\'] directamente');
      roomId = _parseInt(json['roomId']);
      print('DEBUG: roomId: $roomId');
    } else if (json['room_id'] != null) {
      print('DEBUG: usando json[\'room_id\'] directamente');
      roomId = _parseInt(json['room_id']);
      print('DEBUG: roomId: $roomId');
    } else {
      print('DEBUG: NO SE ENCONTRÓ roomId en ningún formato');
    }

    print('DEBUG: roomId final: $roomId');
    print('DEBUG: room object final: ${room != null ? "exists" : "null"}');
    print('================================');

    return Showtime(
      id: json['id']?.toString(),
      dateTime: DateTime.parse(json['dateTime']),
      price: _parseDouble(json['price']),
      remainingSeats: _parseInt(json['remainingSeats']) ?? 0,
      lenguage: json['lenguage'] ?? '',
      movieId: movieId,
      roomId: roomId,
      room: room,
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

  // Helper para convertir a int de forma segura
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'price': price,
      'remainingSeats': remainingSeats,
      'lenguage': lenguage,
      'movie': movieId,
      'room': room?.toJson() ?? roomId,
    };
  }

  // Helper para verificar si es subtitulado
  bool get isSubtitled => lenguage.toLowerCase() == 'subtitulado';

  // Helper para verificar si es en inglés
  bool get isEnglish => lenguage.toLowerCase() == 'ingles';

  // Helper para verificar si es en español
  bool get isSpanish => lenguage.toLowerCase() == 'español';

  // Helper para obtener el idioma formateado
  String get languageLabel {
    switch (lenguage.toLowerCase()) {
      case 'ingles':
        return 'Inglés';
      case 'subtitulado':
        return 'Subtitulado';
      case 'español':
        return 'Español';
      default:
        return lenguage;
    }
  }
}

class Room {
  final int? roomId;
  final String roomName;
  final int roomCapacity;

  Room({this.roomId, required this.roomName, required this.roomCapacity});

  factory Room.fromJson(Map<String, dynamic> json) {
    // DEBUG: Imprimir datos del JSON recibido
    print('=== DEBUG ROOM.fromJson ===');
    print('Raw JSON: $json');
    print('json[\'roomId\']: ${json['roomId']}');
    print('json[\'id\']: ${json['id']}');
    print('json[\'roomName\']: ${json['roomName']}');
    print('json[\'roomCapacity\']: ${json['roomCapacity']}');
    print('===========================');

    // Intentar múltiples nombres de campo para roomId
    final roomId =
        _parseInt(json['roomId']) ??
        _parseInt(json['id']) ??
        _parseInt(json['room_id']);

    print('DEBUG: roomId final parseado: $roomId');

    return Room(
      roomId: roomId,
      roomName: json['roomName'] ?? json['name'] ?? '',
      roomCapacity:
          _parseInt(json['roomCapacity']) ?? _parseInt(json['capacity']) ?? 0,
    );
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
      'roomId': roomId,
      'roomName': roomName,
      'roomCapacity': roomCapacity,
    };
  }

  // Helper para obtener el número de filas estimado (asumiendo ~10 asientos por fila)
  int get estimatedRows => (roomCapacity / 10).ceil();

  // Helper para obtener asientos por fila estimados
  int get estimatedSeatsPerRow => (roomCapacity / estimatedRows).ceil();
}

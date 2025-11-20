/// Modelo de asiento virtual generado en el frontend
/// No corresponde a una tabla en la base de datos
class VirtualSeat {
  final String seatNumber;
  final String row;
  final int number;
  final bool isOccupied;
  final bool isSelected;

  VirtualSeat({
    required this.seatNumber,
    required this.row,
    required this.number,
    this.isOccupied = false,
    this.isSelected = false,
  });

  /// Genera asientos para una sala de cine
  /// [capacity] - Capacidad total de la sala
  /// [occupiedCount] - Número de asientos ya ocupados
  /// [seatsPerRow] - Asientos por fila (por defecto 10)
  static List<VirtualSeat> generateSeats({
    required int capacity,
    required int occupiedCount,
    int seatsPerRow = 10,
  }) {
    final List<VirtualSeat> seats = [];
    final int totalRows = (capacity / seatsPerRow).ceil();
    const String rowLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    // Generar todos los asientos
    for (int rowIndex = 0; rowIndex < totalRows; rowIndex++) {
      final String rowLetter = rowLetters[rowIndex % rowLetters.length];
      final int seatsInThisRow = rowIndex == totalRows - 1
          ? capacity - (rowIndex * seatsPerRow)
          : seatsPerRow;

      for (int seatNum = 1; seatNum <= seatsInThisRow; seatNum++) {
        seats.add(
          VirtualSeat(
            seatNumber: '$rowLetter$seatNum',
            row: rowLetter,
            number: seatNum,
            isOccupied: false,
          ),
        );
      }
    }

    // Marcar asientos ocupados aleatoriamente
    if (occupiedCount > 0 && occupiedCount < seats.length) {
      final List<int> occupiedIndices = [];
      final random = DateTime.now().millisecondsSinceEpoch;

      // Generar índices aleatorios pero consistentes
      while (occupiedIndices.length < occupiedCount) {
        final index = (random + occupiedIndices.length * 17) % seats.length;
        if (!occupiedIndices.contains(index)) {
          occupiedIndices.add(index);
        }
      }

      // Crear nueva lista con asientos ocupados
      return seats.asMap().entries.map((entry) {
        final index = entry.key;
        final seat = entry.value;
        return occupiedIndices.contains(index)
            ? seat.copyWith(isOccupied: true)
            : seat;
      }).toList();
    }

    return seats;
  }

  /// Agrupar asientos por fila
  static Map<String, List<VirtualSeat>> groupByRow(List<VirtualSeat> seats) {
    final Map<String, List<VirtualSeat>> grouped = {};

    for (var seat in seats) {
      if (grouped[seat.row] == null) {
        grouped[seat.row] = [];
      }
      grouped[seat.row]!.add(seat);
    }

    // Ordenar asientos dentro de cada fila
    grouped.forEach((row, seatList) {
      seatList.sort((a, b) => a.number.compareTo(b.number));
    });

    return grouped;
  }

  /// Copiar con nuevos valores
  VirtualSeat copyWith({
    String? seatNumber,
    String? row,
    int? number,
    bool? isOccupied,
    bool? isSelected,
  }) {
    return VirtualSeat(
      seatNumber: seatNumber ?? this.seatNumber,
      row: row ?? this.row,
      number: number ?? this.number,
      isOccupied: isOccupied ?? this.isOccupied,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  /// Verificar si el asiento está disponible
  bool get isAvailable => !isOccupied && !isSelected;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VirtualSeat &&
          runtimeType == other.runtimeType &&
          seatNumber == other.seatNumber;

  @override
  int get hashCode => seatNumber.hashCode;

  @override
  String toString() =>
      'VirtualSeat($seatNumber, occupied: $isOccupied, selected: $isSelected)';
}

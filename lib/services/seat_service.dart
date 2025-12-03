import '../app/constants.dart';
import '../models/seat.dart';
import 'api_service.dart';

class SeatService {
  final ApiService _apiService = ApiService();

  // Obtener todos los asientos
  Future<List<Seat>> getAllSeats() async {
    try {
      final response = await _apiService.get(AppConstants.seatsEndpoint);

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Seat.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error al obtener asientos: $e');
      rethrow;
    }
  }

  // Obtener asientos por función (showtime)
  Future<List<Seat>> getSeatsByShowtime(int showtimeId) async {
    try {
      final response = await _apiService.get(
        AppConstants.seatsEndpoint,
        queryParameters: {'showtimeId': showtimeId},
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Seat.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error al obtener asientos por función: $e');
      rethrow;
    }
  }

  // Obtener asientos disponibles por función
  Future<List<Seat>> getAvailableSeatsByShowtime(int showtimeId) async {
    try {
      final seats = await getSeatsByShowtime(showtimeId);
      return seats.where((seat) => seat.isAvailable).toList();
    } catch (e) {
      print('Error al obtener asientos disponibles: $e');
      rethrow;
    }
  }

  // Obtener asientos reservados por función
  Future<List<Seat>> getReservedSeatsByShowtime(int showtimeId) async {
    try {
      final seats = await getSeatsByShowtime(showtimeId);
      return seats.where((seat) => seat.isReserved).toList();
    } catch (e) {
      print('Error al obtener asientos reservados: $e');
      rethrow;
    }
  }

  // Reservar asientos
  Future<bool> reserveSeats(int showtimeId, List<String> seatNumbers) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.seatsEndpoint}/reserve',
        data: {'showtimeId': showtimeId, 'seatNumbers': seatNumbers},
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error al reservar asientos: $e');
      return false;
    }
  }

  // Liberar asientos (cancelar reserva)
  Future<bool> releaseSeats(int showtimeId, List<String> seatNumbers) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.seatsEndpoint}/release',
        data: {'showtimeId': showtimeId, 'seatNumbers': seatNumbers},
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error al liberar asientos: $e');
      return false;
    }
  }

  // Crear un nuevo asiento (Admin)
  Future<Seat?> createSeat(Seat seat) async {
    try {
      final response = await _apiService.post(
        AppConstants.seatsEndpoint,
        data: seat.toJson(),
      );

      if (response.data != null) {
        return Seat.fromJson(response.data);
      }

      return null;
    } catch (e) {
      print('Error al crear asiento: $e');
      rethrow;
    }
  }

  // Actualizar estado de un asiento
  Future<Seat?> updateSeatStatus(
    String seatNumber,
    int showtimeId,
    bool isReserved,
  ) async {
    try {
      final response = await _apiService.patch(
        '${AppConstants.seatsEndpoint}/$seatNumber',
        data: {'showtimeId': showtimeId, 'isReserved': isReserved},
      );

      if (response.data != null) {
        return Seat.fromJson(response.data);
      }

      return null;
    } catch (e) {
      print('Error al actualizar estado del asiento: $e');
      rethrow;
    }
  }

  // Agrupar asientos por fila
  Map<String, List<Seat>> groupSeatsByRow(List<Seat> seats) {
    Map<String, List<Seat>> grouped = {};

    for (var seat in seats) {
      final row = seat.row;

      if (grouped[row] == null) {
        grouped[row] = [];
      }

      grouped[row]!.add(seat);
    }

    // Ordenar asientos dentro de cada fila por número
    grouped.forEach((row, seatList) {
      seatList.sort((a, b) => a.number.compareTo(b.number));
    });

    return grouped;
  }

  // Obtener matriz de asientos para visualización
  List<List<Seat?>> getSeatMatrix(List<Seat> seats) {
    if (seats.isEmpty) return [];

    final groupedByRow = groupSeatsByRow(seats);
    final rows = groupedByRow.keys.toList()..sort();

    // Encontrar el número máximo de asientos por fila
    int maxSeatsPerRow = 0;
    for (var seatList in groupedByRow.values) {
      if (seatList.length > maxSeatsPerRow) {
        maxSeatsPerRow = seatList.length;
      }
    }

    // Crear matriz
    List<List<Seat?>> matrix = [];

    for (var row in rows) {
      List<Seat?> rowSeats = List.filled(maxSeatsPerRow, null);
      final seatsInRow = groupedByRow[row] ?? [];

      for (var i = 0; i < seatsInRow.length; i++) {
        if (i < maxSeatsPerRow) {
          rowSeats[i] = seatsInRow[i];
        }
      }

      matrix.add(rowSeats);
    }

    return matrix;
  }

  // Generar asientos para una sala (Admin/Setup)
  Future<List<Seat>> generateSeatsForShowtime(
    int showtimeId,
    int rows,
    int seatsPerRow,
  ) async {
    try {
      final List<Seat> generatedSeats = [];
      const rowLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

      for (int i = 0; i < rows; i++) {
        for (int j = 1; j <= seatsPerRow; j++) {
          final seatNumber = '${rowLetters[i]}$j';
          final seat = Seat(
            seatNumber: seatNumber,
            showtimeId: showtimeId,
            isReserved: false,
          );

          final createdSeat = await createSeat(seat);
          if (createdSeat != null) {
            generatedSeats.add(createdSeat);
          }
        }
      }

      return generatedSeats;
    } catch (e) {
      print('Error al generar asientos: $e');
      rethrow;
    }
  }

  // Verificar disponibilidad de asientos específicos
  Future<bool> checkSeatsAvailability(
    int showtimeId,
    List<String> seatNumbers,
  ) async {
    try {
      final seats = await getSeatsByShowtime(showtimeId);

      for (var seatNumber in seatNumbers) {
        final seat = seats.firstWhere(
          (s) => s.seatNumber == seatNumber,
          orElse: () =>
              Seat(seatNumber: '', showtimeId: showtimeId, isReserved: true),
        );

        if (seat.isReserved || seat.seatNumber.isEmpty) {
          return false;
        }
      }

      return true;
    } catch (e) {
      print('Error al verificar disponibilidad: $e');
      return false;
    }
  }
}

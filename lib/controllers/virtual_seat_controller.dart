import 'package:flutter/material.dart';
import '../models/virtual_seat.dart';
import '../models/showtime.dart';
import '../models/room.dart';
import '../services/room_service.dart';

class VirtualSeatController extends ChangeNotifier {
  final RoomService _roomService = RoomService();

  List<VirtualSeat> _seats = [];
  List<VirtualSeat> _selectedSeats = [];
  Showtime? _currentShowtime;
  Room? _currentRoom;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<VirtualSeat> get seats => _seats;
  List<VirtualSeat> get selectedSeats => _selectedSeats;
  Showtime? get currentShowtime => _currentShowtime;
  Room? get currentRoom => _currentRoom;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get hasSeats => _seats.isNotEmpty;
  bool get hasSelectedSeats => _selectedSeats.isNotEmpty;

  // Obtener total de asientos seleccionados
  int get selectedSeatsCount => _selectedSeats.length;

  // Obtener precio total
  double get totalPrice {
    if (_currentShowtime == null) return 0.0;
    return _selectedSeats.length * _currentShowtime!.price;
  }

  // Obtener asientos disponibles
  List<VirtualSeat> get availableSeats =>
      _seats.where((seat) => !seat.isOccupied).toList();

  // Obtener asientos ocupados
  List<VirtualSeat> get occupiedSeats =>
      _seats.where((seat) => seat.isOccupied).toList();

  // Obtener conteo de asientos disponibles
  int get availableSeatsCount => availableSeats.length;

  // Obtener conteo de asientos ocupados
  int get occupiedSeatsCount => occupiedSeats.length;

  /// Generar asientos virtuales para una función
  Future<void> generateSeatsForShowtime(
    Showtime showtime, {
    int seatsPerRow = 10,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _currentShowtime = showtime;
    _selectedSeats = [];
    notifyListeners();

    try {
      // DEBUG: Imprimir información del showtime
      print('=== DEBUG VIRTUAL SEAT CONTROLLER ===');
      print('Showtime ID: ${showtime.id}');
      print('Showtime roomId: ${showtime.roomId}');
      print('Showtime movieId: ${showtime.movieId}');
      print('Showtime remainingSeats: ${showtime.remainingSeats}');
      print('Showtime has embedded room object: ${showtime.room != null}');
      if (showtime.room != null) {
        print('Embedded room ID: ${showtime.room!.roomId}');
        print('Embedded room name: ${showtime.room!.roomName}');
        print('Embedded room capacity: ${showtime.room!.roomCapacity}');
      }
      print('=====================================');

      // Obtener información de la sala
      // Primero intentar usar el objeto room embebido si existe
      if (showtime.room != null) {
        print('DEBUG: Usando room object embebido del showtime');
        _currentRoom = showtime.room;
      } else if (showtime.roomId != null) {
        // Si no hay room embebido, intentar obtener por ID
        print(
          'DEBUG: Obteniendo room desde el backend por ID: ${showtime.roomId}',
        );
        try {
          _currentRoom = await _roomService.getRoomById(showtime.roomId!);
        } catch (e) {
          print('Error al obtener sala: $e');
          _currentRoom = null;
        }
      } else {
        throw Exception(
          'La función no tiene sala asignada. Verifica que el showtime tenga un roomId válido o un objeto room embebido.',
        );
      }

      if (_currentRoom == null) {
        throw Exception(
          'No se pudo obtener información de la sala. '
          'RoomId: ${showtime.roomId}, Room embebido: ${showtime.room != null}',
        );
      }

      // Calcular asientos ocupados
      final int capacity = _currentRoom!.roomCapacity;
      final int remaining = showtime.remainingSeats;
      final int occupied = capacity - remaining;

      print(
        'DEBUG: Capacity: $capacity, Remaining: $remaining, Occupied: $occupied',
      );

      // Generar asientos virtuales
      _seats = VirtualSeat.generateSeats(
        capacity: capacity,
        occupiedCount: occupied,
        seatsPerRow: seatsPerRow,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      print('ERROR EN generateSeatsForShowtime: $_errorMessage');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Seleccionar o deseleccionar un asiento
  void toggleSeatSelection(VirtualSeat seat) {
    if (seat.isOccupied) {
      _errorMessage = 'Este asiento ya está ocupado';
      notifyListeners();
      return;
    }

    final index = _seats.indexWhere((s) => s.seatNumber == seat.seatNumber);
    if (index == -1) return;

    final isCurrentlySelected = _selectedSeats.any(
      (s) => s.seatNumber == seat.seatNumber,
    );

    if (isCurrentlySelected) {
      // Deseleccionar
      _selectedSeats.removeWhere((s) => s.seatNumber == seat.seatNumber);
      _seats[index] = _seats[index].copyWith(isSelected: false);
    } else {
      // Seleccionar
      final selectedSeat = _seats[index].copyWith(isSelected: true);
      _seats[index] = selectedSeat;
      _selectedSeats.add(selectedSeat);
    }

    _errorMessage = null;
    notifyListeners();
  }

  /// Verificar si un asiento está seleccionado
  bool isSeatSelected(VirtualSeat seat) {
    return _selectedSeats.any((s) => s.seatNumber == seat.seatNumber);
  }

  /// Limpiar selección
  void clearSelection() {
    // Desmarcar todos los asientos seleccionados
    for (var i = 0; i < _seats.length; i++) {
      if (_seats[i].isSelected) {
        _seats[i] = _seats[i].copyWith(isSelected: false);
      }
    }
    _selectedSeats = [];
    notifyListeners();
  }

  /// Confirmar reserva (esto actualizaría el backend)
  Future<bool> confirmReservation() async {
    if (_selectedSeats.isEmpty) {
      _errorMessage = 'No hay asientos seleccionados';
      notifyListeners();
      return false;
    }

    if (_currentShowtime == null) {
      _errorMessage = 'No hay función seleccionada';
      notifyListeners();
      return false;
    }

    try {
      // Aquí deberías llamar a tu backend para:
      // 1. Actualizar remainingSeats en showtime
      // 2. Posiblemente crear un ticket o reservación

      // Por ahora, solo simulamos el éxito
      // TODO: Implementar llamada al backend

      // Marcar asientos como ocupados localmente
      for (var selectedSeat in _selectedSeats) {
        final index = _seats.indexWhere(
          (s) => s.seatNumber == selectedSeat.seatNumber,
        );
        if (index != -1) {
          _seats[index] = _seats[index].copyWith(
            isOccupied: true,
            isSelected: false,
          );
        }
      }

      _selectedSeats = [];
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Agrupar asientos por fila
  Map<String, List<VirtualSeat>> getSeatsByRow() {
    return VirtualSeat.groupByRow(_seats);
  }

  /// Obtener filas únicas ordenadas
  List<String> getRows() {
    final rows = _seats.map((seat) => seat.row).toSet().toList();
    rows.sort();
    return rows;
  }

  /// Obtener asientos de una fila específica
  List<VirtualSeat> getSeatsByRowName(String row) {
    return _seats.where((seat) => seat.row == row).toList()
      ..sort((a, b) => a.number.compareTo(b.number));
  }

  /// Obtener números de asientos seleccionados
  List<String> getSelectedSeatNumbers() {
    return _selectedSeats.map((seat) => seat.seatNumber).toList()..sort();
  }

  /// Obtener resumen de selección
  String getSelectionSummary() {
    if (_selectedSeats.isEmpty) return 'No hay asientos seleccionados';

    final seatNumbers = getSelectedSeatNumbers();
    if (seatNumbers.length == 1) {
      return 'Asiento: ${seatNumbers.first}';
    } else if (seatNumbers.length <= 3) {
      return 'Asientos: ${seatNumbers.join(', ')}';
    } else {
      return '${seatNumbers.length} asientos seleccionados';
    }
  }

  /// Recargar asientos
  Future<void> refresh() async {
    if (_currentShowtime != null) {
      await generateSeatsForShowtime(_currentShowtime!);
    }
  }

  /// Limpiar errores
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpiar todo
  void clear() {
    _seats = [];
    _selectedSeats = [];
    _currentShowtime = null;
    _currentRoom = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Seleccionar múltiples asientos
  void selectMultipleSeats(List<VirtualSeat> seats) {
    for (var seat in seats) {
      if (!seat.isOccupied && !isSeatSelected(seat)) {
        final index = _seats.indexWhere((s) => s.seatNumber == seat.seatNumber);
        if (index != -1) {
          _seats[index] = _seats[index].copyWith(isSelected: true);
          _selectedSeats.add(_seats[index]);
        }
      }
    }
    notifyListeners();
  }

  /// Deseleccionar múltiples asientos
  void deselectMultipleSeats(List<VirtualSeat> seats) {
    for (var seat in seats) {
      final index = _seats.indexWhere((s) => s.seatNumber == seat.seatNumber);
      if (index != -1) {
        _seats[index] = _seats[index].copyWith(isSelected: false);
        _selectedSeats.removeWhere((s) => s.seatNumber == seat.seatNumber);
      }
    }
    notifyListeners();
  }

  /// Seleccionar asientos contiguos automáticamente
  void autoSelectSeats(int count) {
    clearSelection();

    final availableSeats = _seats.where((seat) => !seat.isOccupied).toList();
    final seatsByRow = VirtualSeat.groupByRow(availableSeats);

    // Buscar asientos contiguos en cada fila
    for (var row in seatsByRow.keys) {
      final rowSeats = seatsByRow[row]!;
      rowSeats.sort((a, b) => a.number.compareTo(b.number));

      for (int i = 0; i <= rowSeats.length - count; i++) {
        bool areContiguous = true;

        // Verificar si son contiguos
        for (int j = 0; j < count - 1; j++) {
          if (rowSeats[i + j].number + 1 != rowSeats[i + j + 1].number) {
            areContiguous = false;
            break;
          }
        }

        if (areContiguous) {
          // Seleccionar estos asientos
          final seatsToSelect = rowSeats.sublist(i, i + count);
          selectMultipleSeats(seatsToSelect);
          return;
        }
      }
    }

    // Si no se encontraron asientos contiguos, seleccionar los primeros disponibles
    final firstAvailable = availableSeats.take(count).toList();
    selectMultipleSeats(firstAvailable);
  }
}

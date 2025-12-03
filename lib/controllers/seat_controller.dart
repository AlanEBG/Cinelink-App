import 'package:flutter/material.dart';
import '../models/seat.dart';
import '../models/showtime.dart';
import '../services/seat_service.dart';

class SeatController extends ChangeNotifier {
  final SeatService _seatService = SeatService();

  List<Seat> _seats = [];
  List<Seat> _selectedSeats = [];
  Showtime? _currentShowtime;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isReserving = false;

  // Getters
  List<Seat> get seats => _seats;
  List<Seat> get selectedSeats => _selectedSeats;
  Showtime? get currentShowtime => _currentShowtime;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get hasSeats => _seats.isNotEmpty;
  bool get hasSelectedSeats => _selectedSeats.isNotEmpty;
  bool get isReserving => _isReserving;

  // Obtener total de asientos seleccionados
  int get selectedSeatsCount => _selectedSeats.length;

  // Obtener precio total
  double get totalPrice {
    if (_currentShowtime == null) return 0.0;
    return _selectedSeats.length * _currentShowtime!.price;
  }

  // Obtener asientos disponibles
  List<Seat> get availableSeats =>
      _seats.where((seat) => seat.isAvailable).toList();

  // Obtener asientos reservados
  List<Seat> get reservedSeats =>
      _seats.where((seat) => seat.isReserved).toList();

  // Obtener conteo de asientos disponibles
  int get availableSeatsCount => availableSeats.length;

  // Obtener conteo de asientos reservados
  int get reservedSeatsCount => reservedSeats.length;

  // Cargar asientos por función
  Future<void> loadSeatsByShowtime(int showtimeId, Showtime showtime) async {
    _isLoading = true;
    _errorMessage = null;
    _currentShowtime = showtime;
    _selectedSeats = []; // Limpiar selección al cargar nuevos asientos
    notifyListeners();

    try {
      _seats = await _seatService.getSeatsByShowtime(showtimeId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Seleccionar o deseleccionar un asiento
  void toggleSeatSelection(Seat seat) {
    if (seat.isReserved) {
      _errorMessage = 'Este asiento ya está reservado';
      notifyListeners();
      return;
    }

    final index = _selectedSeats.indexWhere(
      (s) => s.seatNumber == seat.seatNumber,
    );

    if (index != -1) {
      // Deseleccionar
      _selectedSeats.removeAt(index);
    } else {
      // Seleccionar
      _selectedSeats.add(seat);
    }

    _errorMessage = null;
    notifyListeners();
  }

  // Verificar si un asiento está seleccionado
  bool isSeatSelected(Seat seat) {
    return _selectedSeats.any((s) => s.seatNumber == seat.seatNumber);
  }

  // Limpiar selección
  void clearSelection() {
    _selectedSeats = [];
    notifyListeners();
  }

  // Reservar asientos seleccionados
  Future<bool> reserveSelectedSeats() async {
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

    _isReserving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final seatNumbers = _selectedSeats
          .map((seat) => seat.seatNumber)
          .toList();

      final success = await _seatService.reserveSeats(
        _currentShowtime!.id != null ? int.parse(_currentShowtime!.id!) : 0,
        seatNumbers,
      );

      if (success) {
        // Actualizar estado local de los asientos reservados
        for (var selectedSeat in _selectedSeats) {
          final index = _seats.indexWhere(
            (s) => s.seatNumber == selectedSeat.seatNumber,
          );
          if (index != -1) {
            _seats[index] = _seats[index].copyWith(isReserved: true);
          }
        }

        _selectedSeats = [];
        _isReserving = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Error al reservar los asientos';
        _isReserving = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isReserving = false;
      notifyListeners();
      return false;
    }
  }

  // Agrupar asientos por fila
  Map<String, List<Seat>> getSeatsByRow() {
    return _seatService.groupSeatsByRow(_seats);
  }

  // Obtener matriz de asientos
  List<List<Seat?>> getSeatMatrix() {
    return _seatService.getSeatMatrix(_seats);
  }

  // Obtener filas únicas ordenadas
  List<String> getRows() {
    final rows = _seats.map((seat) => seat.row).toSet().toList();
    rows.sort();
    return rows;
  }

  // Obtener asientos de una fila específica
  List<Seat> getSeatsByRowName(String row) {
    return _seats.where((seat) => seat.row == row).toList()
      ..sort((a, b) => a.number.compareTo(b.number));
  }

  // Verificar disponibilidad de asientos específicos
  Future<bool> checkAvailability(List<String> seatNumbers) async {
    if (_currentShowtime == null) return false;

    try {
      return await _seatService.checkSeatsAvailability(
        _currentShowtime!.id != null ? int.parse(_currentShowtime!.id!) : 0,
        seatNumbers,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Obtener números de asientos seleccionados
  List<String> getSelectedSeatNumbers() {
    return _selectedSeats.map((seat) => seat.seatNumber).toList()..sort();
  }

  // Obtener resumen de selección
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

  // Recargar asientos
  Future<void> refresh() async {
    if (_currentShowtime != null && _currentShowtime!.id != null) {
      await loadSeatsByShowtime(
        int.parse(_currentShowtime!.id!),
        _currentShowtime!,
      );
    }
  }

  // Limpiar errores
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Limpiar todo
  void clear() {
    _seats = [];
    _selectedSeats = [];
    _currentShowtime = null;
    _errorMessage = null;
    _isReserving = false;
    notifyListeners();
  }

  // Seleccionar múltiples asientos
  void selectMultipleSeats(List<Seat> seats) {
    for (var seat in seats) {
      if (!seat.isReserved && !isSeatSelected(seat)) {
        _selectedSeats.add(seat);
      }
    }
    notifyListeners();
  }

  // Deseleccionar múltiples asientos
  void deselectMultipleSeats(List<Seat> seats) {
    for (var seat in seats) {
      _selectedSeats.removeWhere((s) => s.seatNumber == seat.seatNumber);
    }
    notifyListeners();
  }

  // Seleccionar asientos contiguos automáticamente
  void autoSelectSeats(int count) {
    clearSelection();

    final availableSeats = _seats.where((seat) => seat.isAvailable).toList();
    final seatsByRow = _seatService.groupSeatsByRow(availableSeats);

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
          for (int j = 0; j < count; j++) {
            _selectedSeats.add(rowSeats[i + j]);
          }
          notifyListeners();
          return;
        }
      }
    }

    // Si no se encontraron asientos contiguos, seleccionar los primeros disponibles
    final firstAvailable = availableSeats.take(count).toList();
    _selectedSeats.addAll(firstAvailable);
    notifyListeners();
  }
}

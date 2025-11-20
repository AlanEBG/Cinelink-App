import 'package:flutter/material.dart';
import '../models/showtime.dart';
import '../services/showtime_service.dart';

class ShowtimeController extends ChangeNotifier {
  final ShowtimeService _showtimeService = ShowtimeService();

  List<Showtime> _showtimes = [];
  List<Showtime> _filteredShowtimes = [];
  Showtime? _selectedShowtime;
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedLanguage;
  DateTime? _selectedDate;
  int? _currentMovieId;

  // Getters
  List<Showtime> get showtimes =>
      _filteredShowtimes.isEmpty &&
          _selectedLanguage == null &&
          _selectedDate == null
      ? _showtimes
      : _filteredShowtimes;
  Showtime? get selectedShowtime => _selectedShowtime;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedLanguage => _selectedLanguage;
  DateTime? get selectedDate => _selectedDate;
  bool get hasError => _errorMessage != null;
  bool get hasShowtimes => _showtimes.isNotEmpty;

  // Obtener lista de idiomas disponibles
  List<String> get availableLanguages {
    final Set<String> languageSet = {};
    for (var showtime in _showtimes) {
      languageSet.add(showtime.lenguage);
    }
    return languageSet.toList()..sort();
  }

  // Obtener fechas disponibles
  List<DateTime> get availableDates {
    final Set<DateTime> dateSet = {};
    for (var showtime in _showtimes) {
      final date = DateTime(
        showtime.dateTime.year,
        showtime.dateTime.month,
        showtime.dateTime.day,
      );
      dateSet.add(date);
    }
    final dates = dateSet.toList()..sort();
    return dates;
  }

  // Cargar funciones por película
  Future<void> loadShowtimesByMovie(int movieId) async {
    print('=== DEBUG SHOWTIME_CONTROLLER ===');
    print('loadShowtimesByMovie llamado con movieId: $movieId');

    _isLoading = true;
    _errorMessage = null;
    _currentMovieId = movieId;
    notifyListeners();

    try {
      print('Llamando a showtimeService.getShowtimesByMovie($movieId)...');
      _showtimes = await _showtimeService.getShowtimesByMovie(movieId);
      _filteredShowtimes = _showtimes;

      print('=== RESULTADO EN CONTROLLER ===');
      print('Total showtimes cargados: ${_showtimes.length}');
      if (_showtimes.isNotEmpty) {
        print('Verificando movieId de los showtimes:');
        for (var showtime in _showtimes.take(3)) {
          print(
            '  - Showtime movieId: ${showtime.movieId}, esperado: $movieId',
          );
        }
      }
      print('================================');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('!!! ERROR en loadShowtimesByMovie: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar funciones filtradas
  Future<void> loadFilteredShowtimes({
    required int movieId,
    String? language,
    DateTime? date,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _currentMovieId = movieId;
    _selectedLanguage = language;
    _selectedDate = date;
    notifyListeners();

    try {
      _showtimes = await _showtimeService.getFilteredShowtimes(
        movieId: movieId,
        language: language,
        date: date,
      );
      _filteredShowtimes = _showtimes;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar función por ID
  Future<void> loadShowtimeById(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedShowtime = await _showtimeService.getShowtimeById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Seleccionar una función
  void selectShowtime(Showtime showtime) {
    _selectedShowtime = showtime;
    notifyListeners();
  }

  // Limpiar función seleccionada
  void clearSelectedShowtime() {
    _selectedShowtime = null;
    notifyListeners();
  }

  // Filtrar por idioma
  void filterByLanguage(String? language) {
    _selectedLanguage = language;
    _applyFilters();
  }

  // Filtrar por fecha
  void filterByDate(DateTime? date) {
    _selectedDate = date;
    _applyFilters();
  }

  // Aplicar filtros
  void _applyFilters() {
    _filteredShowtimes = _showtimes;

    if (_selectedLanguage != null) {
      _filteredShowtimes = _filteredShowtimes
          .where((showtime) => showtime.lenguage == _selectedLanguage)
          .toList();
    }

    if (_selectedDate != null) {
      _filteredShowtimes = _filteredShowtimes.where((showtime) {
        final showtimeDate = DateTime(
          showtime.dateTime.year,
          showtime.dateTime.month,
          showtime.dateTime.day,
        );
        final selectedDate = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
        );
        return showtimeDate.isAtSameMomentAs(selectedDate);
      }).toList();
    }

    notifyListeners();
  }

  // Limpiar filtros
  void clearFilters() {
    _selectedLanguage = null;
    _selectedDate = null;
    _filteredShowtimes = _showtimes;
    notifyListeners();
  }

  // Agrupar por fecha
  Map<DateTime, List<Showtime>> getGroupedByDate() {
    return _showtimeService.groupShowtimesByDate(_filteredShowtimes);
  }

  // Agrupar por idioma
  Map<String, List<Showtime>> getGroupedByLanguage() {
    return _showtimeService.groupShowtimesByLanguage(_filteredShowtimes);
  }

  // Ordenar por hora
  void sortByTime({bool ascending = true}) {
    _filteredShowtimes.sort((a, b) {
      return ascending
          ? a.dateTime.compareTo(b.dateTime)
          : b.dateTime.compareTo(a.dateTime);
    });
    notifyListeners();
  }

  // Ordenar por precio
  void sortByPrice({bool ascending = true}) {
    _filteredShowtimes.sort((a, b) {
      return ascending
          ? a.price.compareTo(b.price)
          : b.price.compareTo(a.price);
    });
    notifyListeners();
  }

  // Ordenar por asientos disponibles
  void sortByAvailableSeats({bool ascending = true}) {
    _filteredShowtimes.sort((a, b) {
      return ascending
          ? a.remainingSeats.compareTo(b.remainingSeats)
          : b.remainingSeats.compareTo(a.remainingSeats);
    });
    notifyListeners();
  }

  // Obtener solo funciones disponibles (con asientos)
  List<Showtime> getAvailableShowtimes() {
    return _filteredShowtimes
        .where((showtime) => showtime.remainingSeats > 0)
        .toList();
  }

  // Recargar funciones
  Future<void> refresh() async {
    if (_currentMovieId != null) {
      await loadShowtimesByMovie(_currentMovieId!);
    }
  }

  // Limpiar errores
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Limpiar todo
  void clear() {
    _showtimes = [];
    _filteredShowtimes = [];
    _selectedShowtime = null;
    _selectedLanguage = null;
    _selectedDate = null;
    _currentMovieId = null;
    _errorMessage = null;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';

class MovieController extends ChangeNotifier {
  final MovieService _movieService = MovieService();

  List<Movie> _movies = [];
  List<Movie> _filteredMovies = [];
  Movie? _selectedMovie;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedGenre;

  // Getters
  List<Movie> get movies =>
      _filteredMovies.isEmpty && _searchQuery.isEmpty && _selectedGenre == null
      ? _movies
      : _filteredMovies;
  Movie? get selectedMovie => _selectedMovie;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get selectedGenre => _selectedGenre;
  bool get hasError => _errorMessage != null;
  bool get hasMovies => _movies.isNotEmpty;

  // Obtener lista de géneros únicos
  List<String> get genres {
    final Set<String> genreSet = {};
    for (var movie in _movies) {
      genreSet.add(movie.movieGenre);
    }
    return genreSet.toList()..sort();
  }

  // Cargar todas las películas
  Future<void> loadMovies() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _movies = await _movieService.getAllMovies();
      _filteredMovies = _movies;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar película por ID
  Future<void> loadMovieById(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedMovie = await _movieService.getMovieById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Seleccionar una película
  void selectMovie(Movie movie) {
    _selectedMovie = movie;
    notifyListeners();
  }

  // Limpiar película seleccionada
  void clearSelectedMovie() {
    _selectedMovie = null;
    notifyListeners();
  }

  // Buscar películas por título
  void searchMovies(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredMovies = _movies;
      if (_selectedGenre != null) {
        _filteredMovies = _filteredMovies
            .where((movie) => movie.movieGenre == _selectedGenre)
            .toList();
      }
    } else {
      _filteredMovies = _movies
          .where(
            (movie) =>
                movie.movieTitle.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();

      if (_selectedGenre != null) {
        _filteredMovies = _filteredMovies
            .where((movie) => movie.movieGenre == _selectedGenre)
            .toList();
      }
    }

    notifyListeners();
  }

  // Filtrar por género
  void filterByGenre(String? genre) {
    _selectedGenre = genre;

    if (genre == null) {
      _filteredMovies = _movies;
      if (_searchQuery.isNotEmpty) {
        _filteredMovies = _filteredMovies
            .where(
              (movie) => movie.movieTitle.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
            )
            .toList();
      }
    } else {
      _filteredMovies = _movies
          .where((movie) => movie.movieGenre == genre)
          .toList();

      if (_searchQuery.isNotEmpty) {
        _filteredMovies = _filteredMovies
            .where(
              (movie) => movie.movieTitle.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
            )
            .toList();
      }
    }

    notifyListeners();
  }

  // Limpiar filtros
  void clearFilters() {
    _searchQuery = '';
    _selectedGenre = null;
    _filteredMovies = _movies;
    notifyListeners();
  }

  // Ordenar películas por título
  void sortByTitle({bool ascending = true}) {
    _filteredMovies.sort((a, b) {
      return ascending
          ? a.movieTitle.compareTo(b.movieTitle)
          : b.movieTitle.compareTo(a.movieTitle);
    });
    notifyListeners();
  }

  // Ordenar películas por duración
  void sortByDuration({bool ascending = true}) {
    _filteredMovies.sort((a, b) {
      return ascending
          ? a.movieDurationMinutes.compareTo(b.movieDurationMinutes)
          : b.movieDurationMinutes.compareTo(a.movieDurationMinutes);
    });
    notifyListeners();
  }

  // Recargar películas
  Future<void> refresh() async {
    await loadMovies();
  }

  // Limpiar errores
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

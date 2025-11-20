import '../app/constants.dart';
import '../models/movie.dart';
import 'api_service.dart';

class MovieService {
  final ApiService _apiService = ApiService();

  // Obtener todas las películas
  Future<List<Movie>> getAllMovies() async {
    try {
      final response = await _apiService.get(AppConstants.moviesEndpoint);

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Movie.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error al obtener películas: $e');
      rethrow;
    }
  }

  // Obtener una película por ID
  Future<Movie?> getMovieById(int id) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.moviesEndpoint}/$id',
      );

      if (response.data != null) {
        return Movie.fromJson(response.data);
      }

      return null;
    } catch (e) {
      print('Error al obtener película $id: $e');
      rethrow;
    }
  }

  // Buscar películas por género
  Future<List<Movie>> getMoviesByGenre(String genre) async {
    try {
      final response = await _apiService.get(
        AppConstants.moviesEndpoint,
        queryParameters: {'genre': genre},
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Movie.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error al buscar películas por género: $e');
      rethrow;
    }
  }

  // Buscar películas por título
  Future<List<Movie>> searchMovies(String query) async {
    try {
      final response = await _apiService.get(
        AppConstants.moviesEndpoint,
        queryParameters: {'search': query},
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Movie.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error al buscar películas: $e');
      rethrow;
    }
  }

  // Crear una nueva película (Admin)
  Future<Movie?> createMovie(Movie movie) async {
    try {
      final response = await _apiService.post(
        AppConstants.moviesEndpoint,
        data: movie.toJson(),
      );

      if (response.data != null) {
        return Movie.fromJson(response.data);
      }

      return null;
    } catch (e) {
      print('Error al crear película: $e');
      rethrow;
    }
  }

  // Actualizar una película (Admin)
  Future<Movie?> updateMovie(int id, Movie movie) async {
    try {
      final response = await _apiService.put(
        '${AppConstants.moviesEndpoint}/$id',
        data: movie.toJson(),
      );

      if (response.data != null) {
        return Movie.fromJson(response.data);
      }

      return null;
    } catch (e) {
      print('Error al actualizar película: $e');
      rethrow;
    }
  }

  // Eliminar una película (Admin)
  Future<bool> deleteMovie(int id) async {
    try {
      await _apiService.delete('${AppConstants.moviesEndpoint}/$id');
      return true;
    } catch (e) {
      print('Error al eliminar película: $e');
      return false;
    }
  }
}

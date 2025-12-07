import '../app/constant.dart';
import '../models/movie.dart';
import 'api_service.dart';

class MovieService {
  final ApiService _apiService = ApiService();

  // Obtener todas las películas
  Future<List<Movie>> getMovies() async {
    try {
      print('[MovieService] Obteniendo todas las películas...');
      
      final response = await _apiService.get(
        AppConstants.moviesEndpoint,
      );

      print('[MovieService] Response status: ${response.statusCode}');
      print('[MovieService] Response data type: ${response.data.runtimeType}');

      if (response.statusCode == 200 && response.data is List) {
        final movies = (response.data as List)
            .map((json) => Movie.fromJson(json as Map<String, dynamic>))
            .toList();
        
        print('[MovieService] ✅ ${movies.length} películas obtenidas');
        return movies;
      }

      print('[MovieService] ⚠️ No se encontraron películas');
      return [];
    } catch (e) {
      print('[MovieService] ❌ Error al obtener películas: $e');
      rethrow;
    }
  }

  // Alias para compatibilidad
  Future<List<Movie>> getAllMovies() => getMovies();

  // Obtener una película por ID
  Future<Movie?> getMovieById(int id) async {
    try {
      print('[MovieService] Obteniendo película con ID: $id');
      
      final response = await _apiService.get(
        '${AppConstants.moviesEndpoint}/$id',
      );

      if (response.statusCode == 200 && response.data != null) {
        final movie = Movie.fromJson(response.data as Map<String, dynamic>);
        print('[MovieService] ✅ Película obtenida: ${movie.movieTitle}');
        return movie;
      }

      print('[MovieService] ⚠️ Película no encontrada');
      return null;
    } catch (e) {
      print('[MovieService] ❌ Error al obtener película $id: $e');
      rethrow;
    }
  }

  // Buscar películas por género
  Future<List<Movie>> getMoviesByGenre(String genre) async {
    try {
      print('[MovieService] Buscando películas por género: $genre');
      
      final response = await _apiService.get(
        AppConstants.moviesEndpoint,
        queryParameters: {'genre': genre},
      );

      if (response.statusCode == 200 && response.data is List) {
        final movies = (response.data as List)
            .map((json) => Movie.fromJson(json as Map<String, dynamic>))
            .toList();
        
        print('[MovieService] ✅ ${movies.length} películas encontradas');
        return movies;
      }

      print('[MovieService] ⚠️ No se encontraron películas del género: $genre');
      return [];
    } catch (e) {
      print('[MovieService] ❌ Error al buscar películas por género: $e');
      rethrow;
    }
  }

  // Buscar películas por título
  Future<List<Movie>> searchMovies(String query) async {
    try {
      print('[MovieService] Buscando películas con query: $query');
      
      final response = await _apiService.get(
        AppConstants.moviesEndpoint,
        queryParameters: {'search': query},
      );

      if (response.statusCode == 200 && response.data is List) {
        final movies = (response.data as List)
            .map((json) => Movie.fromJson(json as Map<String, dynamic>))
            .toList();
        
        print('[MovieService] ✅ ${movies.length} películas encontradas');
        return movies;
      }

      print('[MovieService] ⚠️ No se encontraron películas con: $query');
      return [];
    } catch (e) {
      print('[MovieService] ❌ Error al buscar películas: $e');
      rethrow;
    }
  }

  // Filtrar películas (búsqueda más flexible)
  Future<List<Movie>> filterMovies({
    String? genre,
    String? search,
    int? year,
    double? minRating,
  }) async {
    try {
      print('[MovieService] Filtrando películas...');
      
      final queryParams = <String, dynamic>{};
      if (genre != null) queryParams['genre'] = genre;
      if (search != null) queryParams['search'] = search;
      if (year != null) queryParams['year'] = year;
      if (minRating != null) queryParams['minRating'] = minRating;

      final response = await _apiService.get(
        AppConstants.moviesEndpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data is List) {
        final movies = (response.data as List)
            .map((json) => Movie.fromJson(json as Map<String, dynamic>))
            .toList();
        
        print('[MovieService] ✅ ${movies.length} películas filtradas');
        return movies;
      }

      return [];
    } catch (e) {
      print('[MovieService] ❌ Error al filtrar películas: $e');
      rethrow;
    }
  }

  // Crear una nueva película (Admin)
  Future<Movie?> createMovie(Movie movie) async {
    try {
      print('[MovieService] Creando película: ${movie.movieTitle}');
      
      final response = await _apiService.post(
        AppConstants.moviesEndpoint,
        data: movie.toJson(),
      );

      if (response.statusCode == 201 && response.data != null) {
        final createdMovie = Movie.fromJson(response.data as Map<String, dynamic>);
        print('[MovieService] ✅ Película creada: ${createdMovie.movieTitle}');
        return createdMovie;
      }

      print('[MovieService] ⚠️ No se pudo crear la película');
      return null;
    } catch (e) {
      print('[MovieService] ❌ Error al crear película: $e');
      rethrow;
    }
  }

  // Actualizar una película (Admin)
  Future<Movie?> updateMovie(int id, Movie movie) async {
    try {
      print('[MovieService] Actualizando película ID: $id');
      
      final response = await _apiService.patch(
        '${AppConstants.moviesEndpoint}/$id',
        data: movie.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final updatedMovie = Movie.fromJson(response.data as Map<String, dynamic>);
        print('[MovieService] ✅ Película actualizada: ${updatedMovie.movieTitle}');
        return updatedMovie;
      }

      print('[MovieService] ⚠️ No se pudo actualizar la película');
      return null;
    } catch (e) {
      print('[MovieService] ❌ Error al actualizar película: $e');
      rethrow;
    }
  }

  // Actualización parcial de película (Admin)
  Future<Movie?> patchMovie(int id, Map<String, dynamic> updates) async {
    try {
      print('[MovieService] Actualizando parcialmente película ID: $id');
      
      final response = await _apiService.patch(
        '${AppConstants.moviesEndpoint}/$id',
        data: updates,
      );

      if (response.statusCode == 200 && response.data != null) {
        final updatedMovie = Movie.fromJson(response.data as Map<String, dynamic>);
        print('[MovieService] ✅ Película actualizada parcialmente');
        return updatedMovie;
      }

      return null;
    } catch (e) {
      print('[MovieService] ❌ Error al actualizar parcialmente película: $e');
      rethrow;
    }
  }

  // Eliminar una película (Admin)
  Future<bool> deleteMovie(int id) async {
    try {
      print('[MovieService] Eliminando película ID: $id');
      
      final response = await _apiService.delete(
        '${AppConstants.moviesEndpoint}/$id',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('[MovieService] ✅ Película eliminada exitosamente');
        return true;
      }

      print('[MovieService] ⚠️ No se pudo eliminar la película');
      return false;
    } catch (e) {
      print('[MovieService] ❌ Error al eliminar película: $e');
      return false;
    }
  }

  // Obtener películas populares/destacadas
  Future<List<Movie>> getFeaturedMovies() async {
    try {
      print('[MovieService] Obteniendo películas destacadas...');
      
      final response = await _apiService.get(
        '${AppConstants.moviesEndpoint}/featured',
      );

      if (response.statusCode == 200 && response.data is List) {
        final movies = (response.data as List)
            .map((json) => Movie.fromJson(json as Map<String, dynamic>))
            .toList();
        
        print('[MovieService] ✅ ${movies.length} películas destacadas obtenidas');
        return movies;
      }

      return [];
    } catch (e) {
      print('[MovieService] ❌ Error al obtener películas destacadas: $e');
      // Si falla, retornar todas las películas
      return getMovies();
    }
  }

  // Obtener próximos estrenos
  Future<List<Movie>> getUpcomingMovies() async {
    try {
      print('[MovieService] Obteniendo próximos estrenos...');
      
      final response = await _apiService.get(
        '${AppConstants.moviesEndpoint}/upcoming',
      );

      if (response.statusCode == 200 && response.data is List) {
        final movies = (response.data as List)
            .map((json) => Movie.fromJson(json as Map<String, dynamic>))
            .toList();
        
        print('[MovieService] ✅ ${movies.length} próximos estrenos obtenidos');
        return movies;
      }

      return [];
    } catch (e) {
      print('[MovieService] ❌ Error al obtener próximos estrenos: $e');
      return [];
    }
  }
}
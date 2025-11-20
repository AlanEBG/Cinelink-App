import '../app/constants.dart';
import '../models/showtime.dart';
import 'api_service.dart';

class ShowtimeService {
  final ApiService _apiService = ApiService();

  // Obtener todas las funciones
  Future<List<Showtime>> getAllShowtimes() async {
    try {
      final response = await _apiService.get(AppConstants.showtimesEndpoint);

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Showtime.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error al obtener funciones: $e');
      rethrow;
    }
  }

  // Obtener funciones por película
  Future<List<Showtime>> getShowtimesByMovie(int movieId) async {
    try {
      print('=== DEBUG SHOWTIME SERVICE - INICIO ===');
      print('Solicitando showtimes para movieId: $movieId');
      print('Endpoint: ${AppConstants.showtimesEndpoint}');
      print('Query Parameters: {"movieId": $movieId}');

      final response = await _apiService.get(
        AppConstants.showtimesEndpoint,
        queryParameters: {'movieId': movieId},
      );

      // DEBUG: Imprimir respuesta raw del backend
      print('=== DEBUG SHOWTIME SERVICE - RESPUESTA ===');
      print('Response data type: ${response.data.runtimeType}');
      print(
        'Total showtimes recibidos: ${response.data is List ? (response.data as List).length : 0}',
      );

      if (response.data is List && (response.data as List).isNotEmpty) {
        print('--- Primeros 3 showtimes raw data ---');
        final list = response.data as List;
        for (int i = 0; i < (list.length > 3 ? 3 : list.length); i++) {
          print('Showtime $i:');
          print(
            '  - movieId del showtime: ${list[i]['movie'] ?? list[i]['movieId']}',
          );
          print('  - dateTime: ${list[i]['dateTime']}');
          print('  - lenguage: ${list[i]['lenguage']}');
          print('  - remainingSeats: ${list[i]['remainingSeats']}');
        }
      }
      print('==============================');

      if (response.data is List) {
        final allShowtimes = (response.data as List)
            .map((json) => Showtime.fromJson(json))
            .toList();

        // FILTRAR POR MOVIEID EN EL FRONTEND (Temporal - el backend no está filtrando)
        final showtimes = allShowtimes
            .where((showtime) => showtime.movieId == movieId)
            .toList();

        // Verificar que los showtimes tengan el movieId correcto
        print('=== VERIFICACIÓN FINAL ===');
        print('Showtimes recibidos del backend: ${allShowtimes.length}');
        print('Showtimes filtrados por movieId=$movieId: ${showtimes.length}');
        if (showtimes.isNotEmpty) {
          print('Primeros 3 showtimes filtrados:');
          for (var showtime in showtimes.take(3)) {
            print(
              '  - Showtime movieId: ${showtime.movieId}, hora: ${showtime.dateTime}',
            );
          }
        } else {
          print(
            '⚠️ ADVERTENCIA: No se encontraron showtimes para movieId=$movieId',
          );
          print('El backend devolvió showtimes de otras películas.');
        }
        print('=========================');

        return showtimes;
      }

      return [];
    } catch (e) {
      print('!!! ERROR al obtener funciones por película: $e');
      rethrow;
    }
  }

  // Obtener funciones por sala
  Future<List<Showtime>> getShowtimesByRoom(int roomId) async {
    try {
      final response = await _apiService.get(
        AppConstants.showtimesEndpoint,
        queryParameters: {'roomId': roomId},
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Showtime.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error al obtener funciones por sala: $e');
      rethrow;
    }
  }

  // Obtener funciones filtradas por película, idioma y fecha
  Future<List<Showtime>> getFilteredShowtimes({
    required int movieId,
    String? language,
    DateTime? date,
  }) async {
    try {
      Map<String, dynamic> params = {'movieId': movieId};

      if (language != null && language.isNotEmpty) {
        params['language'] = language;
      }

      if (date != null) {
        params['date'] = date.toIso8601String().split('T')[0];
      }

      final response = await _apiService.get(
        AppConstants.showtimesEndpoint,
        queryParameters: params,
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Showtime.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error al obtener funciones filtradas: $e');
      rethrow;
    }
  }

  // Obtener función por ID
  Future<Showtime?> getShowtimeById(String id) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.showtimesEndpoint}/$id',
      );

      if (response.data != null) {
        return Showtime.fromJson(response.data);
      }

      return null;
    } catch (e) {
      print('Error al obtener función $id: $e');
      rethrow;
    }
  }

  // Obtener funciones disponibles (con asientos disponibles)
  Future<List<Showtime>> getAvailableShowtimes(int movieId) async {
    try {
      final showtimes = await getShowtimesByMovie(movieId);

      // Filtrar funciones con asientos disponibles
      return showtimes
          .where((showtime) => showtime.remainingSeats > 0)
          .toList();
    } catch (e) {
      print('Error al obtener funciones disponibles: $e');
      rethrow;
    }
  }

  // Agrupar funciones por fecha
  Map<DateTime, List<Showtime>> groupShowtimesByDate(List<Showtime> showtimes) {
    Map<DateTime, List<Showtime>> grouped = {};

    for (var showtime in showtimes) {
      final date = DateTime(
        showtime.dateTime.year,
        showtime.dateTime.month,
        showtime.dateTime.day,
      );

      if (grouped[date] == null) {
        grouped[date] = [];
      }

      grouped[date]!.add(showtime);
    }

    // Ordenar por hora dentro de cada día
    grouped.forEach((date, list) {
      list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    });

    return grouped;
  }

  // Agrupar funciones por idioma
  Map<String, List<Showtime>> groupShowtimesByLanguage(
    List<Showtime> showtimes,
  ) {
    Map<String, List<Showtime>> grouped = {};

    for (var showtime in showtimes) {
      if (grouped[showtime.lenguage] == null) {
        grouped[showtime.lenguage] = [];
      }

      grouped[showtime.lenguage]!.add(showtime);
    }

    return grouped;
  }

  // Crear una nueva función (Admin)
  Future<Showtime?> createShowtime(Showtime showtime) async {
    try {
      final response = await _apiService.post(
        AppConstants.showtimesEndpoint,
        data: showtime.toJson(),
      );

      if (response.data != null) {
        return Showtime.fromJson(response.data);
      }

      return null;
    } catch (e) {
      print('Error al crear función: $e');
      rethrow;
    }
  }

  // Actualizar una función (Admin)
  Future<Showtime?> updateShowtime(String id, Showtime showtime) async {
    try {
      final response = await _apiService.put(
        '${AppConstants.showtimesEndpoint}/$id',
        data: showtime.toJson(),
      );

      if (response.data != null) {
        return Showtime.fromJson(response.data);
      }

      return null;
    } catch (e) {
      print('Error al actualizar función: $e');
      rethrow;
    }
  }

  // Eliminar una función (Admin)
  Future<bool> deleteShowtime(String id) async {
    try {
      await _apiService.delete('${AppConstants.showtimesEndpoint}/$id');
      return true;
    } catch (e) {
      print('Error al eliminar función: $e');
      return false;
    }
  }

  // Actualizar asientos restantes
  Future<Showtime?> updateRemainingSeats(String id, int remainingSeats) async {
    try {
      final response = await _apiService.patch(
        '${AppConstants.showtimesEndpoint}/$id',
        data: {'remainingSeats': remainingSeats},
      );

      if (response.data != null) {
        return Showtime.fromJson(response.data);
      }

      return null;
    } catch (e) {
      print('Error al actualizar asientos restantes: $e');
      rethrow;
    }
  }
}

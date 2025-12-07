import '../app/constants.dart';
import '../models/room.dart';
import 'api_service.dart';

class RoomService {
  final ApiService _apiService = ApiService();

  // Obtener todas las salas
  Future<List<Room>> getAllRooms() async {
    try {
      final response = await _apiService.get(AppConstants.roomsEndpoint);

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Room.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error al obtener salas: $e');
      rethrow;
    }
  }

  // Obtener una sala por ID
  Future<Room?> getRoomById(int id) async {
    try {
      print('=== DEBUG ROOM SERVICE ===');
      print('Fetching room with ID: $id');
      print('URL: ${AppConstants.roomsEndpoint}/$id');

      final response = await _apiService.get(
        '${AppConstants.roomsEndpoint}/$id',
      );

      print('Response data: ${response.data}');
      print('Response data type: ${response.data?.runtimeType}');
      print('==========================');

      if (response.data != null) {
        return Room.fromJson(response.data);
      }

      return null;
    } catch (e) {
      print('Error al obtener sala $id: $e');
      rethrow;
    }
  }

  // Obtener salas por capacidad mínima
  Future<List<Room>> getRoomsByMinCapacity(int minCapacity) async {
    try {
      final rooms = await getAllRooms();
      return rooms.where((room) => room.roomCapacity >= minCapacity).toList();
    } catch (e) {
      print('Error al filtrar salas por capacidad: $e');
      rethrow;
    }
  }

  // Obtener salas disponibles (sin funciones activas en un horario específico)
  Future<List<Room>> getAvailableRooms(DateTime dateTime) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.roomsEndpoint}/available',
        queryParameters: {'dateTime': dateTime.toIso8601String()},
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Room.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error al obtener salas disponibles: $e');
      rethrow;
    }
  }

  // Crear una nueva sala (Admin)
  Future<Room?> createRoom(Room room) async {
    try {
      final response = await _apiService.post(
        AppConstants.roomsEndpoint,
        data: room.toJson(),
      );

      if (response.data != null) {
        return Room.fromJson(response.data);
      }

      return null;
    } catch (e) {
      print('Error al crear sala: $e');
      rethrow;
    }
  }

  // Actualizar una sala (Admin)
  Future<Room?> updateRoom(int id, Room room) async {
    try {
      final response = await _apiService.patch(
        '${AppConstants.roomsEndpoint}/$id',
        data: room.toJson(),
      );

      if (response.data != null) {
        return Room.fromJson(response.data);
      }

      return null;
    } catch (e) {
      print('Error al actualizar sala: $e');
      rethrow;
    }
  }

  // Eliminar una sala (Admin)
  Future<bool> deleteRoom(int id) async {
    try {
      await _apiService.delete('${AppConstants.roomsEndpoint}/$id');
      return true;
    } catch (e) {
      print('Error al eliminar sala: $e');
      return false;
    }
  }

  // Obtener capacidad total del cine
  Future<int> getTotalCapacity() async {
    try {
      final rooms = await getAllRooms();
      return rooms.fold<int>(0, (sum, room) => sum + room.roomCapacity);
    } catch (e) {
      print('Error al calcular capacidad total: $e');
      return 0;
    }
  }

  // Ordenar salas por capacidad
  List<Room> sortRoomsByCapacity(List<Room> rooms, {bool ascending = true}) {
    final sortedRooms = List<Room>.from(rooms);
    sortedRooms.sort((a, b) {
      return ascending
          ? a.roomCapacity.compareTo(b.roomCapacity)
          : b.roomCapacity.compareTo(a.roomCapacity);
    });
    return sortedRooms;
  }

  // Ordenar salas por nombre
  List<Room> sortRoomsByName(List<Room> rooms, {bool ascending = true}) {
    final sortedRooms = List<Room>.from(rooms);
    sortedRooms.sort((a, b) {
      return ascending
          ? a.roomName.compareTo(b.roomName)
          : b.roomName.compareTo(a.roomName);
    });
    return sortedRooms;
  }

  // Buscar salas por nombre
  Future<List<Room>> searchRoomsByName(String query) async {
    try {
      final rooms = await getAllRooms();
      return rooms
          .where(
            (room) => room.roomName.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } catch (e) {
      print('Error al buscar salas: $e');
      rethrow;
    }
  }
}

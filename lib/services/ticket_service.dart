import '../app/constants.dart';
import '../models/ticket.dart';
import 'api_service.dart';

class TicketService {
  final ApiService _apiService = ApiService();

  // Obtener todos los tickets
  Future<List<Ticket>> getAllTickets() async {
    try {
      final response = await _apiService.get(AppConstants.ticketsEndpoint);

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Ticket.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error al obtener tickets: $e');
      rethrow;
    }
  }

  // Obtener un ticket por ID
  Future<Ticket?> getTicketById(String id) async {
    try {
      print('=== DEBUG TICKET SERVICE ===');
      print('Fetching ticket with ID: $id');
      print('URL: ${AppConstants.ticketsEndpoint}/$id');

      final response = await _apiService.get(
        '${AppConstants.ticketsEndpoint}/$id',
      );

      print('Response data: ${response.data}');
      print('Response data type: ${response.data?.runtimeType}');
      print('============================');

      if (response.data != null) {
        return Ticket.fromJson(response.data);
      }

      return null;
    } catch (e) {
      print('Error al obtener ticket $id: $e');
      rethrow;
    }
  }

  // Crear un nuevo ticket
  Future<Ticket?> createTicket(Ticket ticket) async {
    try {
      final response = await _apiService.post(
        AppConstants.ticketsEndpoint,
        data: ticket.toJson(),
      );

      if (response.data != null) {
        return Ticket.fromJson(response.data);
      }

      return null;
    } catch (e) {
      print('Error al crear ticket: $e');
      rethrow;
    }
  }

  // Actualizar un ticket existente
  Future<Ticket?> updateTicket(String id, Ticket ticket) async {
    try {
      final response = await _apiService.put(
        '${AppConstants.ticketsEndpoint}/$id',
        data: ticket.toJson(),
      );

      if (response.data != null) {
        return Ticket.fromJson(response.data);
      }

      return null;
    } catch (e) {
      print('Error al actualizar ticket: $e');
      rethrow;
    }
  }

  // Eliminar un ticket
  Future<bool> deleteTicket(String id) async {
    try {
      await _apiService.delete('${AppConstants.ticketsEndpoint}/$id');
      return true;
    } catch (e) {
      print('Error al eliminar ticket: $e');
      return false;
    }
  }

  // Obtener tickets por cliente
  Future<List<Ticket>> getTicketsByCustomer(String customerId) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.ticketsEndpoint}/customer/$customerId',
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Ticket.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error al obtener tickets del cliente: $e');
      rethrow;
    }
  }

  // Obtener tickets por función
  Future<List<Ticket>> getTicketsByShowtime(String showtimeId) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.ticketsEndpoint}/showtime/$showtimeId',
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Ticket.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error al obtener tickets de la función: $e');
      rethrow;
    }
  }

  // Obtener tickets por fecha
  Future<List<Ticket>> getTicketsByDate(DateTime date) async {
    try {
      final formattedDate = date.toIso8601String().split('T')[0];
      final response = await _apiService.get(
        '${AppConstants.ticketsEndpoint}/date/$formattedDate',
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Ticket.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error al obtener tickets por fecha: $e');
      rethrow;
    }
  }

  // Obtener ingresos totales
  Future<double> getTotalRevenue() async {
    try {
      final tickets = await getAllTickets();
      return tickets.fold<double>(0.0, (sum, ticket) => sum + ticket.price);
    } catch (e) {
      print('Error al calcular ingresos totales: $e');
      return 0.0;
    }
  }

  // Obtener ingresos por fecha
  Future<double> getRevenueByDate(DateTime date) async {
    try {
      final tickets = await getTicketsByDate(date);
      return tickets.fold<double>(0.0, (sum, ticket) => sum + ticket.price);
    } catch (e) {
      print('Error al calcular ingresos por fecha: $e');
      return 0.0;
    }
  }

  // Obtener tickets de hoy
  Future<List<Ticket>> getTodayTickets() async {
    try {
      final now = DateTime.now();
      return await getTicketsByDate(now);
    } catch (e) {
      print('Error al obtener tickets de hoy: $e');
      return [];
    }
  }

  // Comprar múltiples tickets (compra en lote)
  Future<List<Ticket>> purchaseTickets(List<Ticket> tickets) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.ticketsEndpoint}/batch',
        data: tickets.map((t) => t.toJson()).toList(),
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Ticket.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error al comprar tickets: $e');
      rethrow;
    }
  }

  // Ordenar tickets por fecha
  List<Ticket> sortTicketsByDate(List<Ticket> tickets, {bool ascending = true}) {
    final sortedTickets = List<Ticket>.from(tickets);
    sortedTickets.sort((a, b) {
      return ascending
          ? a.purchaseDate.compareTo(b.purchaseDate)
          : b.purchaseDate.compareTo(a.purchaseDate);
    });
    return sortedTickets;
  }

  // Ordenar tickets por precio
  List<Ticket> sortTicketsByPrice(List<Ticket> tickets, {bool ascending = true}) {
    final sortedTickets = List<Ticket>.from(tickets);
    sortedTickets.sort((a, b) {
      return ascending
          ? a.price.compareTo(b.price)
          : b.price.compareTo(a.price);
    });
    return sortedTickets;
  }

  // Buscar tickets por cliente
  Future<List<Ticket>> searchTicketsByCustomer(String query) async {
    try {
      final tickets = await getAllTickets();
      return tickets
          .where(
            (ticket) => ticket.customerId?.toLowerCase().contains(query.toLowerCase()) ?? false,
          )
          .toList();
    } catch (e) {
      print('Error al buscar tickets: $e');
      rethrow;
    }
  }

  // Filtrar tickets por rango de precios
  List<Ticket> filterTicketsByPriceRange(
    List<Ticket> tickets,
    double minPrice,
    double maxPrice,
  ) {
    return tickets
        .where((ticket) => ticket.price >= minPrice && ticket.price <= maxPrice)
        .toList();
  }

  // Obtener estadísticas básicas
  Map<String, dynamic> getTicketStatistics(List<Ticket> tickets) {
    if (tickets.isEmpty) {
      return {
        'total': 0,
        'totalRevenue': 0.0,
        'averagePrice': 0.0,
        'maxPrice': 0.0,
        'minPrice': 0.0,
      };
    }

    final totalRevenue = tickets.fold<double>(0.0, (sum, ticket) => sum + ticket.price);
    final prices = tickets.map((t) => t.price).toList()..sort();

    return {
      'total': tickets.length,
      'totalRevenue': totalRevenue,
      'averagePrice': totalRevenue / tickets.length,
      'maxPrice': prices.last,
      'minPrice': prices.first,
    };
  }

  // Agrupar tickets por fecha
  Map<String, List<Ticket>> groupTicketsByDate(List<Ticket> tickets) {
    final Map<String, List<Ticket>> grouped = {};

    for (var ticket in tickets) {
      final dateKey = ticket.formattedDate;
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(ticket);
    }

    return grouped;
  }
}
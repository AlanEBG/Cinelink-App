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

  // Crear un ticket con solo IDs (para el flujo de pagos)
  Future<Ticket?> createTicketWithIds({
    required double price,
    required String customerId,
    required String showtimeId,
  }) async {
    try {
      // El backend espera: customer, showtime (no customerId/showtimeId)
      // y purchaseDate en formato ISO 8601
      final ticketData = {
        'price': price,
        'customer': customerId, // Sin "Id" al final
        'showtime': showtimeId, // Sin "Id" al final
        'purchaseDate': DateTime.now().toUtc().toIso8601String(),
      };

      print(
        '[TicketService] Creando ticket con estructura correcta: $ticketData',
      );

      final response = await _apiService.post(
        AppConstants.ticketsEndpoint,
        data: ticketData,
      );

      print('[TicketService] Respuesta del servidor: ${response.data}');

      if (response.data != null) {
        return Ticket.fromJson(response.data);
      }

      return null;
    } catch (e) {
      print('[TicketService] Error al crear ticket con IDs: $e');
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
      print('[TicketService] Consultando tickets para customer: $customerId');

      // Fallback: usar GET /ticket y filtrar por customerId en cliente
      // ya que el endpoint /ticket/customer/:id no está disponible en el backend
      print(
        '[TicketService] Usando fallback: obteniendo todos los tickets y filtrando',
      );

      final response = await _apiService.get(AppConstants.ticketsEndpoint);

      print('[TicketService] Response status: ${response.statusCode}');
      print(
        '[TicketService] Response data type: ${response.data?.runtimeType}',
      );

      if (response.data is List) {
        final allTickets = (response.data as List);
        print('[TicketService] Total tickets recibidos: ${allTickets.length}');

        // Filtrar tickets por customerId
        final customerTickets = allTickets.where((ticketJson) {
          // El customer puede venir como objeto o como string (ID)
          final customerData = ticketJson['customer'];

          if (customerData is String) {
            // Si customer es un string (ID), comparar directamente
            return customerData == customerId;
          } else if (customerData is Map) {
            // Si customer es un objeto, extraer el ID
            final customerIdFromObject =
                customerData['id'] ?? customerData['customerId'];
            return customerIdFromObject == customerId;
          }

          // Si no hay customer o formato no reconocido, verificar customerId directo
          return ticketJson['customerId'] == customerId;
        }).toList();

        print(
          '[TicketService] Tickets filtrados para customer $customerId: ${customerTickets.length}',
        );

        // Log detallado de cada ticket filtrado
        for (var i = 0; i < customerTickets.length; i++) {
          final ticketJson = customerTickets[i];
          print('[TicketService] Ticket filtrado $i: ID=${ticketJson['id']}');
        }

        return customerTickets.map((json) => Ticket.fromJson(json)).toList();
      }

      print('[TicketService] Response data no es una lista, retornando vacío');
      return [];
    } catch (e) {
      print('[TicketService] Error al obtener tickets del cliente: $e');
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
  List<Ticket> sortTicketsByDate(
    List<Ticket> tickets, {
    bool ascending = true,
  }) {
    final sortedTickets = List<Ticket>.from(tickets);
    sortedTickets.sort((a, b) {
      return ascending
          ? a.purchaseDate.compareTo(b.purchaseDate)
          : b.purchaseDate.compareTo(a.purchaseDate);
    });
    return sortedTickets;
  }

  // Ordenar tickets por precio
  List<Ticket> sortTicketsByPrice(
    List<Ticket> tickets, {
    bool ascending = true,
  }) {
    final sortedTickets = List<Ticket>.from(tickets);
    sortedTickets.sort((a, b) {
      return ascending
          ? a.price.compareTo(b.price)
          : b.price.compareTo(a.price);
    });
    return sortedTickets;
  }

  // Buscar tickets por cliente

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

    final totalRevenue = tickets.fold<double>(
      0.0,
      (sum, ticket) => sum + ticket.price,
    );
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

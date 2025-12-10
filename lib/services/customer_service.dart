import '../app/constants.dart';
import '../models/customer.dart';
import 'api_service.dart';

class CustomerService {
  final ApiService _apiService = ApiService();

  // GET - Obtener todos los clientes
  Future<List<Customer>> getAllCustomers() async {
    try {
      final response = await _apiService.get(AppConstants.customersEndpoint);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Customer.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener clientes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener clientes: $e');
      rethrow;
    }
  }

  // GET - Obtener un cliente por ID
  Future<Customer?> getCustomerById(String id) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.customersEndpoint}/$id',
      );

      if (response.statusCode == 200) {
        return Customer.fromJson(response.data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Error al obtener cliente: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener cliente: $e');
      rethrow;
    }
  }

  // POST - Crear un nuevo cliente
  Future<Customer> createCustomer(Customer customer) async {
    try {
      final response = await _apiService.post(
        AppConstants.customersEndpoint,
        data: customer.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Customer.fromJson(response.data);
      } else {
        throw Exception('Error al crear cliente: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al crear cliente: $e');
      rethrow;
    }
  }

  // POST - Crear un cliente con solo userId (para flujo de pagos)
  Future<Customer> createCustomerWithUserId({
    required String userId,
    required String customerName,
    required String customerEmail,
    String? customerLastName,
    String? customerPhoneNumber,
  }) async {
    try {
      final customerData = {
        'userId': userId,
        'customerName': customerName,
        'customerLastName': customerLastName ?? '',
        'customerEmail': customerEmail,
        'customerPhoneNumber': customerPhoneNumber ?? '',
      };

      print('[CustomerService] Creando customer con userId: $customerData');

      final response = await _apiService.post(
        AppConstants.customersEndpoint,
        data: customerData,
      );

      print('[CustomerService] Respuesta: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Customer.fromJson(response.data);
      } else {
        throw Exception('Error al crear cliente: ${response.statusCode}');
      }
    } catch (e) {
      print('[CustomerService] Error al crear cliente con userId: $e');
      rethrow;
    }
  }

  // PATCH - Actualizar un cliente existente
  Future<Customer> updateCustomer(String id, Customer customer) async {
    try {
      final response = await _apiService.patch(
        '${AppConstants.customersEndpoint}/$id',
        data: customer.toJson(),
      );

      if (response.statusCode == 200) {
        return Customer.fromJson(response.data);
      } else {
        throw Exception('Error al actualizar cliente: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al actualizar cliente: $e');
      rethrow;
    }
  }

  // DELETE - Eliminar un cliente
  Future<void> deleteCustomer(String id) async {
    try {
      final response = await _apiService.delete(
        '${AppConstants.customersEndpoint}/$id',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar cliente: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al eliminar cliente: $e');
      rethrow;
    }
  }
}

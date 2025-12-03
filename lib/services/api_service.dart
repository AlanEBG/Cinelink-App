import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import '../app/constant.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  late Dio _dio;
  late CookieJar _cookieJar;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  ApiService._internal() {
    _cookieJar = CookieJar();
    
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) {
        return status != null && status < 500;
      },
    ));
    
    // Agregar cookie manager
    _dio.interceptors.add(CookieManager(_cookieJar));
    
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Añadir Bearer token a cada request
          final token = await _storage.read(key: AppConstants.accessTokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          print('[REQUEST] ========== REQUEST ==========');
          print('[REQUEST] METHOD: ${options.method}');
          print('[REQUEST] URL: ${options.baseUrl}${options.path}');
          print('[REQUEST] HEADERS: ${options.headers}');
          print('[REQUEST] DATA TYPE: ${options.data?.runtimeType}');
          print('[REQUEST] DATA: ${options.data}');
          print('[REQUEST] ================================');
          
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          print('📥 DATA: ${response.data}');
          
          // Extraer y guardar el token de la respuesta si viene
          if (response.data is Map) {
            final data = response.data as Map<String, dynamic>;
            
            // Si la respuesta tiene un token directo (como en login)
            if (data.containsKey('token')) {
              final token = data['token'];
              if (token is String) {
                _storage.write(key: AppConstants.accessTokenKey, value: token);
                print('💾 Token guardado desde respuesta');
              }
            }
            
            // Si la respuesta tiene access_token
            if (data.containsKey('access_token')) {
              final token = data['access_token'];
              if (token is String) {
                _storage.write(key: AppConstants.accessTokenKey, value: token);
                print('💾 Access token guardado desde respuesta');
              }
            }
          }
          
          // Si la respuesta es directamente un string (token)
          if (response.data is String && 
              response.requestOptions.path.contains('login')) {
            _storage.write(key: AppConstants.accessTokenKey, value: response.data);
            print('💾 Token string guardado desde login');
          }
          
          return handler.next(response);
        },
        onError: (error, handler) async {
          print('❌ ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
          print('📛 MESSAGE: ${error.response?.data}');
          print('📛 ERROR TYPE: ${error.type}');
          
          // Si es 401, el token expiró
          if (error.response?.statusCode == 401) {
            print('🔄 Token expirado o inválido, limpiando storage');
            await _storage.delete(key: AppConstants.accessTokenKey);
            await _storage.delete(key: AppConstants.userDataKey);
          }
          
          return handler.next(error);
        },
      ),
    );
  }
  
  // Getter para acceder al Dio instance
  Dio get dio => _dio;
  
  // Limpiar cookies
  Future<void> clearCookies() async {
    await _cookieJar.deleteAll();
    print('🗑️ Cookies eliminadas');
  }
  
  // Set token de autenticación manualmente
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
  
  // Remove token de autenticación
  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
  
  // Métodos HTTP genéricos
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Exception _handleError(DioException error) {
    String message = 'Error desconocido';
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Tiempo de espera agotado. Verifica tu conexión.';
        return TimeoutException(message);
        
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        
        if (responseData is Map) {
          if (responseData.containsKey('message')) {
            message = responseData['message'].toString();
          } else if (responseData.containsKey('error')) {
            message = responseData['error'].toString();
          }
        } else if (responseData is String) {
          message = responseData;
        } else {
          switch (statusCode) {
            case 400:
              message = 'Solicitud inválida. Verifica los datos.';
              break;
            case 401:
              message = 'No autorizado. Credenciales incorrectas.';
              break;
            case 403:
              message = 'Acceso prohibido. No tienes permisos.';
              break;
            case 404:
              message = 'Recurso no encontrado.';
              break;
            case 409:
              message = 'El usuario ya existe.';
              break;
            case 500:
              message = 'Error del servidor. Intenta más tarde.';
              break;
            default:
              message = 'Error del servidor ($statusCode)';
          }
        }
        return ServerException(message, statusCode);
        
      case DioExceptionType.cancel:
        return CancelledException('Petición cancelada');
        
      case DioExceptionType.connectionError:
        message = 'Error de conexión. Verifica tu internet y que el servidor esté activo.';
        return NetworkException(message);
        
      default:
        return NetworkException('Error de red desconocido');
    }
  }
}

// Excepciones personalizadas
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  ServerException(this.message, this.statusCode);
  
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => message;
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => message;
}

class CancelledException implements Exception {
  final String message;
  CancelledException(this.message);
  
  @override
  String toString() => message;
}
class AppConstants {
  // Base URL de tu API de NestJS
  // Para emulador Android usa: 10.0.2.2
  // Para dispositivo físico usa tu IP local: 192.168.x.x
  static const String baseUrl = 'http://10.0.2.2:4000';

  // Endpoints
  static const String moviesEndpoint = '/movie';
  static const String showtimesEndpoint = '/showtime';
  static const String roomsEndpoint = '/room';
  static const String seatsEndpoint = '/seats';
  static const String ticketsEndpoint = '/ticket';
  static const String customersEndpoint = '/customers';
  static const String authEndpoint = '/auth';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Paginación
  static const int defaultPageSize = 20;

  // Idiomas disponibles
  static const List<String> availableLanguages = [
    'ingles',
    'subtitulado',
    'español',
  ];

  // Idiomas con etiquetas
  static const Map<String, String> languageLabels = {
    'ingles': 'Inglés',
    'subtitulado': 'Subtitulado',
    'español': 'Español',
  };

  // Estados de asientos
  static const String seatAvailable = 'available';
  static const String seatReserved = 'reserved';
  static const String seatOccupied = 'occupied';

  // Claves de almacenamiento local
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';

  // Mensajes
  static const String genericErrorMessage =
      'Ha ocurrido un error. Por favor, intenta de nuevo.';
  static const String noInternetMessage =
      'No hay conexión a internet. Verifica tu conexión.';
  static const String sessionExpiredMessage =
      'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.';

  // Validaciones
  static const int minPasswordLength = 8;
  static const int maxTitleLength = 50;

  // Formatos de fecha
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
}

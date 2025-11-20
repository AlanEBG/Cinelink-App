class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://192.168.100.64:4000';
  // static const String baseUrl = 'http://localhost:4000'; // iOS
  
  static const String apiPrefix = ''; 
  static const String apiBaseUrl = baseUrl + apiPrefix;
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String userDataKey = 'user_data';
  
  // Cookie name (debe coincidir con TOKEN_NAME del backend)
  static const String cookieName = 'authToken';
  
  // Endpoints - ACTUALIZADOS según tu backend
  static const String authEndpoint = '/auth';
  static const String loginEndpoint = '$authEndpoint/login';
  static const String registerEndpoint = authEndpoint; // POST /auth
  static const String tokenEndpoint = '$authEndpoint/token';
  static const String checkCookieEndpoint = '$authEndpoint/check-cookie';
  static const String updateUserEndpoint = '$authEndpoint/user'; // /user/:email
  
  // Validation
  static const int minPasswordLength = 8;
  
  // Regex patterns
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  // Roles disponibles
  static const String roleAdmin = 'Admin';
  static const String roleCustomer = 'Customer';
  static const String roleManager = 'Manager';
  
  static const List<String> availableRoles = [roleAdmin, roleCustomer, roleManager];
  static const String defaultRole = roleCustomer;
}

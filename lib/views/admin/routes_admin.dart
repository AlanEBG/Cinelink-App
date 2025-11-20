import 'package:flutter/material.dart';
import 'admin_page.dart';
import 'movies/movies_view.dart';
import 'customers/customer_view.dart';
import 'room/room_view.dart';
import 'showtimes/showtime_view.dart';
import 'tickets/ticket_view.dart';
import 'users/user_view.dart'; // Agregar esta importación

class AdminRoutes {
  // Rutas de admin
  static const String admin = '/admin';
  static const String adminMovies = '/admin/movies';
  static const String adminShowtimes = '/admin/showtimes';
  static const String adminTickets = '/admin/tickets';
  static const String adminRooms = '/admin/rooms';
  static const String adminUsers = '/admin/users'; // Agregar esta ruta
  static const String adminReports = '/admin/reports';

  // Mapa de rutas
  static Map<String, WidgetBuilder> get routes => {
    admin: (context) => const AdminPage(),
    adminMovies: (context) => const MoviesAdminPage(),
    adminShowtimes: (context) => const ShowtimesAdminPage(),
    adminTickets: (context) => const TicketsAdminPage(),
    adminRooms: (context) => const RoomsAdminPage(),
    adminUsers: (context) => const UsersAdminPage(), // Agregar esta línea
    //adminReports: (context) => const ReportsAdminPage(),
  };

  // Generador de rutas con parámetros
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case admin:
        return MaterialPageRoute(
          builder: (context) => const AdminPage(),
          settings: settings,
        );
      
      case adminMovies:
        return MaterialPageRoute(
          builder: (context) => const MoviesAdminPage(),
          settings: settings,
        );
      
      case adminShowtimes:
        return MaterialPageRoute(
          builder: (context) => const ShowtimesAdminPage(),
          settings: settings,
        );
      
      case adminTickets:
        return MaterialPageRoute(
          builder: (context) => const TicketsAdminPage(),
          settings: settings,
        );
      
      case adminRooms:
        return MaterialPageRoute(
          builder: (context) => const RoomsAdminPage(),
          settings: settings,
        );
      
      case adminUsers: // Agregar este case
        return MaterialPageRoute(
          builder: (context) => const UsersAdminPage(),
          settings: settings,
        );
      
      /*case adminReports:
        return MaterialPageRoute(
          builder: (context) => const ReportsAdminPage(),
          settings: settings,
        );*/
      
      default:
        return null;
    }
  }

  // Lista de rutas que requieren autenticación de admin
  static List<String> get protectedRoutes => [
    admin,
    adminMovies,
    adminShowtimes,
    adminTickets,
    adminRooms,
    adminUsers, // Agregar esta línea
    adminReports,
  ];

  // Verificar si una ruta es de admin
  static bool isAdminRoute(String? routeName) {
    return routeName?.startsWith('/admin') ?? false;
  }
}
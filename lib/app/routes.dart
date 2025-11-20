import 'package:cinelink_app/views/admin/admin_page.dart';
import 'package:cinelink_app/views/admin/movies/movies_view.dart';
import 'package:cinelink_app/views/admin/showtimes/showtime_view.dart';
import 'package:cinelink_app/views/admin/tickets/ticket_view.dart';
import 'package:cinelink_app/views/admin/room/room_view.dart';
import 'package:cinelink_app/views/admin/users/user_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../views/auth/login_page.dart';
import '../views/auth/signup_page.dart';
import '../views/home_page.dart';
import '../views/movies/movie_list_page.dart';
import '../controllers/auth_controller.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String movies = '/movies';
  static const String admin = '/admin';
  static const String adminMovies = '/admin/movies';
  static const String adminShowtimes = '/admin/showtimes';
  static const String adminTickets = '/admin/tickets';
  static const String adminRooms = '/admin/rooms';
  static const String adminUsers = '/admin/users';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashPage(),
        );
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );
      case signup:
        return MaterialPageRoute(
          builder: (_) => const SignupPage(),
        );
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
        );
      case movies:
        return MaterialPageRoute(
          builder: (_) => const MovieListPage(),
        );
      case admin:
        return MaterialPageRoute(
          builder: (_) => const AdminPage(),
        );
      case adminMovies:
        return MaterialPageRoute(
          builder: (_) => const MoviesAdminPage(),
        );
      case adminShowtimes:
        return MaterialPageRoute(
          builder: (_) => const ShowtimesAdminPage(),
        );
      case adminTickets:
        return MaterialPageRoute(
          builder: (_) => const TicketsAdminPage(),
        );
      case adminRooms:
        return MaterialPageRoute(
          builder: (_) => const RoomsAdminPage(),
        );
      case adminUsers:
        return MaterialPageRoute(
          builder: (_) => const UsersAdminPage(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

// Splash Page - Inicializa la autenticación
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    print('🎬 Iniciando Cine App...');
    
    // Esperar un frame para que Provider esté disponible
    await Future.delayed(Duration.zero);
    if (!mounted) return;

    final authController = context.read<AuthController>();
    await authController.initialize();

    if (!mounted) return;

    // Navegar según el estado de autenticación
    if (authController.isAuthenticated) {
      print('✅ Usuario autenticado, navegando a home');
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else {
      print('❌ Usuario no autenticado, navegando a login');
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo o icono
              Icon(
                Icons.movie_filter,
                size: 120,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              Text(
                'Cine App',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tu cine en la palma de tu mano',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cargando...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
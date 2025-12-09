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
import '../views/movies/movie_list_page.dart';
import '../views/profile/profile_page.dart';
import '../views/more/more_page.dart';
import '../controllers/auth_controller.dart';
import '../widgets/app_layout.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String movies = '/movies';
  // ❌ QUITAR showtimes de aquí (ShowtimeListPage requiere movie)
  // static const String showtimes = '/showtimes';
  static const String profile = '/profile';
  static const String more = '/more';

  // Admin routes (sin navbar)
  static const String admin = '/admin';
  static const String adminMovies = '/admin/movies';
  static const String adminShowtimes = '/admin/showtimes';
  static const String adminTickets = '/admin/tickets';
  static const String adminRooms = '/admin/rooms';
  static const String adminUsers = '/admin/users';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());

      // Auth pages (SIN navbar)
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case signup:
        return MaterialPageRoute(builder: (_) => const SignupPage());

      // Main pages (CON navbar usando AppLayout)
      case movies:
        return MaterialPageRoute(
          builder: (_) => const AppLayout(
            currentIndex: 0, // 🎬 Películas
            child: MovieListPage(),
          ),
        );

      // ❌ QUITAR esta ruta (ShowtimeListPage se accede desde MovieDetailPage)
      // case showtimes:
      //   return MaterialPageRoute(
      //     builder: (_) => const AppLayout(
      //       currentIndex: 1,
      //       child: ShowtimeListPage(),
      //     ),
      //   );

      case profile:
        return MaterialPageRoute(
          builder: (_) => const AppLayout(
            currentIndex: 2, // 👤 Perfil
            child: ProfilePage(),
          ),
        );

      case more:
        return MaterialPageRoute(
          builder: (_) => const AppLayout(
            currentIndex: 3, // ☰ Más
            child: MorePage(),
          ),
        );

      // Admin pages (SIN navbar)
      case admin:
        return MaterialPageRoute(builder: (_) => const AdminPage());

      case adminMovies:
        return MaterialPageRoute(builder: (_) => const MoviesAdminPage());

      case adminShowtimes:
        return MaterialPageRoute(builder: (_) => const ShowtimesAdminPage());

      case adminTickets:
        return MaterialPageRoute(builder: (_) => const TicketsAdminPage());

      case adminRooms:
        return MaterialPageRoute(builder: (_) => const RoomsAdminPage());

      case adminUsers:
        return MaterialPageRoute(builder: (_) => const UsersAdminPage());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}

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
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authController = context.read<AuthController>();
    await authController.initialize();

    if (!mounted) return;

    if (authController.isAuthenticated) {
      // Si el usuario está autenticado, verificar si es admin o usuario normal
      // Por defecto, redirigir a movies (home del usuario)
      // El usuario puede acceder a /admin desde el menú si tiene permisos
      print('[SplashPage] Usuario autenticado, redirigiendo a /movies');
      Navigator.of(context).pushReplacementNamed(AppRoutes.movies);
    } else {
      print('[SplashPage] Usuario no autenticado, redirigiendo a /login');
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            const Text(
              'Cine App',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

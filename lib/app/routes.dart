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
  static const String profile = '/profile';
  static const String more = '/more';

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
      
      case movies:
        return MaterialPageRoute(
          builder: (_) => const AppLayout(
            currentIndex: 0,
            child: MovieListPage(),
          ),
        );
      
      case profile:
        return MaterialPageRoute(
          builder: (_) => const AppLayout(
            currentIndex: 2,
            child: ProfilePage(),
          ),
        );
      
      case more:
        return MaterialPageRoute(
          builder: (_) => const AppLayout(
            currentIndex: 3,
            child: MorePage(),
          ),
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
      Navigator.of(context).pushReplacementNamed(AppRoutes.movies);
    } else {
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
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
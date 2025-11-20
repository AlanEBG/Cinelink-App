import 'package:flutter/material.dart';
import 'app/theme.dart';
import 'views/movies/movie_list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cine App',
      theme: appTheme, // <-- Aquí aplicamos el tema global
      home: const MovieListPage(),
    );
  }
}

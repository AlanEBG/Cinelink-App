import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class MovieService {
  // Cambia esta URL por la de tu backend NestJS
  static const String baseUrl = 'http://localhost:4000/movie';

  // Obtener todas las películas
  Future<List<Movie>> getMovies() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      // Convertir JSON a lista de objetos Movie
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar películas: ${response.statusCode}');
    }
  }
}

import 'dart:convert';
import 'package:cinelink_app/app/constant.dart';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class MovieService {
  // Cambia esta URL por la de tu backend NestJS
final String url = "${AppConstants.baseUrl}/movie";

  //MI RUTA A LA API!!!! ---  POR LA MISMA RED A LA QUE ESTE CONECTADOS



  // Obtener todas las películas
  Future<List<Movie>> getMovies() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Convertir JSON a lista de objetos Movie
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar películas: ${response.statusCode}');
    }
  }
}

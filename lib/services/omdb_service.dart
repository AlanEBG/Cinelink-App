import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OMDbService {
  static String get _apiKey => dotenv.env['OMDB_API_KEY'] ?? '';
  static const String _baseUrl = 'http://www.omdbapi.com/';

  Future<MovieDetails?> getMovieDetails(String movieTitle) async {
    if (_apiKey.isEmpty) return null;

    try {
      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: {
          'apikey': _apiKey,
          't': movieTitle,
          'plot': 'full',
          'type': 'movie',
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['Response'] == 'True') {
          return MovieDetails.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<MovieDetails?> getMovieDetailsByYear(
    String movieTitle,
    int year,
  ) async {
    if (_apiKey.isEmpty) return null;

    try {
      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: {
          'apikey': _apiKey,
          't': movieTitle,
          'y': year.toString(),
          'plot': 'full',
          'type': 'movie',
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['Response'] == 'True') {
          return MovieDetails.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

class MovieDetails {
  final String title;
  final String year;
  final String director;
  final String actors;
  final String plot;
  final String poster;
  final String imdbRating;
  final String genre;
  final String runtime;

  MovieDetails({
    required this.title,
    required this.year,
    required this.director,
    required this.actors,
    required this.plot,
    required this.poster,
    required this.imdbRating,
    required this.genre,
    required this.runtime,
  });

  factory MovieDetails.fromJson(Map<String, dynamic> json) {
    return MovieDetails(
      title: json['Title'] ?? '',
      year: json['Year'] ?? '',
      director: json['Director'] ?? 'N/A',
      actors: json['Actors'] ?? 'N/A',
      plot: json['Plot'] ?? '',
      poster: json['Poster'] ?? '',
      imdbRating: json['imdbRating'] ?? 'N/A',
      genre: json['Genre'] ?? '',
      runtime: json['Runtime'] ?? '',
    );
  }

  List<String> getDirectorsList() {
    if (director == 'N/A' || director.isEmpty) return [];
    return director.split(',').map((d) => d.trim()).toList();
  }

  List<String> getActorsList() {
    if (actors == 'N/A' || actors.isEmpty) return [];
    return actors.split(',').map((a) => a.trim()).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'year': year,
      'director': director,
      'actors': actors,
      'plot': plot,
      'poster': poster,
      'imdbRating': imdbRating,
      'genre': genre,
      'runtime': runtime,
    };
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TMDbService {
  static String get _apiKey => dotenv.env['TMDB_API_KEY'] ?? '';
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p';

  static const String profileSizeSmall = 'w185';
  static const String profileSizeMedium = 'h632';
  static const String profileSizeLarge = 'original';

  Future<TMDbMovie?> searchMovie(String movieTitle) async {
    if (_apiKey.isEmpty) return null;

    try {
      final searchUri = Uri.parse('$_baseUrl/search/movie').replace(
        queryParameters: {
          'api_key': _apiKey,
          'query': movieTitle,
          'language': 'es-ES',
          'include_adult': 'false',
        },
      );

      final searchResponse = await http.get(searchUri);
      if (searchResponse.statusCode != 200) return null;

      final searchData = json.decode(searchResponse.body);
      if (searchData['results'] == null || searchData['results'].isEmpty) {
        return null;
      }

      final movieData = searchData['results'][0];
      final movieId = movieData['id'];

      final creditsUri = Uri.parse(
        '$_baseUrl/movie/$movieId/credits',
      ).replace(queryParameters: {'api_key': _apiKey, 'language': 'es-ES'});

      final creditsResponse = await http.get(creditsUri);
      if (creditsResponse.statusCode != 200) {
        return TMDbMovie.fromJson(movieData, null);
      }

      final creditsData = json.decode(creditsResponse.body);
      return TMDbMovie.fromJson(movieData, creditsData);
    } catch (e) {
      return null;
    }
  }

  Future<TMDbPerson?> searchPerson(String personName) async {
    if (_apiKey.isEmpty) return null;

    try {
      final uri = Uri.parse('$_baseUrl/search/person').replace(
        queryParameters: {
          'api_key': _apiKey,
          'query': personName,
          'language': 'es-ES',
        },
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        return null;
      }

      final data = json.decode(response.body);

      if (data['results'] == null || data['results'].isEmpty) {
        return null;
      }

      return TMDbPerson.fromJson(data['results'][0]);
    } catch (e) {
      return null;
    }
  }

  static String getImageUrl(
    String? imagePath, {
    String size = profileSizeSmall,
  }) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }
    return '$_imageBaseUrl/$size$imagePath';
  }
}

class TMDbMovie {
  final int id;
  final String title;
  final String originalTitle;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String releaseDate;
  final List<TMDbCastMember> cast;
  final List<TMDbCrewMember> crew;

  TMDbMovie({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.releaseDate,
    required this.cast,
    required this.crew,
  });

  factory TMDbMovie.fromJson(
    Map<String, dynamic> movieJson,
    Map<String, dynamic>? creditsJson,
  ) {
    return TMDbMovie(
      id: movieJson['id'] ?? 0,
      title: movieJson['title'] ?? '',
      originalTitle: movieJson['original_title'] ?? '',
      overview: movieJson['overview'] ?? '',
      posterPath: movieJson['poster_path'],
      backdropPath: movieJson['backdrop_path'],
      releaseDate: movieJson['release_date'] ?? '',
      cast: creditsJson != null && creditsJson['cast'] != null
          ? (creditsJson['cast'] as List)
                .map((c) => TMDbCastMember.fromJson(c))
                .toList()
          : [],
      crew: creditsJson != null && creditsJson['crew'] != null
          ? (creditsJson['crew'] as List)
                .map((c) => TMDbCrewMember.fromJson(c))
                .toList()
          : [],
    );
  }

  List<TMDbCrewMember> getDirectors() {
    return crew.where((member) => member.job == 'Director').toList();
  }

  List<TMDbCastMember> getMainCast({int limit = 10}) {
    return cast.take(limit).toList();
  }

  String getPosterUrl({String size = TMDbService.profileSizeMedium}) {
    return TMDbService.getImageUrl(posterPath, size: size);
  }

  String getBackdropUrl({String size = 'w780'}) {
    return TMDbService.getImageUrl(backdropPath, size: size);
  }
}

class TMDbCastMember {
  final int id;
  final String name;
  final String character;
  final String? profilePath;
  final int order;

  TMDbCastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
    required this.order,
  });

  factory TMDbCastMember.fromJson(Map<String, dynamic> json) {
    return TMDbCastMember(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      character: json['character'] ?? '',
      profilePath: json['profile_path'],
      order: json['order'] ?? 999,
    );
  }

  String getProfileUrl({String size = TMDbService.profileSizeSmall}) {
    return TMDbService.getImageUrl(profilePath, size: size);
  }

  bool get hasPhoto => profilePath != null && profilePath!.isNotEmpty;
}

class TMDbCrewMember {
  final int id;
  final String name;
  final String job;
  final String department;
  final String? profilePath;

  TMDbCrewMember({
    required this.id,
    required this.name,
    required this.job,
    required this.department,
    this.profilePath,
  });

  factory TMDbCrewMember.fromJson(Map<String, dynamic> json) {
    return TMDbCrewMember(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      job: json['job'] ?? '',
      department: json['department'] ?? '',
      profilePath: json['profile_path'],
    );
  }

  String getProfileUrl({String size = TMDbService.profileSizeSmall}) {
    return TMDbService.getImageUrl(profilePath, size: size);
  }

  bool get hasPhoto => profilePath != null && profilePath!.isNotEmpty;
}

class TMDbPerson {
  final int id;
  final String name;
  final String? profilePath;
  final double popularity;
  final String knownForDepartment;

  TMDbPerson({
    required this.id,
    required this.name,
    this.profilePath,
    required this.popularity,
    required this.knownForDepartment,
  });

  factory TMDbPerson.fromJson(Map<String, dynamic> json) {
    return TMDbPerson(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      profilePath: json['profile_path'],
      popularity: (json['popularity'] ?? 0).toDouble(),
      knownForDepartment: json['known_for_department'] ?? '',
    );
  }

  String getProfileUrl({String size = TMDbService.profileSizeSmall}) {
    return TMDbService.getImageUrl(profilePath, size: size);
  }

  bool get hasPhoto => profilePath != null && profilePath!.isNotEmpty;
}

//import 'showtime.dart'; // Si quieres manejar showtimes también

class Movie {
  final int? movieId;
  final String movieTitle;
  final String movieDescription;
  final int movieDurationMinutes;
  final String movieGenre;
  final String? movieImageUrl;
  final String? movieTrailer;
  //final List<Showtime>? showtimes; // Opcional, según tu DTO

  Movie({
    this.movieId,
    required this.movieTitle,
    required this.movieDescription,
    required this.movieDurationMinutes,
    required this.movieGenre,
    this.movieImageUrl,
    this.movieTrailer,
    //this.showtimes,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      movieId: json['movieId'],
      movieTitle: json['movieTitle'],
      movieDescription: json['movieDescription'],
      movieDurationMinutes: json['movieDurationMinutes'],
      movieGenre: json['movieGenre'],
      movieImageUrl: json['movieImageUrl'],
      movieTrailer: json['movieTrailer'],
      /*showtimes: json['showtimes'] != null
          ? List<Showtime>.from(
              json['showtimes'].map((x) => Showtime.fromJson(x)))
          : null,*/
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'movieId': movieId,
      'movieTitle': movieTitle,
      'movieDescription': movieDescription,
      'movieDurationMinutes': movieDurationMinutes,
      'movieGenre': movieGenre,
      'movieImageUrl': movieImageUrl,
      'movieTrailer': movieTrailer,
      //'showtimes': showtimes?.map((x) => x.toJson()).toList(),
    };
  }
}

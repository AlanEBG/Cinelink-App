import 'omdb_service.dart';
import 'tmdb_service.dart';

class MovieInfoService {
  final OMDbService _omdbService = OMDbService();
  final TMDbService _tmdbService = TMDbService();

  /// Obtiene información completa combinando OMDb (texto) y TMDb (fotos)
  Future<CombinedMovieInfo?> getMovieInfo(String movieTitle) async {
    final omdbInfo = await _omdbService.getMovieDetails(movieTitle);
    final tmdbInfo = await _tmdbService.searchMovie(movieTitle);

    if (omdbInfo == null && tmdbInfo == null) return null;

    return CombinedMovieInfo(omdbData: omdbInfo, tmdbData: tmdbInfo);
  }
}

class CombinedMovieInfo {
  final MovieDetails? omdbData;
  final TMDbMovie? tmdbData;

  CombinedMovieInfo({required this.omdbData, required this.tmdbData});

  /// Obtiene lista de directores con sus fotos
  List<PersonWithPhoto> getDirectors() {
    final directors = <PersonWithPhoto>[];

    if (omdbData != null) {
      // Obtener nombres de directores desde OMDb
      final directorNames = omdbData!.getDirectorsList();

      // Buscar fotos en TMDb
      if (tmdbData != null) {
        final tmdbDirectors = tmdbData!.getDirectors();

        for (final directorName in directorNames) {
          final tmdbDirector = tmdbDirectors.firstWhere(
            (d) => _namesMatch(d.name, directorName),
            orElse: () => TMDbCrewMember(
              id: 0,
              name: directorName,
              job: 'Director',
              department: 'Directing',
              profilePath: null,
            ),
          );

          directors.add(
            PersonWithPhoto(
              name: directorName,
              photoUrl: tmdbDirector.profilePath != null
                  ? TMDbService.getImageUrl(tmdbDirector.profilePath!)
                  : null,
              role: 'Director',
            ),
          );
        }
      } else {
        for (final directorName in directorNames) {
          directors.add(
            PersonWithPhoto(
              name: directorName,
              photoUrl: null,
              role: 'Director',
            ),
          );
        }
      }
    } else if (tmdbData != null) {
      final tmdbDirectors = tmdbData!.getDirectors();
      for (final director in tmdbDirectors) {
        directors.add(
          PersonWithPhoto(
            name: director.name,
            photoUrl: director.profilePath != null
                ? TMDbService.getImageUrl(director.profilePath!)
                : null,
            role: 'Director',
          ),
        );
      }
    }

    return directors;
  }

  /// Obtiene lista de actores principales con sus fotos
  List<PersonWithPhoto> getCast({int limit = 10}) {
    final cast = <PersonWithPhoto>[];

    if (omdbData != null) {
      final actorNames = omdbData!.getActorsList();

      if (tmdbData != null) {
        final tmdbCast = tmdbData!.getMainCast(limit: limit);

        for (final actorName in actorNames.take(limit)) {
          final tmdbActor = tmdbCast.firstWhere(
            (a) => _namesMatch(a.name, actorName),
            orElse: () => TMDbCastMember(
              id: 0,
              name: actorName,
              character: '',
              profilePath: null,
              order: 999,
            ),
          );

          cast.add(
            PersonWithPhoto(
              name: actorName,
              photoUrl: tmdbActor.profilePath != null
                  ? TMDbService.getImageUrl(tmdbActor.profilePath!)
                  : null,
              role: tmdbActor.character.isNotEmpty ? tmdbActor.character : null,
            ),
          );
        }
      } else {
        for (final actorName in actorNames.take(limit)) {
          cast.add(
            PersonWithPhoto(name: actorName, photoUrl: null, role: null),
          );
        }
      }
    } else if (tmdbData != null) {
      final tmdbCast = tmdbData!.getMainCast(limit: limit);
      for (final actor in tmdbCast) {
        cast.add(
          PersonWithPhoto(
            name: actor.name,
            photoUrl: actor.profilePath != null
                ? TMDbService.getImageUrl(actor.profilePath!)
                : null,
            role: actor.character.isNotEmpty ? actor.character : null,
          ),
        );
      }
    }

    return cast;
  }

  /// Obtiene la sinopsis (prioriza OMDb en español, luego TMDb)
  String? getPlot() {
    if (omdbData != null && omdbData!.plot.isNotEmpty) {
      return omdbData!.plot;
    }
    if (tmdbData != null && tmdbData!.overview.isNotEmpty) {
      return tmdbData!.overview;
    }
    return null;
  }

  /// Obtiene el poster URL (prioriza TMDb por calidad)
  String? getPosterUrl() {
    if (tmdbData != null && tmdbData!.posterPath != null) {
      return tmdbData!.getPosterUrl();
    }
    if (omdbData != null && omdbData!.poster != 'N/A') {
      return omdbData!.poster;
    }
    return null;
  }

  bool _namesMatch(String name1, String name2) {
    final normalized1 = name1.toLowerCase().trim();
    final normalized2 = name2.toLowerCase().trim();

    if (normalized1 == normalized2) return true;

    if (normalized1.contains(normalized2) ||
        normalized2.contains(normalized1)) {
      return true;
    }

    return false;
  }

  bool get hasCompleteInfo => omdbData != null || tmdbData != null;
  bool get hasPhotos => tmdbData != null;
}

class PersonWithPhoto {
  final String name;
  final String? photoUrl;
  final String? role;

  PersonWithPhoto({required this.name, this.photoUrl, this.role});

  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;
}

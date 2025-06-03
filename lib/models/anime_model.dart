class Anime {
  final int malId;
  final String title;
  final String imageUrl;
  final String url;          // Link MyAnimeList
  final String? trailerUrl;  // Link trailer YouTube, nullable
  final String? synopsis;
  final String? type;
  final String? source;
  final int? episodes;
  final String? status;
  final String? airedFrom;
  final String? airedTo;
  final double? score;
  final int? rank;
  final int? popularity;
  final List<String> genres;
  final String? rating;

  Anime({
    required this.malId,
    required this.title,
    required this.imageUrl,
    required this.url,
    this.trailerUrl,
    this.synopsis,
    this.type,
    this.source,
    this.episodes,
    this.status,
    this.airedFrom,
    this.airedTo,
    this.score,
    this.rank,
    this.popularity,
    this.genres = const [],
    this.rating,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    List<String> parseGenres(dynamic genreList) {
      if (genreList is List) {
        return genreList.map((g) => g['name'] as String).toList();
      }
      return [];
    }

    return Anime(
      malId: json['mal_id'] as int,
      title: json['title'] as String,
      imageUrl: json['images']?['jpg']?['large_image_url'] as String? ??
                json['images']?['jpg']?['image_url'] as String? ??
                'https://placehold.co/200x300/2D2D2D/FFFFFF?text=No+Image',
      url: json['url'] as String,
      trailerUrl: json['trailer']?['url'] as String?,  // Ambil trailer URL, bisa null
      synopsis: json['synopsis'] as String?,
      type: json['type'] as String?,
      source: json['source'] as String?,
      episodes: json['episodes'] as int?,
      status: json['status'] as String?,
      airedFrom: json['aired']?['from'] as String?,
      airedTo: json['aired']?['to'] as String?,
      score: (json['score'] as num?)?.toDouble(),
      rank: json['rank'] as int?,
      popularity: json['popularity'] as int?,
      genres: parseGenres(json['genres']),
      rating: json['rating'] as String?,
    );
  }
}

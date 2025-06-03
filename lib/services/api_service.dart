import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anime_model.dart';

class ApiService {
  static const String _baseUrl = 'https://api.jikan.moe/v4';

  Future<List<Anime>> fetchAnime({
    String query = '',
    String status = '', // airing, complete, upcoming
    String rating = '', // g, pg, pg13, r17, r, rx
    Set<String> genres = const {}, // genre ids comma separated
    String orderBy = 'popularity',
    String sort = 'asc',
    double min_score = 0,
    int page = 1,
    int limit = 24,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'q': query,
        'sfw': 'true',
        'page': page.toString(),
        'limit': limit.toString(),
        'order_by': orderBy,
        'sort': sort,
        'min_score': min_score.toString(),
      };

      String genresApiParameter = "";
      if (genres.isNotEmpty) {
        genresApiParameter = genres.join(',');
        // Hasil dari .join(',') di sini akan menjadi string "22,4" atau "4,22"
        // (Urutan dalam Set tidak dijamin, tapi untuk parameter genres Jikan API, urutan ID biasanya tidak masalah)
      }

      if (status.isNotEmpty) queryParams['status'] = status;
      if (rating.isNotEmpty) queryParams['rating'] = rating;
      if (genres.isNotEmpty) queryParams['genres'] = genres.join(',');

      final uri = Uri.parse('$_baseUrl/anime').replace(queryParameters: queryParams);

      print('Fetching anime from: $uri');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> animeListJson = data['data'] as List<dynamic>;
        return animeListJson
            .map((jsonItem) => Anime.fromJson(jsonItem as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 429) {

        // Rate limit exceeded, wait and retry or inform user
        print('Rate limit exceeded. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        await Future.delayed(Duration(seconds: 5)); // Wait 5 seconds
        return fetchAnime(
          query: query,
          status: status,
          rating: rating,
          genres: genres,
          orderBy: orderBy,
          sort: sort,
          page: page,
          limit: limit,
        ); // Retry
      } else {
        print('Failed to load anime. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load anime: ${response.statusCode}');

      }
    } catch (e) {
      print('Error fetching anime: $e');
      throw Exception('Error fetching anime: $e');
    }
  }

  Future<Anime> fetchAnimeDetail(int malId) async {
    try {
      final uri = Uri.parse('$_baseUrl/anime/$malId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Map<String, dynamic> animeJson = data['data'] as Map<String, dynamic>;
        return Anime.fromJson(animeJson);
      } else {
        throw Exception('Failed to load anime detail, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching anime detail: $e');
      throw Exception('Error fetching anime detail: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchGenres() async {
    final response = await http.get(Uri.parse('$_baseUrl/genres/anime'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> genresListJson = data['data'] as List<dynamic>;
      return genresListJson
          .map(
            (g) => {'mal_id': g['mal_id'] as int, 'name': g['name'] as String},
          )
          .toList();
    } else {
      throw Exception('Failed to load genres');
    }
  }
}

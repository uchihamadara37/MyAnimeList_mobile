import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/anime_model.dart';

class AnimeDetailScreen extends StatelessWidget {
  final Anime anime;

  const AnimeDetailScreen({Key? key, required this.anime}) : super(key: key);

  Future<void> _launchMALPage(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Tidak dapat membuka URL: $url');
    }
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.white70, fontSize: 14),
          children: [
            TextSpan(text: '$label: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  String _formatAired(String? from, String? to) {
    if (from == null) return 'Tidak diketahui';
    String fromDate = from.split('T').first;
    String toDate = to?.split('T').first ?? 'Sekarang';
    return '$fromDate sampai $toDate';
  }

  String _formatGenres(List<String> genres) {
    return genres.isEmpty ? 'Tidak ada' : genres.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(anime.title),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (anime.imageUrl.isNotEmpty)
              Center(
                child: Image.network(
                  anime.imageUrl,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 16),
            Text(
              anime.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (anime.synopsis != null && anime.synopsis!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: Text(
                  anime.synopsis!,
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ),

            _buildInfoRow('Type', anime.type),
            _buildInfoRow('Episodes', anime.episodes?.toString()),
            _buildInfoRow('Status', anime.status),
            _buildInfoRow('Aired', _formatAired(anime.airedFrom, anime.airedTo)),
            _buildInfoRow('Rating', anime.rating),
            _buildInfoRow('Score', anime.score?.toStringAsFixed(2)),
            _buildInfoRow('Rank', anime.rank?.toString()),
            _buildInfoRow('Popularity', anime.popularity?.toString()),
            _buildInfoRow('Genres', _formatGenres(anime.genres)),

            SizedBox(height: 24),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.open_in_new),
                    label: Text('Lihat di MyAnimeList'),
                    onPressed: () {
                      _launchMALPage(anime.url);
                    },
                  ),
                  SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: Icon(Icons.play_circle_fill),
                    label: Text('Tonton Trailer'),
                    onPressed: () async {
                      if (anime.trailerUrl != null && anime.trailerUrl!.isNotEmpty) {
                        final uri = Uri.parse(anime.trailerUrl!);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Tidak dapat membuka trailer.')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Trailer tidak tersedia.')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

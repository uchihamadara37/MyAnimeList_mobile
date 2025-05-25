import 'package:flutter/material.dart';
import 'package:my_anime_list_gemini/models/anime_model.dart';
// Import Anime model
// import '../models/anime_model.dart'; // Path might need adjustment

class AnimeCard extends StatelessWidget {
  final Anime anime;
  final VoidCallback onTap;
  final VoidCallback onBookmarkTap;

  AnimeCard({required this.anime, required this.onTap, required this.onBookmarkTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  anime.imageUrl,
                  width: 100,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 150,
                      color: Colors.grey[700],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image_outlined, color: Colors.grey[400], size: 30),
                          SizedBox(height: 4),
                          Text("No Image", style: TextStyle(color: Colors.grey[400], fontSize: 10))
                        ],
                      ),
                    );
                  },
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                       width: 100,
                       height: 150,
                       color: Colors.grey[700],
                       child: Center(
                         child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                          color: Colors.deepPurpleAccent[100],
                                             ),
                       ),
                    );
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anime.title,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6),
                    if (anime.type != null)
                      Text('Tipe: ${anime.type}', style: TextStyle(fontSize: 13, color: Colors.white70)),
                    if (anime.episodes != null)
                      Text('Episode: ${anime.episodes}', style: TextStyle(fontSize: 13, color: Colors.white70)),
                    if (anime.status != null)
                      Text('Status: ${anime.status}', style: TextStyle(fontSize: 13, color: Colors.white70)),
                    if (anime.score != null)
                      Row(
                        children: [
                          Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                          SizedBox(width: 4),
                          Text('${anime.score}', style: TextStyle(fontSize: 14, color: Colors.amber, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    SizedBox(height: 8),
                     if (anime.genres.isNotEmpty)
                      Wrap(
                        spacing: 4.0,
                        runSpacing: 2.0,
                        children: anime.genres.take(3).map((genre) => Chip(
                          label: Text(genre, style: TextStyle(fontSize: 10, color: Colors.white)),
                          backgroundColor: Colors.deepPurpleAccent.withOpacity(0.7),
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        )).toList(),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.bookmark_add_outlined, color: Colors.deepPurpleAccent[100]),
                onPressed: onBookmarkTap,
                tooltip: 'Tambah ke Bookmark',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
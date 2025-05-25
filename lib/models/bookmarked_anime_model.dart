class BookmarkedAnimeModel {
  final int? id;
  final int containerId;
  final int animeMalId; // MAL ID of the anime
  final String animeTitle;
  final String animeImageUrl;

  BookmarkedAnimeModel({
    this.id,
    required this.containerId,
    required this.animeMalId,
    required this.animeTitle,
    required this.animeImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'containerId': containerId,
      'animeMalId': animeMalId,
      'animeTitle': animeTitle,
      'animeImageUrl': animeImageUrl,
    };
  }

  factory BookmarkedAnimeModel.fromMap(Map<String, dynamic> map) {
    return BookmarkedAnimeModel(
      id: map['id'] as int?,
      containerId: map['containerId'] as int,
      animeMalId: map['animeMalId'] as int,
      animeTitle: map['animeTitle'] as String,
      animeImageUrl: map['animeImageUrl'] as String,
    );
  }
}
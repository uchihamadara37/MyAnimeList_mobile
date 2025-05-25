class BookmarkContainerModel {
  final int? id;
  final String name;
  final String? logoPath; // Path to the image file in local storage

  BookmarkContainerModel({this.id, required this.name, this.logoPath});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'logoPath': logoPath,
    };
  }

  factory BookmarkContainerModel.fromMap(Map<String, dynamic> map) {
    return BookmarkContainerModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      logoPath: map['logoPath'] as String?,
    );
  }
}
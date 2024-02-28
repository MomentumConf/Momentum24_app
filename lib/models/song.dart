class Song {
  String title;
  String originalTitle;
  String lyrics;

  Song(
      {required this.title, required this.originalTitle, required this.lyrics});

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      title: json['title'],
      originalTitle: json['originalTitle'],
      lyrics: json['lyrics']
          .replaceAllMapped(RegExp(r'(?<!\s\s)\n'), (match) => r'  \n'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'originalTitle': originalTitle,
      'lyrics': lyrics,
    };
  }
}

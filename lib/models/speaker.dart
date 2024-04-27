class Speaker {
  final String id;
  final String name;
  final String description;
  final String coverUrl;
  final String coverLqip;
  final String imageUrl;
  final String imageLqip;
  final List<dynamic> events;

  Speaker({
    required this.id,
    required this.name,
    required this.description,
    required this.coverUrl,
    required this.coverLqip,
    required this.imageUrl,
    required this.imageLqip,
    required this.events,
  });

  factory Speaker.fromJson(Map<String, dynamic> json) {
    return Speaker(
        id: json['_id'],
        name: json['name'],
        description: json['description'],
        coverUrl: json['coverUrl'],
        coverLqip: json['coverLqip'],
        imageUrl: json['imageUrl'],
        imageLqip: json['imageLqip'],
        events: json['events'] ?? []);
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'coverUrl': coverUrl,
      'coverLqip': coverLqip,
      'imageUrl': imageUrl,
      'imageLqip': imageLqip,
      'events': events,
    };
  }
}

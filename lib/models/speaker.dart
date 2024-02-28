class Speaker {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String imageLqip;
  final List<dynamic> events;

  Speaker({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.imageLqip,
    required this.events,
  });

  factory Speaker.fromJson(Map<String, dynamic> json) {
    return Speaker(
        id: json['_id'],
        name: json['name'],
        description: json['description'],
        imageUrl: json['imageUrl'],
        imageLqip: json['imageLqip'],
        events: json['events'] ?? []);
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'imageLqip': imageLqip,
      'events': events,
    };
  }
}

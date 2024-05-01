class Speaker {
  final String id;
  final String name;
  final String description;
  final String coverUrl;
  final String coverLqip;
  final String imageUrl;
  final String imageLqip;
  List<dynamic> events = [];

  Speaker({
    required this.id,
    required this.name,
    required this.description,
    required this.coverUrl,
    required this.coverLqip,
    required this.imageUrl,
    required this.imageLqip,
    this.events = const [],
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

class EventSpeaker {
  final String id;
  final String name;
  final String imageUrl;
  final String imageLqip;

  EventSpeaker({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.imageLqip,
  });

  factory EventSpeaker.fromJson(Map<String, dynamic> json) {
    return EventSpeaker(
      id: json['_id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      imageLqip: json['imageLqip'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'imageUrl': imageUrl,
      'imageLqip': imageLqip,
    };
  }
}

import './speaker.dart';

class Category {
  final ColorData textColor;
  final ColorData color;

  Category({required this.textColor, required this.color});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      textColor: ColorData.fromJson(json['textColor']),
      color: ColorData.fromJson(json['color']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'textColor': textColor.toJson(),
      'color': color.toJson(),
    };
  }
}

class ColorData {
  final double alpha;
  final int hex; // Store color as an integer

  ColorData({required this.alpha, required this.hex});

  factory ColorData.fromJson(Map<String, dynamic> json) {
    // Convert HEX string to integer
    final hexString = json['hex'].replaceAll('#', '');
    final hexInt = int.parse("ff$hexString", radix: 16);

    return ColorData(
      alpha: (json['alpha'] as num).toDouble(),
      hex: hexInt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alpha': alpha,
      'hex': '#${hex.toRadixString(16)}',
    };
  }
}

class Event {
  final String title;
  final String? description;
  final DateTime start;
  final String? location;
  final List<EventSpeaker> speakers;
  final List<Event> subevents;
  final Category? category;

  Event({
    required this.title,
    this.description,
    required this.start,
    this.location,
    this.speakers = const <EventSpeaker>[],
    this.subevents = const <Event>[],
    this.category,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'],
      description: json['description'],
      start: json['start'] != null
          ? DateTime.parse(json['start']).toLocal()
          : DateTime.now(), // Subevents have no start date
      location: json['location'],
      speakers: json['speakers'] != null
          ? List<EventSpeaker>.from(
              json['speakers'].map((x) => EventSpeaker.fromJson(x)))
          : <EventSpeaker>[],
      subevents: json['subevents'] != null
          ? List<Event>.from(json['subevents'].map((x) => Event.fromJson(x)))
          : [],
      category:
          json['category'] != null ? Category.fromJson(json['category']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'start': start.toUtc().toIso8601String(),
      'location': location,
      'speakers': speakers.map((x) => x.toJson()).toList(),
      'subevents': subevents.map((x) => x.toJson()).toList(),
      'category': category?.toJson(),
    };
  }
}

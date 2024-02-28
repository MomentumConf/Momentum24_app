import './speaker.dart';

class Event {
  final String title;
  final String? description;
  final DateTime start;
  final String? location;
  final List<Speaker> speakers;
  final List<Event> subevents;

  Event({
    required this.title,
    this.description,
    required this.start,
    this.location,
    this.speakers = const <Speaker>[],
    this.subevents = const <Event>[],
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'],
      description: json['description'],
      start: json['start'] != null
          ? DateTime.parse(json['start']).toLocal()
          : DateTime.now(),
      location: json['location'],
      speakers: json['speakers'] != null
          ? List<Speaker>.from(json['speakers'].map((x) => Speaker.fromJson(x)))
          : <Speaker>[],
      subevents: json['subevents'] != null
          ? List<Event>.from(json['subevents'].map((x) => Event.fromJson(x)))
          : [],
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
    };
  }
}

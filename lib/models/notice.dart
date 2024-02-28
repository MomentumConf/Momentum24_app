class Notice {
  final String id;
  final String title;
  final String description;
  final DateTime date;

  Notice({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
    };
  }
}

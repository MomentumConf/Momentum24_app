import 'dart:async';

import '../client.dart';

abstract class ApiService {
  Future<List<dynamic>> fetchSchedule();
  Future<String> fetchRegulations();
  Future<List<dynamic>> fetchSpeakers();
  Future<List<dynamic>> fetchNotifications();
  Future<int> countNotificationsFromDate(DateTime fromDate);
  Future<List<dynamic>> fetchSongs();
  Future<Map<String, dynamic>> fetchMap();
}

class SanityApiService implements ApiService {
  @override
  Future<List<dynamic>> fetchSchedule() async {
    final data =
        await sanityClient.fetch(r"""*[_type == "event"] | order(start asc) {
        title,
        description,
        start,
        "location": location->name,
        "speakers": speakers[]->{
          _id,
          name,
          description,
          "imageUrl": imageUrl.asset->url,
          "imageLqip": imageUrl.asset->metadata.lqip,
        },
        category->,
        subevents[] {
          title,
          description,
          start,
          "location": location->name,
          "speakers": speakers[]->{
            _id,
            name,
            "imageUrl": imageUrl.asset->url,
            "imageLqip": imageUrl.asset->metadata.lqip,
          },
        }
      }
    """);

    return data;
  }

  @override
  Future<String> fetchRegulations() async {
    final data = await sanityClient.fetch(r"""*[_type == "regulation"][0]{
        content
      }
    """);
    return data['content'];
  }

  @override
  Future<List<dynamic>> fetchSpeakers() async {
    final List<dynamic> data =
        await sanityClient.fetch<List<dynamic>>(r"""*[_type == "speaker"]{
      _id,
      name,
      description,
      "coverUrl": cover.asset->url,
      "coverLqip": cover.asset->metadata.lqip,
      "imageUrl": imageUrl.asset->url,
      "imageLqip": imageUrl.asset->metadata.lqip,
      "events": *[_type == "event" && references(^._id)] | order(start asc) {
        _id,
        title,
        start,
        speakers[],
        subevents[] {
          ...,
          "location": location->name
        },
        "location": location->name
      }
    }
    """);

    return data;
  }

  @override
  Future<List<dynamic>> fetchNotifications() async {
    final currentDate = DateTime.now().toIso8601String();
    final data = await sanityClient
        .fetch(r"""*[_type == "notification" && date <= $currentDate] | order(date desc) {
  _id,
  title,
  description,
  date 
}""", params: {
      '\$currentDate': '"$currentDate"',
    });

    return data;
  }

  @override
  Future<int> countNotificationsFromDate(DateTime fromDate) async {
    final fromDateStr = fromDate.toUtc().toIso8601String();
    final data = await sanityClient
        .fetch(r"""count(*[_type == "notification" && date >= $fromDate] | order(date desc))""",
            params: {
          '\$fromDate': '"$fromDateStr"',
        });

    return data;
  }

  @override
  Future<List<dynamic>> fetchSongs() async {
    final data = await sanityClient.fetch(r"""*[_type == "song"]{
        title,
        originalTitle,
        lyrics
      }
    """);

    return data;
  }

  @override
  Future<Map<String, dynamic>> fetchMap() async {
    final data = await sanityClient.fetch(r"""*[_type == "map"][0]{
        center,
        markers[],
        zoom
      }
    """);

    return data;
  }
}

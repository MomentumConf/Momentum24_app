import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import './api_service.dart';
import './cache_manager.dart';
import '../models/event.dart';
import '../models/map.dart';
import '../models/notice.dart';
import '../models/song.dart';
import '../models/speaker.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class DataProviderService {
  final ApiService apiService = GetIt.instance.get<ApiService>();
  void Function(dynamic value) changesNotifier = _defaultNotifier;
  CacheManager cacheManager = GetIt.instance.get<CacheManager>();

  static const int MINUTE = 60;
  static const int HOUR = 60 * MINUTE;
  static const int DAY = 24 * HOUR;

  static Map<String, int> TTL = {
    CacheManager.scheduleKey: 10 * MINUTE,
    CacheManager.regulationsKey: DAY,
    CacheManager.speakersKey: HOUR,
    CacheManager.notificationsKey: 10 * MINUTE,
    CacheManager.songsKey: DAY,
    CacheManager.mapDataKey: HOUR,
  };

  static void _defaultNotifier(dynamic value) {}

  DataProviderService setNotifier(void Function(dynamic value) notifier) {
    changesNotifier = notifier;
    return this;
  }

  Future<List<Event>> getSchedule({bool forceNewData = false}) async {
    List<Event> mapToEventList(List<dynamic> value) =>
        value.map<Event>((event) => Event.fromJson(event)).toList();

    try {
      String? cachedData = await cacheManager.getScheduleData();
      if (!forceNewData && cachedData != null) {
        final lastUpdate =
            await cacheManager.getLastUpdate(CacheManager.scheduleKey);
        if (lastUpdate != null &&
            DateTime.now().difference(lastUpdate).inSeconds <
                TTL[CacheManager.scheduleKey]!) {
          return mapToEventList(json.decode(cachedData));
        }

        apiService
            .fetchSchedule()
            .then((value) {
              cacheManager.cacheScheduleData(json.encode(value));
              cacheManager.setLastUpdate(
                  CacheManager.scheduleKey, DateTime.now());
              return value;
            })
            .then(mapToEventList)
            .then(changesNotifier);

        return mapToEventList(json.decode(cachedData));
      }

      final apiData = await apiService.fetchSchedule();
      cacheManager.cacheScheduleData(json.encode(apiData));
      cacheManager.setLastUpdate(CacheManager.scheduleKey, DateTime.now());

      final data = mapToEventList(apiData);
      changesNotifier(data);
      return data;
    } catch (e) {
      await Sentry.captureException(e);
      log("$e");
      return [];
    }
  }

  Future<String> getRegulations() async {
    try {
      String? cachedData = await cacheManager.getRegulationsData();
      if (cachedData != null) {
        final lastUpdate =
            await cacheManager.getLastUpdate(CacheManager.regulationsKey);
        if (lastUpdate != null &&
            DateTime.now().difference(lastUpdate).inSeconds <
                TTL[CacheManager.regulationsKey]!) {
          return cachedData;
        }

        apiService.fetchRegulations().then((value) {
          cacheManager.cacheRegulationsData(value);
          cacheManager.setLastUpdate(
              CacheManager.regulationsKey, DateTime.now());
          return value;
        }).then(changesNotifier);
        return cachedData;
      }

      final apiData = await apiService.fetchRegulations();
      cacheManager.cacheRegulationsData(apiData);
      cacheManager.setLastUpdate(CacheManager.regulationsKey, DateTime.now());
      changesNotifier(apiData);

      return apiData;
    } catch (e) {
      await Sentry.captureException(e);
      log("$e");
      return 'Error while loading regulations.';
    }
  }

  Future<List<Speaker>> getSpeakers() async {
    List<Speaker> mapToSpeakerList(List<dynamic> value) {
      return value
          .map<Speaker>((speaker) => Speaker.fromJson(speaker))
          .toList();
    }

    try {
      String? cachedData = await cacheManager.getSpeakersData();
      if (cachedData != null) {
        final lastUpdate =
            await cacheManager.getLastUpdate(CacheManager.speakersKey);
        if (lastUpdate != null &&
            DateTime.now().difference(lastUpdate).inSeconds <
                TTL[CacheManager.speakersKey]!) {
          return mapToSpeakerList(json.decode(cachedData));
        }

        apiService
            .fetchSpeakers()
            .then((value) {
              cacheManager.cacheSpeakersData(json.encode(value));
              cacheManager.setLastUpdate(
                  CacheManager.speakersKey, DateTime.now());
              return value;
            })
            .then(mapToSpeakerList)
            .then(changesNotifier);
        return mapToSpeakerList(json.decode(cachedData));
      }

      final apiData = await apiService.fetchSpeakers();
      cacheManager.cacheSpeakersData(json.encode(apiData));
      cacheManager.setLastUpdate(CacheManager.speakersKey, DateTime.now());

      final data = mapToSpeakerList(apiData);
      changesNotifier(data);
      return data;
    } catch (e) {
      await Sentry.captureException(e);
      log("$e");
      rethrow;
    }
  }

  Future<List<Notice>> getNotifications({bool forceNewData = false}) async {
    List<Notice> mapToNoticeList(List<dynamic> value) {
      return value.map<Notice>((notice) => Notice.fromJson(notice)).toList();
    }

    try {
      String? cachedData = await cacheManager.getNotificationsData();
      if (!forceNewData && cachedData != null) {
        final lastUpdate =
            await cacheManager.getLastUpdate(CacheManager.notificationsKey);
        if (lastUpdate != null &&
            DateTime.now().difference(lastUpdate).inSeconds <
                TTL[CacheManager.notificationsKey]!) {
          return mapToNoticeList(json.decode(cachedData));
        }

        apiService
            .fetchNotifications()
            .then((value) {
              cacheManager.cacheNotificationsData(json.encode(value));
              cacheManager.setLastUpdate(
                  CacheManager.notificationsKey, DateTime.now());
              return value;
            })
            .then(mapToNoticeList)
            .then(changesNotifier);
        return mapToNoticeList(json.decode(cachedData) as List<dynamic>);
      }

      final apiData = await apiService.fetchNotifications();
      cacheManager.cacheNotificationsData(json.encode(apiData));
      cacheManager.setLastUpdate(CacheManager.notificationsKey, DateTime.now());

      final data = mapToNoticeList(apiData);
      changesNotifier(data);
      return data;
    } catch (e) {
      await Sentry.captureException(e);
      log("$e");
      return [];
    }
  }

  Future<List<Song>> getSongs({bool forceNewData = false}) async {
    List<Song> mapToSongList(List<dynamic> value) {
      return value.map<Song>((song) => Song.fromJson(song)).toList();
    }

    try {
      String? cachedData = await cacheManager.getSongsData();
      if (!forceNewData && cachedData != null) {
        final lastUpdate =
            await cacheManager.getLastUpdate(CacheManager.songsKey);
        if (lastUpdate != null &&
            DateTime.now().difference(lastUpdate).inSeconds <
                TTL[CacheManager.songsKey]!) {
          return mapToSongList(json.decode(cachedData));
        }

        apiService
            .fetchSongs()
            .then((value) {
              cacheManager.cacheSongsData(json.encode(value));
              cacheManager.setLastUpdate(CacheManager.songsKey, DateTime.now());
              return value;
            })
            .then(mapToSongList)
            .then(changesNotifier);
        return mapToSongList(json.decode(cachedData) as List<dynamic>);
      }

      final apiData = await apiService.fetchSongs();
      cacheManager.cacheSongsData(json.encode(apiData));
      cacheManager.setLastUpdate(CacheManager.songsKey, DateTime.now());

      final data = mapToSongList(apiData).cast<Song>();
      changesNotifier(data);
      return data;
    } catch (e) {
      await Sentry.captureException(e);
      log("$e");
      return [];
    }
  }

  Future<MapData> getMapData() async {
    MapData mapToMapData(Map<String, dynamic> value) {
      return MapData.fromJson(value);
    }

    try {
      String? cachedData = await cacheManager.getMapData();
      if (cachedData != null) {
        final lastUpdate =
            await cacheManager.getLastUpdate(CacheManager.mapDataKey);
        if (lastUpdate != null &&
            DateTime.now().difference(lastUpdate).inSeconds <
                TTL[CacheManager.mapDataKey]!) {
          return mapToMapData(json.decode(cachedData) as Map<String, dynamic>);
        }

        apiService
            .fetchMap()
            .then((value) {
              cacheManager.cacheMapData(json.encode(value));
              cacheManager.setLastUpdate(
                  CacheManager.mapDataKey, DateTime.now());
              return value;
            })
            .then(mapToMapData)
            .then(changesNotifier);
        return mapToMapData(json.decode(cachedData) as Map<String, dynamic>);
      }

      final apiData = await apiService.fetchMap();
      cacheManager.cacheMapData(json.encode(apiData));
      cacheManager.setLastUpdate(CacheManager.mapDataKey, DateTime.now());

      final data = mapToMapData(apiData);
      changesNotifier(data);
      return data;
    } catch (e) {
      await Sentry.captureException(e);
      log("$e");
      return MapData(
        center: const LatLng(54.1795, 15.5685),
        markers: [],
        zoom: 15,
      );
    }
  }

  Future<void> prefetchAndCacheData() async {
    try {
      await Future.wait([
        getSpeakers(),
        getMapData(),
        getSongs(),
        getRegulations(),
      ]);
    } catch (e) {
      await Sentry.captureException(e);
      log("$e");
    }
  }
}

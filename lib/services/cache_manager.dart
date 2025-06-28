import 'package:shared_preferences/shared_preferences.dart';

abstract class CacheManager {
  static const String scheduleKey = 'schedule';
  static const String regulationsKey = 'regulations';
  static const String speakersKey = 'speakers';
  static const String notificationsKey = 'notifications';
  static const String lastReadNotificationKey = 'lastReadNotification';
  static const String songsKey = 'songs';
  static const String mapDataKey = 'mapData';
  static const String socialMediaKey = 'socialMedia';

  Future<void> cacheMapData(String jsonData);
  Future<void> cacheNotificationsData(String jsonData);
  Future<void> cacheRegulationsData(String jsonData);
  Future<void> cacheScheduleData(String jsonData);
  Future<void> cacheSocialMediaData(String jsonData);
  Future<void> cacheSongsData(String jsonData);
  Future<void> cacheSpeakersData(String jsonData);
  Future<String?> getMapData();
  Future<String?> getNotificationsData();
  Future<String?> getRegulationsData();
  Future<String?> getScheduleData();
  Future<String?> getSocialMediaData();
  Future<String?> getSongsData();
  Future<String?> getSpeakersData();
  Future<DateTime?> getLastReadNotificationDate();
  Future<DateTime?> getLastUpdate(String key);
  Future<void> saveLastReadNotificationDate(DateTime date);
  Future<void> setLastUpdate(String key, DateTime time);
  Future<void> clearCache();
  Future<void> clearSpeakersCache();
}

class PreferencesCacheManager implements CacheManager {
  final prefs = SharedPreferences.getInstance();

  @override
  Future<DateTime?> getLastUpdate(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString('${key}_lastUpdate');
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }

  @override
  Future<void> setLastUpdate(String key, DateTime time) async {
    (await prefs)
        .setString('${key}_lastUpdate', time.toUtc().toIso8601String());
  }

  @override
  Future<void> cacheScheduleData(String jsonData) async {
    await (await prefs).setString(CacheManager.scheduleKey, jsonData);
  }

  @override
  Future<void> cacheRegulationsData(String jsonData) async {
    await (await prefs).setString(CacheManager.regulationsKey, jsonData);
  }

  @override
  Future<void> cacheSpeakersData(String jsonData) async {
    await (await prefs).setString(CacheManager.speakersKey, jsonData);
  }

  @override
  Future<void> clearSpeakersCache() async {
    await (await prefs).remove(CacheManager.speakersKey);
  }

  @override
  Future<String?> getScheduleData() async {
    return (await prefs).getString(CacheManager.scheduleKey);
  }

  @override
  Future<String?> getRegulationsData() async {
    return (await prefs).getString(CacheManager.regulationsKey);
  }

  @override
  Future<String?> getSpeakersData() async {
    return (await prefs).getString(CacheManager.speakersKey);
  }

  @override
  Future<void> cacheNotificationsData(String jsonData) async {
    await (await prefs).setString(CacheManager.notificationsKey, jsonData);
  }

  @override
  Future<String?> getNotificationsData() async {
    return (await prefs).getString(CacheManager.notificationsKey);
  }

  @override
  Future<void> saveLastReadNotificationDate(DateTime date) async {
    await (await prefs).setString(
        CacheManager.lastReadNotificationKey, date.toUtc().toIso8601String());
  }

  @override
  Future<DateTime?> getLastReadNotificationDate() async {
    final dateString =
        (await prefs).getString(CacheManager.lastReadNotificationKey);
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }

  @override
  Future<void> cacheSongsData(String jsonData) async {
    await (await prefs).setString(CacheManager.songsKey, jsonData);
  }

  @override
  Future<String?> getSongsData() async {
    return (await prefs).getString(CacheManager.songsKey);
  }

  @override
  Future<void> cacheMapData(String jsonData) async {
    await (await prefs).setString(CacheManager.mapDataKey, jsonData);
  }

  @override
  Future<String?> getMapData() async {
    return (await prefs).getString(CacheManager.mapDataKey);
  }

  @override
  Future<void> cacheSocialMediaData(String jsonData) async {
    await (await prefs).setString(CacheManager.socialMediaKey, jsonData);
  }

  @override
  Future<String?> getSocialMediaData() async {
    return (await prefs).getString(CacheManager.socialMediaKey);
  }

  @override
  Future<void> clearCache() async {
    await (await prefs).clear();
  }
}

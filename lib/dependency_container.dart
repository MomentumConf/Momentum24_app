import 'package:get_it/get_it.dart';
import 'package:momentum24_app/services/api_service.dart';
import 'package:momentum24_app/services/cache_manager.dart';
import 'package:momentum24_app/services/data_provider_service.dart';
import 'package:momentum24_app/services/theme_service.dart';

final getIt = GetIt.instance;

void registerDependencies() {
  getIt.registerSingleton<CacheManager>(PreferencesCacheManager());
  getIt.registerSingleton<ApiService>(SanityApiService());
  getIt.registerSingleton<DataProviderService>(DataProviderService());
  getIt.registerSingleton<ThemeService>(ThemeService());
}

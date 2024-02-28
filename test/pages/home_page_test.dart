import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:momentum24_app/services/api_service.dart';
import 'package:momentum24_app/services/cache_manager.dart';
import 'package:momentum24_app/services/data_provider_service.dart';
import 'package:momentum24_app/pages/home_page.dart';
import 'package:momentum24_app/pages/notifications_screen.dart';

// Mock the services
class MockApiService extends Mock implements ApiService {}

class MockCacheManager extends Mock implements CacheManager {}

class MockDataProviderService extends Mock implements DataProviderService {}

void main() {
  late MockApiService mockApiService;
  late MockCacheManager mockCacheManager;
  late MockDataProviderService mockDataProviderService;

  setUp(() {
    mockApiService = MockApiService();
    mockCacheManager = MockCacheManager();
    mockDataProviderService = MockDataProviderService();

    GetIt.I.reset();
    GetIt.I.registerSingleton<ApiService>(mockApiService);
    GetIt.I.registerSingleton<CacheManager>(mockCacheManager);
    GetIt.I.registerSingleton<DataProviderService>(mockDataProviderService);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  testWidgets('HomePage initializes correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomePage()),
    );

    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('HomePage shows correct screen on bottom navigation bar tap',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomePage()),
    );

    // Tap the second navigation bar item
    await tester.tap(find.byIcon(Icons.notifications).first);
    await tester.pumpAndSettle();

    // Check that the NotificationsScreen is now visible
    expect(find.byType(NotificationsScreen), findsOneWidget);
  });

  testWidgets('HomePage updates unread notifications count',
      (WidgetTester tester) async {
    when(mockApiService.countNotificationsFromDate(DateTime.now()))
        .thenAnswer((_) async => 5);

    await tester.pumpWidget(
      const MaterialApp(home: HomePage()),
    );

    await tester.pump(const Duration(minutes: 1));

    // Check that the unread notifications count has been updated
    expect(find.text('5'), findsOneWidget);
  });
}

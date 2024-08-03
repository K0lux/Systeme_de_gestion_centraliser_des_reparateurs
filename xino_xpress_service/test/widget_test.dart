import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mockito/mockito.dart';
import 'package:xino_xpress_service/main.dart';
import 'package:xino_xpress_service/services/auth_service.dart';
import 'package:xino_xpress_service/services/notification_service.dart';

// Mock classes for AuthService and NotificationService
class MockAuthService extends Mock implements AuthService {}

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  // Create mock instances of the services
  final mockAuthService = MockAuthService();
  final mockNotificationService = MockNotificationService();

  setUpAll(() async {
    // Initialize Firebase
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>.value(value: mockAuthService),
          ChangeNotifierProvider<NotificationService>.value(
              value: mockNotificationService),
        ],
        child: MyApp(),
      ),
    );
  });
}

import 'package:aegis_nexus/app/app.dart';
import 'package:aegis_nexus/app/bootstrap.dart';
import 'package:aegis_nexus/features/auth/presentation/providers/auth_provider.dart';
import 'package:aegis_nexus/features/chat/presentation/providers/chat_provider.dart';
import 'package:aegis_nexus/features/settings/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppBootstrap.init();
  });

  testWidgets('Home screen renders prompt composer', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>.value(
            value: AppBootstrap.settingsProvider,
          ),
          ChangeNotifierProvider<AuthProvider>.value(
            value: AppBootstrap.authProvider,
          ),
          ChangeNotifierProvider<ChatProvider>.value(
            value: AppBootstrap.chatProvider,
          ),
        ],
        child: const AegisNexusApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Envoyer'), findsOneWidget);
    expect(find.text('Voix'), findsOneWidget);
    expect(find.text('Importer'), findsOneWidget);
  });
}

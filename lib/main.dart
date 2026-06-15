import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';
import 'core/config/env_loader.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/chat/presentation/providers/chat_provider.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'features/workspaces/presentation/providers/workspace_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvLoader.load();
  EnvLoader.validate();
  await AppBootstrap.init();

  runApp(
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
        ChangeNotifierProvider<WorkspaceProvider>(
          create: (_) => WorkspaceProvider(),
        ),
      ],
      child: const AegisNexusApp(),
    ),
  );
}

import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/settings_repository.dart';
import 'presentation/screens/access/access_screen.dart';
import 'presentation/screens/main/main_screen.dart';
import 'presentation/screens/card/card_module_screen.dart';
import 'presentation/screens/p2p/p2p_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';

void main() {
  runApp(const POSApp());
}

class POSApp extends StatelessWidget {
  const POSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS Terminal',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/access',
      routes: {
        '/access': (context) => const AccessScreen(),
        '/main': (context) => const MainScreen(),
        '/card': (context) => const CardModuleScreen(),
        '/p2p': (context) => const P2PScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle arguments for settings (e.g., opening specific tab)
        if (settings.name == '/settings' && settings.arguments != null) {
          return MaterialPageRoute(
            builder: (context) => const SettingsScreen(),
          );
        }
        return null;
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/main/screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AkiraApp());
}

class AkiraApp extends StatelessWidget {
  const AkiraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akira Anime',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainScreen(),
    );
  }
}

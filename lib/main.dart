import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'services/download_service.dart';
import 'theme/app_theme.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay colors for modern edge-to-edge dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final storageService = await StorageService.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        ChangeNotifierProvider<DownloadService>(create: (_) => DownloadService()),
      ],
      child: const MovieBoxApp(),
    ),
  );
}

class MovieBoxApp extends StatelessWidget {
  const MovieBoxApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MovieBox Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationScreen(),
    );
  }
}

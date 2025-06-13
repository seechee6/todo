import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'screens/home_screen.dart';
import 'services/migration_service.dart';
import 'services/database_helper.dart';

void main() async {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database factory for web and desktop (only if not on web)
  if (!kIsWeb) {
    try {
      DatabaseHelper.initialize();
    } catch (e) {
      print(
        'Database initialization failed, will use SharedPreferences fallback: $e',
      );
    }
  }

  // Migrate existing data from SharedPreferences to SQLite if needed
  try {
    await MigrationService.migrateDataIfNeeded();
  } catch (e) {
    print('Migration failed, continuing with SharedPreferences: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

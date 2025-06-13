import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'screens/home_screen.dart';
import 'screens/debug_screen.dart';
import 'services/migration_service.dart';
import 'services/database_helper.dart';

void main() async {
  print('=== Todo App Starting ===');

  try {
    // Avoid errors caused by flutter upgrade.
    WidgetsFlutterBinding.ensureInitialized();
    print('Flutter binding initialized');

    // Initialize database factory for web and desktop
    DatabaseHelper.initialize();
    print('Database factory initialized');

    // Migrate existing data from SharedPreferences to SQLite if needed
    print('Starting migration check...');
    await MigrationService.migrateDataIfNeeded();
    print('Migration check completed');

    print('Starting Flutter app...');
    runApp(const MyApp());
  } catch (e, stackTrace) {
    print('Error during app initialization: $e');
    print('Stack trace: $stackTrace');

    // Run app anyway with minimal setup
    runApp(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Initialization Error: $e'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    runApp(const MyApp());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
      home: const AppSelector(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppSelector extends StatelessWidget {
  const AppSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Choose an option:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text('Go to Todo List'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DebugScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.bug_report),
                label: const Text('Debug Database'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

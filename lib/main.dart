import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'config/firebase_config.dart';
import 'services/app_initialization_service.dart';
import 'views/widgets/offline_banner.dart';
import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize error tracking with Sentry
  await SentryFlutter.init(
    (options) {
      // Replace with your actual Sentry DSN
      options.dsn = 'https://YOUR_SENTRY_DSN@sentry.io/YOUR_PROJECT_ID';
      options.tracesSampleRate = 1.0;
      options.environment = const String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
    },
    appRunner: () => _runApp(),
  );
}

void _runApp() async {
  try {
    // Initialize Firebase
    developer.log('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Firebase Crashlytics
    developer.log('Initializing Firebase Crashlytics...');
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    
    // Pass all uncaught platform errors to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    // Initialize all services
    developer.log('Initializing app services...');
    final initService = AppInitializationService();
    await initService.initializeAllServices();

    developer.log('✅ App initialization complete');
  } catch (e, stackTrace) {
    developer.log('❌ App initialization error: $e',
        error: e, stackTrace: stackTrace);
    
    // Record to both Sentry and Firebase Crashlytics
    await FirebaseCrashlytics.instance.recordError(e, stackTrace);
    await Sentry.captureException(e, stackTrace: stackTrace);
    
    rethrow;
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'LingoQuest',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const MyHomePage(title: 'LingoQuest'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          // Offline banner at top
          const OfflineBanner(),
          
          // Main content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('You have pushed the button this many times:'),
                  Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Welcome to LingoQuest!'),
                        ),
                      );
                    },
                    child: const Text('Test'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

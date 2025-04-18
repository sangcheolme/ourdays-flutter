import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'constants/index.dart';
import 'models/index.dart';
import 'services/index.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/couple_connection_screen.dart';
import 'screens/main/home_screen.dart';
import 'screens/main/calendar_screen.dart';
import 'screens/main/memories_screen.dart';
import 'screens/main/settings_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/couple_provider.dart';
import 'providers/date_record_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // // Initialize Firebase
  // await Firebase.initializeApp();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize services
    final secureStorage = const FlutterSecureStorage();
    final apiClient = ApiClient();
    final authService = AuthService(apiClient);
    final userService = UserService(apiClient);
    final coupleService = CoupleService(apiClient);
    final dateRecordService = DateRecordService(apiClient);

    return MultiProvider(
      providers: [
        // Service providers
        Provider<ApiClient>(create: (_) => apiClient),
        Provider<AuthService>(create: (_) => authService),
        Provider<UserService>(create: (_) => userService),
        Provider<CoupleService>(create: (_) => coupleService),
        Provider<DateRecordService>(create: (_) => dateRecordService),
        Provider<PlaceService>(create: (_) => PlaceService(apiClient)),
        Provider<MediaService>(create: (_) => MediaService(apiClient)),
        Provider<CommentService>(create: (_) => CommentService(apiClient)),
        Provider<SpecialDateService>(create: (_) => SpecialDateService(apiClient)),
        Provider<StatisticsService>(create: (_) => StatisticsService(apiClient)),

        // State providers
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authService, secureStorage),
        ),
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (_) => UserProvider(userService),
          update: (_, authProvider, previous) => 
            previous!..update(authProvider.isAuthenticated, authProvider.token),
        ),
        ChangeNotifierProxyProvider<AuthProvider, CoupleProvider>(
          create: (_) => CoupleProvider(coupleService),
          update: (_, authProvider, previous) => 
            previous!..update(authProvider.isAuthenticated, authProvider.token),
        ),
        ChangeNotifierProxyProvider<AuthProvider, DateRecordProvider>(
          create: (_) => DateRecordProvider(dateRecordService),
          update: (_, authProvider, previous) => 
            previous!..update(authProvider.isAuthenticated, authProvider.token),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ko', 'KR'), // Korean
          Locale('en', 'US'), // English
        ],
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/couple-connection': (context) => const CoupleConnectionScreen(),
          '/home': (context) => const HomeScreen(),
          '/calendar': (context) => const CalendarScreen(),
          '/memories': (context) => const MemoriesScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}

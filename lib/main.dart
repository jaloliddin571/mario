import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'providers/language_provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/language_screen.dart';
import 'screens/admin/admin_home.dart';
import 'screens/worker/worker_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  await NotificationService.initialize();

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      title: 'Mario Smena',
      debugShowCheckedModeBanner: false,
      locale: langProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LanguageProvider.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC0392B),
        ),
        useMaterial3: true,
      ),
      home: const AppWrapper(),
    );
  }
}

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final lang = Provider.of<LanguageProvider>(context);

    // LanguageProvider hali yuklanmagan bo‘lsa
    if (!lang.isLoaded) {
      return const Scaffold(
        backgroundColor: Color(0xFFC0392B),
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        ),
      );
    }

    // Til hali tanlanmagan bo‘lsa
    if (lang.isFirstTime) {
      return const LanguageScreen();
    }

    // Auth hali yuklanayotgan bo‘lsa
    if (auth.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFC0392B),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'MARIO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 6,
                ),
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      );
    }

    // Login qilinmagan bo‘lsa
    if (auth.user == null) {
      return const LoginScreen();
    }

    // Role bo‘yicha yo‘naltirish
    if (auth.role == 'admin') {
      return const AdminHome();
    }

    return const WorkerHome();
  }
}
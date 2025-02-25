import 'package:face_recognition/providers/user_provider.dart';
import 'package:face_recognition/ui/pages/class_page.dart';
import 'package:face_recognition/ui/pages/dashboard_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

import 'package:face_recognition/ui/pages/Auth/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Error loading .env file: $e");
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) {
          var userProvider = UserProvider();
          userProvider.fetchCurrentUserData(); // Ensure this runs on startup
          return userProvider;
        }),
      ],
      child: const MyApp(),
    ),
  );
}
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/classPage': (context) => const ClassPage(),
        '/dashboard': (context) => const DashboardPage(),
      },
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: const LoginPage(),
    );
  }
}

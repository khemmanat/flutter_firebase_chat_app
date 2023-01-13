import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_app/core/constants/color.dart';
import 'package:flutter_firebase_chat_app/core/helpers/helper_function.dart';
import 'package:flutter_firebase_chat_app/features/auth/login_page.dart';
import 'package:flutter_firebase_chat_app/features/home/home_page.dart';
import 'package:flutter_firebase_chat_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isUserLoggedIn = false;

  @override
  void initState() {
    super.initState();
    getUserLoggedInStatus();
  }

  getUserLoggedInStatus() async {
    await HelperFunction.getUserLoggedInStatus().then((value) {
      if (value != null) {
        setState(() {
          _isUserLoggedIn = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: ThemeColor.primaryMaterialColor,
        primaryColor: ThemeColor.primaryColor,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: _isUserLoggedIn ? const HomePage() : LoginPage(),
    );
  }
}

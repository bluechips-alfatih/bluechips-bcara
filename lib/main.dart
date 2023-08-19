import 'package:b_cara/providers/user_provider.dart';
import 'package:b_cara/resources/auth_methods.dart';
import 'package:b_cara/resources/chat_methods.dart';
import 'package:b_cara/responsive/mobile_screen_layout.dart';
import 'package:b_cara/responsive/responsive_layout.dart';
import 'package:b_cara/responsive/web_screen_layout.dart';
import 'package:b_cara/screens/login_screen.dart';
import 'package:b_cara/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialise app based on platform- web or mobile
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyC3Ymv_Z_8H3T4kGw0S9bmEvbXGOV0a2YE",
        projectId: "b-cara-70eca",
        storageBucket: "b-cara-70eca.appspot.com",
        messagingSenderId: "562011403710",
        appId: "1:562011403710:web:256742b715631840f5b5ef",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  if (firebaseAuth.currentUser != null) {
    AuthMethods().setUserState(true);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Instagram Clone',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: mobileBackgroundColor,
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              // Checking if the snapshot has any data or not
              if (snapshot.hasData) {
                // if snapshot has data which means user is logged in then we check the width of screen and accordingly display the screen layout
                return const ResponsiveLayout(
                  mobileScreenLayout: MobileScreenLayout(),
                  webScreenLayout: WebScreenLayout(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('${snapshot.error}'),
                );
              }
            }

            // means connection to future hasnt been made yet
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return const LoginScreen();
          },
        ),
      ),
    );
  }
}

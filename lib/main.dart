import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:borrowbreeze/services/auth.dart';
import 'package:borrowbreeze/wrapper.dart';
import 'package:borrowbreeze/screens/loan_view.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyDWk_LXD-hrOpo0hnyhhKaj7Xuw91sWkGA",
          appId: "1:36578099640:web:19883730ede1eef1730f4d",
          messagingSenderId: "G-YGFGMSSQPY",
          projectId: "borrowbreeze",
          storageBucket: "gs://borrowbreeze.appspot.com"));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return StreamProvider.value(
      value: AuthService().authStateChanges,
      initialData: null,
      child: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return MaterialApp(
              initialRoute: '/',
              routes: {
                '/': (context) => Wrapper(),
                '/loans': (context) => LoanView(),
              },
            );
          } else if (snapshot.hasError) {
            return Text("Error in main.dart: ${snapshot.error}");
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}

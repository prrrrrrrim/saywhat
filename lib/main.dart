import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:saywhat_app/pages/cover.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
//import 'package:saywhat_app/pages/auth_page.dart';
// openapi key: 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
void main() async { //Add async to ensure firebase is intialize
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: FirebaseOptions( apiKey: "AIzaSyDmUZ8KnKaugo8ao7fOwgy5G_L8aIXm53Y",
  authDomain: "saywhat1111.firebaseapp.com",
  databaseURL: "https://saywhat1111-default-rtdb.asia-southeast1.firebasedatabase.app",
  projectId: "saywhat1111",
  storageBucket: "saywhat1111.firebasestorage.app",
  messagingSenderId: "949354399842",
  appId: "1:949354399842:web:c85af4b6f751e81e7ba93b")
  ); //end
  runApp( StreamProvider<User?>.value(
      value: FirebaseAuth.instance.authStateChanges(), //FirebaseAuth.instance.signOut(), for log out
      initialData: null,
      child: const MyApp(),
    ),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'SayWhat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CoverPage(), // set CoverPage as initial
      
    );
  }
}

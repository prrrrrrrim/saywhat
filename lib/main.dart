import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:saywhat_app/pages/cover.dart';

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
  runApp(const MyApp());
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

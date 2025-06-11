import 'package:coolapp/pages/intro_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async{

   WidgetsFlutterBinding.ensureInitialized();

if(kIsWeb){
  await Firebase.initializeApp(options: FirebaseOptions(apiKey: "AIzaSyAZEzsTQCiFfO71D306RSwMJ6G8pynE7tM",
  authDomain: "fire-setup-70f1c.firebaseapp.com",
  projectId: "fire-setup-70f1c",
  storageBucket: "fire-setup-70f1c.firebasestorage.app",
  messagingSenderId: "91702637694",
  appId: "1:91702637694:web:0d087748363b2e0c0c142f"));
  }else{
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}




class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: IntroPage(),
      theme: ThemeData(scaffoldBackgroundColor: Color(0xFFFAF3E0)),
    );
  }
}

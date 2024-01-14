import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:login/screens/admin_home_screen.dart';
import 'package:login/screens/home_screen.dart';
import 'package:login/screens/signin_screen.dart';

class CheckLoggedIn extends StatefulWidget {
  const CheckLoggedIn({Key? key});

  @override
  State<CheckLoggedIn> createState() => _CheckLoggedInState();
}

class _CheckLoggedInState extends State<CheckLoggedIn> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final Box<dynamic> hiveBox = await Hive.openBox('authBox');
      final bool isLoggedIn = hiveBox.get('isLoggedIn') ?? false;
      
      if (isLoggedIn) {
        
        try{
          final Box<dynamic> credentials = await Hive.openBox('credentials');
          String emailId = await credentials.get('email');
          await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailId,
          password: await credentials.get('password'),
          );
        final DocumentSnapshot userSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(emailId).get();
        final String role = userSnapshot['role'];

        if (role == "student") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminHomeScreen(),
            ),
          );
        }

        }
        catch (e) {
    
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ),
          );
        }

      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignInScreen(),
          ),
        );
      }
    } catch (e) {
      print('Error checking authentication status: $e');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignInScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: Colors.white,
          size: 50,
        ),
      ),
    );
  }
}

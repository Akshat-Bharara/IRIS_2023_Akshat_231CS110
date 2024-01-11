import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:login/reusable_widgets/reusable_widget.dart';
import 'package:login/screens/admin_home_screen.dart';
import 'package:login/screens/home_screen.dart';
import 'package:login/utils/color_utils.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {


  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: 
      
      Container(
        decoration: BoxDecoration(gradient: LinearGradient(
        colors: [
        hexStringToColor("CB2B93"),
        hexStringToColor("9546C4"),
        hexStringToColor("5E61F4")
        ],begin: Alignment.topCenter, end: Alignment.bottomCenter
      )),
      
      child: SingleChildScrollView(
        child:Padding(padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.2, 20, 0),
        child: Column(
          children: <Widget> [

            SizedBox(
              height: 30,
            ),
            reusableTextField("Enter Email: ", Icons.person_outline, false, _emailTextController),
            SizedBox(
              height: 30,
            ),
            reusableTextField("Enter Password: ", Icons.lock_outline, true, _passwordTextController),

            SizedBox(
              height: 30,
            ),

            
            signInSignUpButton(context, true, () async {
              try {
                await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: _emailTextController.text,
                  password: _passwordTextController.text,
                  );

              var db = FirebaseFirestore.instance;

              QuerySnapshot<Map<String, dynamic>> querySnapshot = await db
                  .collection('users')
                  .where('email', isEqualTo: _emailTextController.text)
                  .get();

              if (querySnapshot.docs.isNotEmpty) {
                var user = querySnapshot.docs.first.data();

                final Box<dynamic> hiveBox = await Hive.openBox('authBox');
                await hiveBox.put('isLoggedIn', true);

                final Box<dynamic> Credentials = await Hive.openBox('credentials');
                await Credentials.put('email', _emailTextController.text);
                await Credentials.put('password', _passwordTextController.text);

                if (user["role"] == "admin") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminHomeScreen()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                }
              } else {
                print('No user found for that email.');
              }
            } on FirebaseAuthException {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Invalid credentials, Try again'),
                  ),
                );
              
            }
    }),


            

            const SizedBox(
                  height: 415,
                ),

            

            

          ],
        )
        
        )
      ),
      
      
      
      )
    );


  }

}
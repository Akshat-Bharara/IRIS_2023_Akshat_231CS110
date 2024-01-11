import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login/reusable_widgets/reusable_widget.dart';
import 'package:login/screens/admin_home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _nameTextController = TextEditingController();
  TextEditingController _rollnoTextController = TextEditingController();
  var selectedOption="student";

 

  @override
  Widget build(BuildContext context) {



    return Scaffold(extendBodyBehindAppBar: true, appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text("Sign Up", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ),

    body: Container(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 120, 20,0),
            child: Column(
              children: <Widget> [

                

                const SizedBox(
                  height: 20,
                ),

                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter Email ID", Icons.person_outline, false, _emailTextController),

                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter full name", Icons.person_outline, false, _nameTextController),

                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter Password", Icons.lock_outline, true, _passwordTextController),

                
                
               

                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter Roll no", Icons.numbers, false, _rollnoTextController),

                 Column(
                  children: <Widget> [
                    ListTile(
                      title: const Text("Student"),
                      leading: Radio(
                        value: "student", 
                        groupValue: selectedOption, 
                        onChanged: (value) {
                          setState(() {
                            selectedOption = value!;
                          });
                        })),
                     ListTile(
                      title: const Text("Admin"),
                      leading: Radio(
                        value: "admin", 
                        groupValue: selectedOption, 
                        onChanged: (value) {
                          setState(() {
                            selectedOption = value!;
                          });
                        })), 
                    
                  ],
                ),



                signInSignUpButton(context, false, () async {
                  if (_emailTextController.text.isEmpty ||
                      _nameTextController.text.isEmpty ||
                      _passwordTextController.text.isEmpty ||
                      _rollnoTextController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please fill in all the required fields.'),
                      ),
                    );
                    return;
                  }

                  try {
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: _emailTextController.text,
                        password: _passwordTextController.text);

                    var db = FirebaseFirestore.instance;

                    final data = {
                      "name": _nameTextController.text,
                      "email": _emailTextController.text,
                      "role": selectedOption,
                      "rollno": _rollnoTextController.text,
                      "mess balance": "0",
                      "mess": "Not Allotted",
                      "mess change": "Not initiated"
                    };

                    db.collection("users").doc(_emailTextController.text).set(data);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Account created successfully.'),
                      ),
                    );

                    if (selectedOption == "student") {
                      final data = {
                        "date1": "null",
                      };
                      db.collection("leaves").doc(_emailTextController.text).set(data);

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: ((context) => AdminHomeScreen())),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: ((context) => const AdminHomeScreen())),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error during sign-up. Please try again.'),
                      ),
                    );
                  }
                }

                ),

                

              ]
            ),
          ),
        ),
    ),

    );

    
  }


   
}


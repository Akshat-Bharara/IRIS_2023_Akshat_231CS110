import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login/screens/manage_mess.dart';
import 'package:login/screens/manage_mess_allocation.dart';
import 'package:login/screens/mess_change_requests.dart';
import 'package:login/screens/mess_costs.dart';
import 'package:login/screens/signin_screen.dart';
import 'package:login/screens/signup_screen.dart';
import 'package:login/screens/view_feedback.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(
              children: <Widget>[

                Text(
                  "Admin Page",
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                    ),
                
                
                SizedBox(
                  height: 30,
                ),

                createMessButton(),
                
                SizedBox(
                  height: 20,
                ),
                messChangeRequestsButton(),
                SizedBox(
                  height: 20,
                ),
                allocateDeallocateUsersButton(),

                SizedBox(
                  height: 30,
                ),
                signUpOption(),

                SizedBox(
                  height: 30,
                ),
                MessCost(),

                SizedBox(
                  height: 30,
                ),
                Feedback(),

                SizedBox(
                  height: 30,
                ),
                Logout(),

                SizedBox(
                  height: 200,
                )
                
              ],
            ),
          ),
        ),
      ),
    );
  }

  ElevatedButton createMessButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context,MaterialPageRoute(builder: (context) => ManageMess()));
      },
      child: Text("Manage Messes"),
    );
  }

  

  ElevatedButton messChangeRequestsButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context,MaterialPageRoute(builder: (context) => MessChangeRequests()));
      },
      child: Text("Mess Change Requests"),
    );
  }

  ElevatedButton allocateDeallocateUsersButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context,MaterialPageRoute(builder: (context) => ManageMessAllocation()));
      },
      child: Text("Allocate/Deallocate Users"),
    );
  }

  ElevatedButton signUpOption() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SignUpScreen()));
      },
      child: Text("Create new account"),
    );
  }

  ElevatedButton MessCost() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MessCosts()));
      },
      child: Text("Update mess costs"),
    );
  }

  ElevatedButton Feedback() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ViewFeedback()));
      },
      child: Text("Feedback"),
    );
  }


  Center Logout() {
    return Center(
      child: ElevatedButton(
        child: Text("Logout"),
        onPressed: () {
          FirebaseAuth.instance.signOut().then((value) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SignInScreen()));
          });
        },
      ),
    );
  }
}

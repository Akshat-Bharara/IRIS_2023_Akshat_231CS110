import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart'; 
import 'package:login/screens/add_mess_balance.dart';
import 'package:login/screens/apply_leave.dart';
import 'package:login/screens/change_mess.dart';
import 'package:login/screens/mess_registration.dart';
import 'package:login/screens/signin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScrollController scrollController = ScrollController();
  var currentUser = FirebaseAuth.instance.currentUser;
  List<dynamic> itemsList = [];
  late Future<Box> _userHiveFuture; 

  @override
  void initState() {
    super.initState();
    _userHiveFuture = openHiveBox(); 
    getList();
  }

  Future<Box> openHiveBox() async {
    return await Hive.openBox('user details');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              getList();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<dynamic>>(
          future: Future.value(itemsList),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return FutureBuilder<Box>(
                // Use FutureBuilder for the Hive box
                future: _userHiveFuture,
                builder: (context, boxSnapshot) {
                  if (boxSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else {
                    final Box _userHive = boxSnapshot.data!;
                    List<dynamic> userDetails = [
                      {
                        "name": _userHive.get('Name', defaultValue: ''),
                        "email": _userHive.get('Email', defaultValue: ''),
                        "rollno": _userHive.get('Roll number', defaultValue: ''),
                      }
                    ];

                    for (int i = 0; i < itemsList.length; i++) {
                      if (itemsList[i]["email"] == currentUser!.email!) {
                        userDetails.add(itemsList[i]);
                      }
                    }

                    if (itemsList.isEmpty) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return Column(
                      children: <Widget>[
                        Container(
                          width: 350,
                          height: 50,
                          margin: EdgeInsets.all(6.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(),
                          ),
                          child: Text("Name: ${userDetails[0]["name"]}"),
                        ),
                        Container(
                          width: 350,
                          height: 50,
                          margin: EdgeInsets.all(6.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(),
                          ),
                          child: Text("Email ID: ${userDetails[0]["email"]}"),
                        ),
                        Container(
                          width: 350,
                          height: 50,
                          margin: EdgeInsets.all(6.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(),
                          ),
                          child: Text("Roll Number: ${userDetails[0]["rollno"]}"),
                        ),
                        Container(
                          width: 350,
                          height: 50,
                          margin: EdgeInsets.all(6.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(),
                          ),
                          child:
                              Text("Mess Balance: ${userDetails[1]["mess balance"]}"),
                        ),
                        Container(
                          width: 350,
                          height: 50,
                          margin: EdgeInsets.all(6.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(),
                          ),
                          child: Text("Current Mess: ${userDetails[1]["mess"]}"),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Center(
                          child: ElevatedButton(
                            child: Text("Add Mess Balance"),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddMessBalance(),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Center(
                          child: ElevatedButton(
                            child: Text("Mess Registration"),
                            onPressed: () {
                              if (userDetails[1]["mess"] == "Not Allotted") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MessRegistration(),
                                  ),
                                );
                              } else {
                                showAlertDialog(
                                    context,
                                    'Already Registered',
                                    'You are already registered in a mess');
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Center(
                          child: ElevatedButton(
                            child: Text("Change Mess"),
                            onPressed: () {
                              if (userDetails[1]["mess"] == "Not Allotted") {
                                showAlertDialog(
                                    context,
                                    "Mess is unallotted",
                                    "Register for a mess first");
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChangeMess(),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Center(
                          child: ElevatedButton(
                            child: Text("Apply Leave"),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ApplyLeave(),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Center(
                          child: ElevatedButton(
                            child: Text("Logout"),
                            onPressed: () {
                              FirebaseAuth.instance
                                  .signOut()
                                  .then((value) async {
                                final Box<dynamic> hiveBox =
                                    await Hive.openBox('authBox');
                                await hiveBox.put('isLoggedIn', false);

                                final Box hiveBoxCredentials =
                                    Hive.box('credentials');
                                await hiveBoxCredentials.deleteFromDisk();

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignInScreen(),
                                  ),
                                );
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> getList() async {
    var db = FirebaseFirestore.instance;
    List<dynamic> updatedItemsList = [];

    await db.collection('users').get().then((QuerySnapshot) {
      QuerySnapshot.docs.forEach((element) {
        updatedItemsList.add(element.data());
      });
    });

    setState(() {
      itemsList = updatedItemsList;
    });
  }
}

showAlertDialog(BuildContext context, String title, String message) {
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      okButton,
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

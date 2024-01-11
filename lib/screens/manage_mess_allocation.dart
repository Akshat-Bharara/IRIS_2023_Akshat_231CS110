import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:login/reusable_widgets/reusable_widget.dart';

class ManageMessAllocation extends StatefulWidget {
  @override
  _ManageMessAllocationState createState() => _ManageMessAllocationState();
}

class _ManageMessAllocationState extends State<ManageMessAllocation> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedMess = '';

  Future<String> getDocumentName() async {
    final QuerySnapshot querySnapshot =
        await _firestore.collection('mess').limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    } else {
      print('No documents found in the mess collection.');
      return "";
    }
  }

  Future<Null> updateUserMess(String userId, String messId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'mess': messId,
      });

      DocumentReference newMessRef =
          _firestore.collection('mess').doc(messId);
      DocumentSnapshot newMessSnapshot = await newMessRef.get();

      if ((int.parse(newMessSnapshot['seats']) -
              int.parse(newMessSnapshot['occupied seats']))
          .toString() ==
          "0") {
        showAlertDialog(
            context, "No vacancy", "All seats in this mess have been occupied");
        return null;
      }

      int newSeats = int.parse(newMessSnapshot['occupied seats']);

      await _firestore.collection('mess').doc(messId).update({
        'occupied seats': (newSeats + 1).toString(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully updated user\'s mess allocation.'),
        ),
      );
    } catch (e) {
      print('Error updating user\'s mess allocation: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Failed to update user\'s mess allocation. Please try again. $e'),
        ),
      );
    }
  }

  Future<void> removeUserMess(String userId, String messId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'mess': "Not Allotted",
      });

      DocumentReference newMessRef =
          _firestore.collection('mess').doc(messId);
      DocumentSnapshot newMessSnapshot = await newMessRef.get();
      int newSeats = int.parse(newMessSnapshot['occupied seats']);

      await _firestore.collection('mess').doc(messId).update({
        'occupied seats': (newSeats - 1).toString(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully deallocated user'),
        ),
      );
    } catch (e) {
      print('Error deallocating user');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deallocating user'),
        ),
      );
    }
  }

  @override
void initState() {
  super.initState();
  _initializeMess();
}

Future<void> _initializeMess() async {
  String messId = await getDocumentName();

  
  if (messId.isNotEmpty) {
    setState(() {
      _selectedMess = messId;
    });
  }
}

  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Allocation/Deallocation"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 15,
          ),
          Text(
            'Mess Allocation',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Select the mess: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 16.0),

          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('mess').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                List<DocumentSnapshot> messes = snapshot.data!.docs;
                return Container(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: messes.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot mess = messes[index];
                      return ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedMess = mess.id;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          primary: _selectedMess == mess.id
                              ? Color.fromARGB(255, 10, 26, 199)
                              : Colors.black,
                        ),
                        child: Text(mess['name']),
                      );
                    },
                  ),
                );
              }
            },
          ),

          SizedBox(height: 16.0),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .where('mess', isEqualTo: "Not Allotted")
                  .where('role', isEqualTo: "student")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  List<DocumentSnapshot> users = snapshot.data!.docs;

                  if (users.isEmpty) {
                    return Center(
                      child: Text('No users available to allocate mess.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot user = users[index];
                      return ListTile(
                        title: Text(user['name']),
                        subtitle: Text(user['email']),
                        trailing: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            updateUserMess(
                              user['email'],
                              _selectedMess,
                            );
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Text(
            'Mess Deallocation',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .where('mess', isNotEqualTo: "Not Allotted")
                  .where('role', isEqualTo: "student")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  List<DocumentSnapshot> users = snapshot.data!.docs;

                  if (users.isEmpty) {
                    return Center(
                      child: Text('No users available to deallocate mess.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot user = users[index];
                      return ListTile(
                        title: Text(user['name']),
                        subtitle: Text(user['email'] + "\n" + user['mess']),
                        trailing: IconButton(
                          icon: Icon(Icons.remove_circle),
                          onPressed: () {
                            removeUserMess(
                              user['email'],
                              _selectedMess,
                            );
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
     
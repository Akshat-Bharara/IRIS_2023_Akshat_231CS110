// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class ApplyLeave extends StatefulWidget {
//   const ApplyLeave({super.key});

//   @override
//   State<ApplyLeave> createState() => _ApplyLeaveState();
// }

// class _ApplyLeaveState extends State<ApplyLeave> {

//   DateTime _dateTime = DateTime.now();

//   void _showDatePicker() {
//     showDatePicker(
//       context: context, 
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(), 
//       lastDate: DateTime(2025),
//       cancelText: '',
//     ).then((value) {
//       setState(() {
//         _dateTime = value!;
//       });
//     });
//   }

//   void addDate(String date) async {

//       var db = FirebaseFirestore.instance;
//       var currentUser = FirebaseAuth.instance.currentUser;

//       final userLeaves = db.collection('leaves').doc(currentUser!.email);
//       final snapshot = await userLeaves.get();
//       var dataDates = snapshot.data();
//       List<String> dates=[];

//       dataDates!.keys.forEach((key) {
//         if(dataDates[key]!="null"){
//           dates.add(dataDates[key]);
//         }
//       });

//       for(int i=0;i<dates.length;i++){
//         if(dates[i]==date){
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Leave has already been applied on this day'),
//             ),
//           );
//           return;
//         }
//       }

//       DocumentSnapshot documentSnapshot = await db.collection("leaves").doc(currentUser.email!).get();
//       Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
//       int n = data.length;
//       n=n+1;

//       db.collection("leaves").doc(currentUser.email).update({"date$n" : date});

//       ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Leave applied successfully and has been auto-approved'),
//             ),
//           );

//     }

//     getLeaves() async {

//       final userLeaves = FirebaseFirestore.instance.collection('leaves')
//       .doc(FirebaseAuth.instance.currentUser!.email);

//       final snapshot = await userLeaves.get();
//       var data = snapshot.data();

//       List dates=[];

//       data!.keys.forEach((key) {
//         if(data[key]!="null"){
//           dates.add(data[key]);
//         }
//       });
      
//     }

//   @override
//   Widget build(BuildContext context) {

    

//     return Scaffold(

//       appBar: AppBar(
//         title: const Text("Apply Leave"),
//       ),

//       body: 
      
//       Container(

//         child:  Column(
          
//           children: <Widget> [

//             SizedBox(
//               height: 50,
//             ),

//             Center(
//               child: MaterialButton(
//                 onPressed: _showDatePicker,
//                 child: const Padding(padding: EdgeInsets.all(10.0),
//                 child: Text("Choose date",
//                 style: TextStyle(
//                   color:Colors.white,
//                   fontSize: 25,
//                 ),
//                 ),
//                 ),
//                 color: Colors.black,
//                 ),
//             ),

//             SizedBox(
//               height: 20,
//             ),

//             Text('Selected date: ',
//             style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold),),

//             SizedBox(
//               height: 20,
//             ),

//             Text(_dateTime.day.toString()+"-"+_dateTime.month.toString()+"-"+_dateTime.year.toString(),
//             style: TextStyle(fontSize: 20,color: Colors.white),),

//             SizedBox(
//               height: 20,
//             ),

//             Center(
//               child: ElevatedButton(
//                 child: Text("Apply"),
//                 onPressed: () {
//                   addDate(_dateTime.day.toString()+"-"+_dateTime.month.toString()+"-"+_dateTime.year.toString());
//                 },
//               ),
//             ),

//             SizedBox(
//               height: 20,
//             ),


            

//       ],
//         )
        
//         )
      

//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ApplyLeave extends StatefulWidget {
  const ApplyLeave({Key? key});

  @override
  State<ApplyLeave> createState() => _ApplyLeaveState();
}

class _ApplyLeaveState extends State<ApplyLeave> {
  DateTime _dateTime = DateTime.now();

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
      cancelText: '',
    ).then((value) {
      if (value != null) {
        setState(() {
          _dateTime = value;
        });
      }
    });
  }

  void addDate(String date) async {
    var db = FirebaseFirestore.instance;
    var currentUser = FirebaseAuth.instance.currentUser;

    final userLeaves = db.collection('leaves').doc(currentUser!.email);
    final snapshot = await userLeaves.get();
    var dataDates = snapshot.data();
    List<String> dates = [];

    dataDates!.keys.forEach((key) {
      if (dataDates[key] != "null") {
        dates.add(dataDates[key]);
      }
    });

    for (int i = 0; i < dates.length; i++) {
      if (dates[i] == date) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Leave has already been applied on this day'),
          ),
        );
        return;
      }
    }

    // Update leave in Firestore
    await db.collection("leaves").doc(currentUser.email).update({date: date});

    // Trigger a rebuild to update the applied leaves
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Leave applied successfully and has been auto-approved'),
      ),
    );
  }

  Stream<List<String>> getLeavesStream() {
    final userLeaves = FirebaseFirestore.instance
        .collection('leaves')
        .doc(FirebaseAuth.instance.currentUser!.email);

    return userLeaves.snapshots().map((snapshot) {
      var data = snapshot.data();

      List<String> dates = [];

      data!.keys.forEach((key) {
        if (data[key] != "null") {
          dates.add(data[key]);
        }
      });

      return dates;
    });
  }

  void deleteLeave(String date) async {
    var db = FirebaseFirestore.instance;
    var currentUser = FirebaseAuth.instance.currentUser;

    await db.collection("leaves").doc(currentUser!.email).update({date: FieldValue.delete()});

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Leave deleted successfully'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Apply Leave"),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 50,
            ),
            Center(
              child: MaterialButton(
                onPressed: _showDatePicker,
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "Choose date",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                    ),
                  ),
                ),
                color: Colors.black,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Selected date: ',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              _dateTime.day.toString() +
                  "-" +
                  _dateTime.month.toString() +
                  "-" +
                  _dateTime.year.toString(),
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: ElevatedButton(
                child: Text("Apply"),
                onPressed: () {
                  addDate(_dateTime.day.toString() +
                      "-" +
                      _dateTime.month.toString() +
                      "-" +
                      _dateTime.year.toString());
                },
              ),
            ),
            SizedBox(
              height: 40,
            ),
            StreamBuilder<List<String>>(
              stream: getLeavesStream(),
              builder: (context, AsyncSnapshot<List<String>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  List<String>? leaves = snapshot.data;

                  if (leaves == null || leaves.isEmpty) {
                    return Text('No leaves applied');
                  }

                  return Column(
                    children: [
                      Text(
                        'Leaves Applied:',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: leaves.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              leaves[index],
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete,color: Colors.red),
                              onPressed: () {
                                deleteLeave(leaves[index]);
                              }, 
                              ),
                          );
                        },
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

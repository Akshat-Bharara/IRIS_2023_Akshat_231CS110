import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ApplyLeave extends StatefulWidget {
  const ApplyLeave({super.key});

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
      setState(() {
        _dateTime = value!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    addDate(String date) async {

      var db = FirebaseFirestore.instance;
      var currentUser = FirebaseAuth.instance.currentUser;

      final userLeaves = db.collection('leaves').doc(currentUser!.email);
      final snapshot = await userLeaves.get();
      var dataDates = snapshot.data();
      List<String> dates=[];

      dataDates!.keys.forEach((key) {
        if(dataDates[key]!="null"){
          dates.add(dataDates[key]);
        }
      });

      for(int i=0;i<dates.length;i++){
        if(dates[i]==date){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Leave has already been applied on this day'),
            ),
          );
          return;
        }
      }

      DocumentSnapshot documentSnapshot = await db.collection("leaves").doc(currentUser.email!).get();
      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      int n = data.length;
      n=n+1;

      db.collection("leaves").doc(currentUser.email).update({"date$n" : date});

      ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Leave applied successfully and has been auto-approved'),
            ),
          );

    }

    return Scaffold(

      appBar: AppBar(
        title: const Text("Apply Leave"),
        //backgroundColor: hexStringToColor("CB2B93"),
      ),

      body: 
      
      Container(
      //   decoration: BoxDecoration(gradient: LinearGradient(
      //   colors: [
      //   hexStringToColor("CB2B93"),
      //   hexStringToColor("9546C4"),
      //   hexStringToColor("5E61F4")
      //   ],begin: Alignment.topCenter, end: Alignment.bottomCenter
      // )),

        child:  Column(
          
          children: <Widget> [

            SizedBox(
              height: 175,
            ),

            

            

            Center(
              child: MaterialButton(
                onPressed: _showDatePicker,
                child: const Padding(padding: EdgeInsets.all(10.0),
                child: Text("Choose date",
                style: TextStyle(
                  color:Colors.white,
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

            Text('Selected date: ',
            style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold),),

            SizedBox(
              height: 20,
            ),

            Text(_dateTime.day.toString()+"-"+_dateTime.month.toString()+"-"+_dateTime.year.toString(),
            style: TextStyle(fontSize: 20,color: Colors.white),),

            SizedBox(
              height: 20,
            ),

            Center(
              child: ElevatedButton(
                child: Text("Apply"),
                onPressed: () {
                  addDate(_dateTime.day.toString()+"-"+_dateTime.month.toString()+"-"+_dateTime.year.toString());
                },
              ),
            ),
            

      ],
        )
        
        )
      

    );
  }
}
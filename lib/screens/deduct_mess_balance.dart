import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login/screens/check_logged_in.dart';

class DeductMessBalance extends StatefulWidget {
  const DeductMessBalance({Key? key}) : super(key: key);

  @override
  State<DeductMessBalance> createState() => _DeductMessBalanceState();
}

class _DeductMessBalanceState extends State<DeductMessBalance> {
  bool isLoading = true;

  Future<void> balanceDeduction() async {

    DateTime _dateTime = DateTime.now();
    String newDate = _dateTime.day.toString()+"-"+_dateTime.month.toString()+"-"+_dateTime.year.toString();

    var db = FirebaseFirestore.instance;
    var userDocument1 = await db.collection('last deducted').doc("date").get();
    
    String oldDate = userDocument1.data()?['date'];

    if(oldDate==newDate){
      stopLoading();
    }

    DateTime date1 = DateFormat('dd-MM-yyyy').parse(oldDate);
    DateTime date2 = DateFormat('dd-MM-yyyy').parse(newDate);

    

    List<DateTime> dateList = [];
    DateTime currentDate = date1;

    while (currentDate.isBefore(date2) || currentDate.isAtSameMomentAs(date2)) {
      dateList.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    

    var userDocument2 = await db.collection('mess costs').doc("cost").get();

    int total = userDocument2.data()?['total'];

    

    CollectionReference usersCollection = db.collection('users');
    QuerySnapshot querySnapshot = await usersCollection.where('role', isEqualTo: 'student').get();

    for (QueryDocumentSnapshot document in querySnapshot.docs) {

      if(document['mess']=="Not allotted"){
        continue;
      }

      int difference = date2.difference(date1).inDays;

      final userLeaves = FirebaseFirestore.instance.collection('leaves').doc(document.id);
      final snapshot = await userLeaves.get();
      var data = snapshot.data();
      List<DateTime> dates=[];

      data!.keys.forEach((key) {
        if(data[key]!="null"){
          dates.add(DateFormat('dd-MM-yyyy').parse(data[key]));
        }
      });

      for(int i=0;i<dateList.length;i++){
        for(int j=0;j<dates.length;j++){
          if(dateList[i]==dates[j]){
            difference--;
          }
        }
      }

      int deductBalance = total*difference;
      int oldBalance = int.parse(document['mess balance']);
      int newBalance = oldBalance-deductBalance;
      db.collection("users").doc(document.id).update({"mess balance": newBalance.toString()});
    }

    db.collection("last deducted").doc("date").update({"date": newDate});

    stopLoading();
  }

  @override
  void initState() {
    super.initState();

    // Simulating an async operation (e.g., deducting mess balance)

    balanceDeduction();
    

    // After the operation is done, you can call stopLoading to stop the indicator
    Future.delayed(const Duration(seconds: 3), () {
      stopLoading();
    });
  }

  void stopLoading() {
    setState(() {
      isLoading = false;
    });
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => SignInScreen(),
    //   ),
    // );

  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckLoggedIn(),
      ),
    );

}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : const Text('Deduction completed!'),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:login/reusable_widgets/reusable_widget.dart';

class MessChangeRequests extends StatefulWidget {
  const MessChangeRequests({super.key});

  @override
  State<MessChangeRequests> createState() => _MessChangeRequestsState();
}

class _MessChangeRequestsState extends State<MessChangeRequests> {

  var db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Mess Change Requests"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection("mess requests").snapshots(),
        builder: (context,snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
                    return Center(
              child: CircularProgressIndicator(),
            );
          }
          else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          
          else {
            List<DocumentSnapshot> requests = snapshot.data!.docs;
            if (requests.isEmpty) {
              return Center(
                child: Text('No mess change requests available.'),
              );
            }
            return ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                DocumentSnapshot request = requests[index];
                return Card(
                 margin: EdgeInsets.all(8.0),
                 child: ListTile(
                    title: Text(
                      'Email: ${request['email']}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    
                    subtitle: Text(
                      'Old Mess: ${request['old mess']}'+ "\n"
                      'New Mess: ${request['new mess']}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            approveMessChange(request.id, request['old mess'].toString(), request['new mess'].toString());
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            rejectMessChange(request.id);
                          },
                        ),
                      ],
                    ),
                 ),
                );
              },
            );
          }
        },
      ),
    );
 }



  Future<Null> approveMessChange(String requestId, String oldMess, String newMess) async {

    DocumentReference oldMessRef = db.collection('mess').doc(oldMess);
    DocumentSnapshot oldMessSnapshot = await oldMessRef.get();

    if((int.parse(oldMessSnapshot['seats'])-int.parse(oldMessSnapshot['occupied seats'])).toString()=="0"){
      showAlertDialog(context, "No vacancy", "All seats in this mess have been occupied");
      return null;
    }
    
    //1. Change user mess
    db.collection("users").doc(requestId).update({"mess" : newMess});

    //2. Change status to Approved
    db.collection("users").doc(requestId).update({"mess change" : "Approved"});


    //3. Change mess seats
    
    int oldSeats = int.parse(oldMessSnapshot['occupied seats']);

    await db.collection('mess').doc(oldMess).update({
        'occupied seats': (oldSeats-1).toString(),
      });

    DocumentReference newMessRef = db.collection('mess').doc(newMess);
    DocumentSnapshot newMessSnapshot = await newMessRef.get();
    int newSeats = int.parse(newMessSnapshot['occupied seats']);

    await db.collection('mess').doc(newMess).update({
        'occupied seats': (newSeats+1).toString(),
      });

    //4. Remove request
    db.collection("mess requests").doc(requestId).delete();

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mess change request approved'),
            ),
          );

 }

 Future<void> rejectMessChange(String requestId) async {
    
    //1. Change status to Rejected
    db.collection("users").doc(requestId).update({"mess change" : "Rejected"});

    //2. Remove request
    db.collection("mess requests").doc(requestId).delete();

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mess change request rejected'),
            ),
          );


 }


}
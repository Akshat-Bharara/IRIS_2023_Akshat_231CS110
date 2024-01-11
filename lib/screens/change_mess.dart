import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login/reusable_widgets/reusable_widget.dart';

class ChangeMess extends StatefulWidget {
  @override
  _ChangeMessState createState() => _ChangeMessState();
}

class _ChangeMessState extends State<ChangeMess> {
  String status = "";
  List<Map<String, dynamic>> messChoices = [];

  Future<void> fetchMessChoices() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('mess').get();
      setState(() {
        messChoices = querySnapshot.docs.map((mess) {

          return {
            'Block': mess['blockNumber'],
            'Name': mess['name'],
            'vacancy': (int.parse(mess['seats'])-int.parse(mess['occupied seats'])).toString(),
            'total seats':mess['seats'],
            'Mess councillor':mess['messCouncillor'],
            'Contact number':mess['contactNumber'],
            'Email ID':mess['emailId'],
            'occupied seats':mess['occupied seats']
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching mess choices: $e');
    }
  }

  Future<Null> initiateRequest(String messId, String seats) async {

    if(seats=="0"){
      showAlertDialog(context, "No vacancy", "All seats in this mess have been occupied");
      return null;
    }

    var db = FirebaseFirestore.instance;
    var currentUser = FirebaseAuth.instance.currentUser;

    await db.collection('users').get().then((QuerySnapshot) {
      QuerySnapshot.docs.forEach((element) async {
        if(element.data()["email"]==currentUser!.email!){
          String currentMess = element.data()["mess"];

          if(currentMess==messId){
            showAlertDialog(context, "Same mess selected", "This is your current mess. Choose a different mess.");
          }

          else{
            final data = {
              "email":currentUser.email,
              "old mess":currentMess,
              "new mess": messId
            };

            db.collection("mess requests").doc(currentUser.email).set(data);

            await db.collection('users').doc(currentUser.email).update({
              'mess change': "In progress",
            });

            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mess change request initiated'),
            ),
          );

            // Navigate back to the home screen
            Navigator.pop(context);

          }
          
        }
      });
    });

  }

  @override
  void initState() {
    super.initState();
    fetchMessChangeValue().then((value) {
      setState(() {
        status = value;
      });
    fetchMessChoices();
    });
  }

  Future<String> fetchMessChangeValue() async {
    try {
      var db = FirebaseFirestore.instance;

      // Assuming the document ID is the user's email
      var documentId = FirebaseAuth.instance.currentUser!.email;

      var userDocument = await db.collection('users').doc(documentId).get();

      return userDocument.data()?['mess change'] ?? "";
    } catch (e) {
      print('Error fetching mess change value: $e');
      return "";
    }
  }

  void initiateNewRequest() async {
    var db = FirebaseFirestore.instance;
    var currentUser = FirebaseAuth.instance.currentUser;

    // Update the status to 'Not initiated'
    await db.collection('users').doc(currentUser!.email).update({
      'mess change': 'Not initiated',
    });

    setState(() {
      
    });
}


  @override
  Widget build(BuildContext context) {
    Color progressBarColor;
    double progressValue;
    String statusText;

    switch (status) {
      case 'Not initiated':
        progressBarColor = Colors.grey;
        progressValue = 0.0;
        statusText = 'Not Initiated';
        break;
      case 'In progress':
        progressBarColor = Colors.blue;
        progressValue = 0.5;
        statusText = 'In Progress';
        break;
      case 'Approved':
        progressBarColor = Colors.green;
        progressValue = 1.0;
        statusText = 'Approved';
        break;
      case 'Rejected':
        progressBarColor = Colors.red;
        progressValue = 1.0;
        statusText = 'Rejected';
        break;
      default:
        progressBarColor = Colors.grey;
        progressValue = 0.0;
        statusText = 'Unknown Status';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Change Mess'),
      ),
      body: Column(
        children: [
          Container(
            height: 40,
            child: Stack(
              children: [
                SizedBox(height: 50),
                LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(progressBarColor),
                ),
                Center(
                  child: Text(
                    "Current status: " + statusText,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (status == 'Not initiated') // Apply padding only if status is not initiated
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                      'Available Mess Choices',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    if (messChoices.isEmpty)
                      Text('No mess choices available.')
                    else
                      ListView.builder(
                    shrinkWrap: true,
                    itemCount: messChoices.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> mess = messChoices[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(mess['Name'] + "\t - \t Block " + mess['Block']),
                          subtitle: Text('Vacancy: ${mess['vacancy']}'
                          + "\nTotal seats : ${mess['total seats']}"
                          + "\nMess councillor : ${mess['Mess councillor']}"
                          + "\nContact number : ${mess['Contact number']}"
                          + "\nEmail ID : ${mess['Email ID']}"
                          ),
                          onTap: () {
                            // Implement registration logic here
                            initiateRequest(mess['Name'],mess['vacancy']);
                          },
                        ),
                      );
                    },
                  ),
                  
                ],
              ),
            ),


            if (status == 'In progress')
            Expanded(child: 
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("mess requests").snapshots(),
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
                              'Initiated request: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Old Mess: ${request['old mess']}'+ "\n"
                              'New Mess: ${request['new mess']}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),

            if ((status == 'Approved') || (status == "Rejected"))
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mess Change $status!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'The mess change request was $status by the admin',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        initiateNewRequest();
                        Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeMess(),
                        ),
                      );
                      },
                      child: Text('Initiate New Request'),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login/reusable_widgets/reusable_widget.dart';

class MessRegistration extends StatefulWidget {
  @override
  _MessRegistrationState createState() => _MessRegistrationState();
}

class _MessRegistrationState extends State<MessRegistration> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var currentUser = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> messChoices = [];

  @override
  void initState() {
    super.initState();
    fetchMessChoices();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mess Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Mess Choices',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            if (messChoices.isEmpty)
              Text('No mess choices available.')
            else
              Expanded(
                child: ListView.builder(
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
                          registerForMess(mess['Name'],mess['occupied seats'],mess['vacancy']);
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<Null> registerForMess(String messId, String seats,String vacancy) async {
    // Implement your logic to register the user for the selected mess

    if(vacancy=="0"){
      showAlertDialog(context, "No vacancy", "All seats in this mess have been occupied");
      return null;
    }

    // Update the 'mess' field for the user
    try {
      await _firestore.collection('users').doc(currentUser!.email).update({
        'mess': messId,
      });

      // Update the vacancy count for the selected mess

      int intSeats = int.parse(seats);
      

      await _firestore.collection('mess').doc(messId).update({
        'occupied seats': (intSeats+1).toString(),
      });

      // Show a success message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mess registration successful.'),
        ),
      );

      // Navigate back to the home screen
      Navigator.pop(context);
    } catch (e) {
      // Handle any errors that occur during the registration process
      print('Error registering for mess: $e');

      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to register for mess. Please try again.'),
        ),
      );
    }
  }
}

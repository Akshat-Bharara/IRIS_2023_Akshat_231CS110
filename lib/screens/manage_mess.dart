import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageMess extends StatefulWidget {
  @override
  _ManageMess createState() => _ManageMess();
}

class _ManageMess extends State<ManageMess> {
  final TextEditingController _messNameController = TextEditingController();
  final TextEditingController _blockNumberController = TextEditingController();
  final TextEditingController _messCouncillorController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _emailIdController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();
  String? selectedMessId;
  List<DocumentSnapshot> messList = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Fetch the mess documents when the widget initializes
    fetchMesses();
  }

  Future<void> fetchMesses() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('mess').get();
      setState(() {
        messList = querySnapshot.docs;
        // Set default selectedMessId, if any
        selectedMessId = messList.isNotEmpty ? messList.first.id : null;
      });
    } catch (e) {
      print('Error fetching messes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Messes'),
      ),
      body: SingleChildScrollView(
        child:Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Mess',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _messNameController,
              decoration: InputDecoration(
                labelText: 'Mess Name',
              ),
            ),
            TextField(
              controller: _blockNumberController,
              decoration: InputDecoration(
                labelText: 'Block Number',
              ),
            ),
            TextField(
              controller: _messCouncillorController,
              decoration: InputDecoration(
                labelText: 'Mess Councillor',
              ),
            ),
            TextField(
              controller: _contactNumberController,
              decoration: InputDecoration(
                labelText: 'Contact Number',
              ),
            ),
            TextField(
              controller: _emailIdController,
              decoration: InputDecoration(
                labelText: 'Email ID',
              ),
            ),
            TextField(
              controller: _seatsController,
              decoration: InputDecoration(
                labelText: 'Number of seats',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                createMess(
                  _messNameController.text,
                  _blockNumberController.text,
                  _messCouncillorController.text,
                  _contactNumberController.text,
                  _emailIdController.text,
                  _seatsController.text,
                );
              },
              child: Text('Create Mess'),
            ),
            SizedBox(height: 32),
            Text(
              'Delete Mess',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            // Add a dropdown or some mechanism to select the mess to delete

            DropdownButton<String>(
              value: selectedMessId,
              hint: Text('Select Mess'),
              onChanged: (String? newValue) {
                setState(() {
                  selectedMessId = newValue!;
                });
              },
              items: messList.map<DropdownMenuItem<String>>((mess) {
                return DropdownMenuItem<String>(
                  value: mess.id,
                  child: Text(mess['name']),
                );
              }).toList(),
            ),

            ElevatedButton(
              onPressed: () {
                deleteMess(selectedMessId!);
              },
              child: Text('Delete Mess'),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Future<void> createMess(
    String messName,
    String blockNumber,
    String messCouncillor,
    String contactNumber,
    String emailId,
    String seats,
  ) async {
    try {
      await _firestore.collection('mess').doc(messName).set({
        'name': messName,
        'blockNumber': blockNumber,
        'messCouncillor': messCouncillor,
        'contactNumber': contactNumber,
        'emailId': emailId,
        'seats': seats,
        'occupied seats':'0'
      });

      // Clear the text fields after creating a mess
      _messNameController.clear();
      _blockNumberController.clear();
      _messCouncillorController.clear();
      _contactNumberController.clear();
      _emailIdController.clear();
      _seatsController.clear();

      fetchMesses();

      // Show a success message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mess created successfully.'),
        ),
      );
    } catch (e) {
      // Handle any errors that occur during the createMess process
      print('Error creating mess: $e');

      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create mess. Please try again.'),
        ),
      );
    }
  }

  
  Future<void> deleteMess(String messId) async {
  
    await _firestore.collection("mess").doc(messId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mess deleted successfully.'),
      ),
    );


    final userQuery = await _firestore.collection('users').where('mess', isEqualTo: messId).get();

    for (final user in userQuery.docs) {
    await _firestore.collection('users').doc(user.id).update({'mess': 'Not Allotted'});

    }
            
  

    fetchMesses();
  } 
}

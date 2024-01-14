import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:login/screens/home_screen.dart';

class AddMessBalance extends StatefulWidget {
  const AddMessBalance({Key? key}) : super(key: key);

  @override
  State<AddMessBalance> createState() => _AddMessBalanceState();
}

class _AddMessBalanceState extends State<AddMessBalance> {
  final _formKey = GlobalKey<FormState>();
  String? _amount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Mess Balance'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Enter amount',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || value=="0") {
                    return 'Please enter some amount';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onSaved: (value) {
                  _amount = value!;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    showProcessingIndicator();

                    await addBalance(_amount!);

                    hideProcessingIndicator();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Mess balance added successfully'),
                      ),
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(),
                      ),
                    );
                  }
                },
                child: const Text('Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addBalance(String _amount) async {

    final Box<dynamic> userDetails= await Hive.openBox('user details');
    int oldBlance = int.parse(userDetails.get('mess balance'));
    int newBalance = oldBlance + int.parse(_amount);
    await userDetails.put('mess balance', newBalance.toString());
  }

  void showProcessingIndicator() {
    setState(() {
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Processing payment...',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void hideProcessingIndicator() {
    setState(() {
    });
    Navigator.of(context).pop(); 
  }
}

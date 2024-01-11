import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:login/screens/admin_home_screen.dart';

class MessCosts extends StatefulWidget {
  const MessCosts({Key? key}) : super(key: key);

  @override
  State<MessCosts> createState() => _MessCostsState();
}

class _MessCostsState extends State<MessCosts> {
  final _formKey = GlobalKey<FormState>();
  String? _breakfastCost;
  String? _lunchCost;
  String? _snacksCost;
  String? _dinnerCost;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Mess Costs'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Breakfast Cost',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the cost for breakfast';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onSaved: (value) {
                  _breakfastCost = value!;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Lunch Cost',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the cost for lunch';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onSaved: (value) {
                  _lunchCost = value!;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Snacks Cost',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the cost for snacks';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onSaved: (value) {
                  _snacksCost = value!;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Dinner Cost',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the cost for dinner';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onSaved: (value) {
                  _dinnerCost = value!;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    var db = FirebaseFirestore.instance;
                    db.collection("mess costs").doc("cost").update(
                      {
                        "breakfast": int.parse(_breakfastCost!),
                        "lunch":int.parse(_lunchCost!),
                        "snacks":int.parse(_snacksCost!),
                        "dinner":int.parse(_dinnerCost!),
                        "total":
                        int.parse(_breakfastCost!)+int.parse(_lunchCost!)
                        +int.parse(_snacksCost!)+int.parse(_dinnerCost!)
                      }
                      );

                    ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Mess costs updated successfully'),
                    ));
                    
                    Navigator.push(context,MaterialPageRoute(builder: (context) => AdminHomeScreen()));

                  }
                },
                child: const Text('Update'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

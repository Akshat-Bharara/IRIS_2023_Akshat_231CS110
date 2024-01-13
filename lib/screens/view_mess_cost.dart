import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewMessCost extends StatefulWidget {
  const ViewMessCost({Key? key}) : super(key: key);

  @override
  State<ViewMessCost> createState() => _ViewMessCostState();
}

class _ViewMessCostState extends State<ViewMessCost> {
  late DocumentReference<Map<String, dynamic>> messCostDocument;

  @override
  void initState() {
    super.initState();
    messCostDocument = FirebaseFirestore.instance.collection('mess costs').doc('cost');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mess Cost per day'),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: messCostDocument.get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var data = snapshot.data!.data()!;
          List<Widget> costWidgets = [
            _buildCostCard("Breakfast", data['breakfast'],Icon(Icons.breakfast_dining_outlined)), 
            _buildCostCard("Lunch", data['lunch'],Icon(Icons.lunch_dining)),
            _buildCostCard("Dinner", data['dinner'],Icon(Icons.restaurant)),
            _buildCostCard("Snacks", data['snacks'],Icon(Icons.dinner_dining)),
            _buildCostCard("Total", data['total'],Icon(Icons.numbers)),
          ];

          return ListView(
            children: costWidgets,
          );
        },
      ),
    );
  }

  Widget _buildCostCard(String meal, int cost, Icon icon) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(10),
      child: ListTile(
        leading: icon,
        title: Text(meal),
        subtitle: Text('Cost: \ $cost'),
      ),
    );
  }
}

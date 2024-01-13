import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewFeedback extends StatefulWidget {
  const ViewFeedback({Key? key}) : super(key: key);

  @override
  State<ViewFeedback> createState() => _ViewFeedbackState();
}

class _ViewFeedbackState extends State<ViewFeedback> {
  late Stream<List<FeedbackData>> _feedbackStream;

  @override
  void initState() {
    super.initState();
    _feedbackStream = _getFeedbackStream();
  }

  Stream<List<FeedbackData>> _getFeedbackStream() {
    return FirebaseFirestore.instance
        .collection('feedback')
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return FeedbackData.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Feedbacks'),
      ),
      body: StreamBuilder<List<FeedbackData>>(
        stream: _feedbackStream,
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

          List<FeedbackData>? feedbackList = snapshot.data;

          if (feedbackList == null || feedbackList.isEmpty) {
            return Center(
              child: Text('No feedbacks available.'),
            );
          }

          return ListView.builder(
            itemCount: feedbackList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Email: ${feedbackList[index].userId}'),
                subtitle: Text('Feedback: ${feedbackList[index].feedbackText}'),
              );
            },
          );
        },
      ),
    );
  }
}

class FeedbackData {
  final String userId;
  final String feedbackText;

  FeedbackData({required this.userId, required this.feedbackText});

  factory FeedbackData.fromMap(Map<String, dynamic> map) {
    return FeedbackData(
      userId: map['user_id'] ?? '',
      feedbackText: map['feedback_text'] ?? '',
    );
  }
}

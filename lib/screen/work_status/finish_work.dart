import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FinishWorkPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finish Works'),
      ),
      body: WorkList(status: 'Finish'),
    );
  }
}

class WorkList extends StatelessWidget {
  final String status;

  WorkList({required this.status});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('works').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('No works available.');
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var workData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            String workID = snapshot.data!.docs[index].id;

            // Filter works by status
            if (workData['Status'] == status) {
              return ListTile(
                title: Text('Work ID: ${workData['workID']}'),
                subtitle: Text('Date: ${workData['date']}'),
                onTap: () {
                  // Handle onTap
                },
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    // Handle edit
                  },
                ),
              );
            } else {
              return SizedBox(); // Return an empty SizedBox if the status doesn't match
            }
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namyong_demo/model/Work.dart';
import 'package:namyong_demo/screen/AllWork.dart';
import 'package:namyong_demo/screen/EditWork.dart';
import 'package:namyong_demo/screen/Timeline.dart';

class OnProgressWorkPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 202, 228, 255),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: 100,
        title: const Text(
          "Cancelled Work",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(224, 14, 94, 253),
                Color.fromARGB(255, 4, 6, 126),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
      ),
      body: WorkList(status: 'Assigned'),
    );
  }
}

class CancelWorkList extends StatelessWidget {
  final String status;

  CancelWorkList({required this.status});

  final Map<String, Color> statusColors = {
    'NoStatus': Colors.grey,
    'Assigned': Colors.yellow,
    'Cancel': Colors.red,
    'Complete': Colors.green,
  };

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
          return Text('No cancelled works available.');
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var workData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            String workID = snapshot.data!.docs[index].id;

            Work work = Work.fromMap(workData);
            String lastStatus = work.statuses.isNotEmpty ? work.statuses.last : 'Assigned';

            if (status == 'Assigned' && lastStatus == 'Assigned') {
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                elevation: 4.0,
                child: ListTile(
                  tileColor: Colors.white,
                  title: Text('Work ID: ${work.workID}'),
                  subtitle: Text('Date: ${work.date}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TimelinePage(workID: work.workID),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColors[lastStatus],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditWorkPage(workID: workID),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirm Delete'),
                                content: Text('Are you sure you want to delete this work?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      deleteWork(workID);
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const SizedBox();
            }
          },
        );
      },
    );
  }

  Future<void> deleteWork(String workID) async {
    try {
      await FirebaseFirestore.instance.collection('works').doc(workID).delete();
      print('Document successfully deleted: $workID');
    } catch (e) {
      print('Error deleting document: $e');
    }
  }
}

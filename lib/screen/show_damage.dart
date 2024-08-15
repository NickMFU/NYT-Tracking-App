import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShowDamagePage extends StatefulWidget {
  final String workID;

  const ShowDamagePage({Key? key, required this.workID}) : super(key: key);

  @override
  _ShowDamagePageState createState() => _ShowDamagePageState();
}

class _ShowDamagePageState extends State<ShowDamagePage> {
  Future<void> _deleteDamageRecord(String docID) async {
    try {
      await FirebaseFirestore.instance
          .collection('works')
          .doc(widget.workID)
          .collection('Damage')
          .doc(docID)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Damage record deleted successfully')),
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete record: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: 100,
        title: const Text(
          "Damage Information",
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
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('works')
            .doc(widget.workID)
            .collection('Damage')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No damage records available'));
          }

          // Extract damage records
          List<QueryDocumentSnapshot> damageRecords = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: damageRecords.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> damageData =
                  damageRecords[index].data() as Map<String, dynamic>;

              // Extract image URLs
              List<String> imageUrls =
                  List<String>.from(damageData['imageUrls'] ?? []);

              return Card(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display VIN and description
                      ListTile(
                        title: Text('VIN: ${damageData['vin']}'),
                        subtitle: Text('Description: ${damageData['description']}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteDamageRecord(damageRecords[index].id);
                          },
                        ),
                      ),
                      // Display images
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: imageUrls.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.network(imageUrls[index]),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

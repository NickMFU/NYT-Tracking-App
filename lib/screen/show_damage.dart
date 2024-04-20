import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ShowDamagePage extends StatefulWidget {
  final String workID;

  const ShowDamagePage({Key? key, required this.workID}) : super(key: key);

  @override
  _ShowDamagePageState createState() => _ShowDamagePageState();
}

class _ShowDamagePageState extends State<ShowDamagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: 100,
        title: const Text(
          "Damage information",
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
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('works')
            .doc(widget.workID)
            .collection('Damage')
            .doc(widget.workID) // Replace 'damageID' with the actual ID of the damage record
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return Center(child: Text('No damage record available'));
          }

          // Extract damage data
          Map<String, dynamic> damageData =
              snapshot.data!.data() as Map<String, dynamic>;

          // Extract image URLs
          List<String> imageUrls =
              List<String>.from(damageData['imageUrls'] ?? []);

          return ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              // Display VIN and description
              ListTile(
                title: Text('VIN: ${damageData['vin']}'),
                subtitle: Text('Description: ${damageData['description']}'),
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
          );
        },
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _wasteLevelController = TextEditingController();

  Future<List<DocumentSnapshot>> _fetchData() async {
    try {
      final querySnapshot = await _firestore.collection('waste_levels').get();
      return querySnapshot.docs;
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching data: $e");
      }
      return [];
    }
  }

  // Create new data in Firestore
  Future<void> _createData(String level) async {
    try {
      final collectionRef = _firestore.collection('waste_levels');
      final docRef = await collectionRef.add({
        'waste_level': level,
        'timestamp': DateTime.now().toIso8601String(),
      });
      Fluttertoast.showToast(msg: 'Data created with ID: ${docRef.id}');
      _refreshData(); // Refresh data after creation
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error creating data');
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  // Update existing data in Firestore
  Future<void> _updateData(String id, String level) async {
    try {
      await _firestore.collection('waste_levels').doc(id).update({
        'waste_level': level,
        'timestamp': DateTime.now().toIso8601String(),
      });
      Fluttertoast.showToast(msg: 'Data updated successfully');
      _refreshData(); // Refresh data after update
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error updating data');
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  // Delete data from Firestore
  Future<void> _deleteData(String id) async {
    try {
      await _firestore.collection('waste_levels').doc(id).delete();
      Fluttertoast.showToast(msg: 'Data deleted successfully');
      _refreshData(); // Refresh data after deletion
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error deleting data');
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  // Function to refresh the data after CRUD operations
  void _refreshData() {
    setState(() {
      //nothing to update here
    });
  }

  Future<void> _showDialog(String action, String? id) async {
    if (action == 'Edit' && id != null) {
      final docSnapshot = await _firestore.collection('waste_levels').doc(id).get();
      _wasteLevelController.text = docSnapshot['waste_level'];
    } else {
      _wasteLevelController.clear();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(action == 'Create' ? 'Add Waste Level' : 'Edit Waste Level'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _wasteLevelController,
                decoration: InputDecoration(labelText: 'Waste Level'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(action == 'Create' ? 'Add' : 'Update'),
              onPressed: () {
                if (_wasteLevelController.text.isNotEmpty) {
                  if (action == 'Create') {
                    _createData(_wasteLevelController.text);
                  } else if (action == 'Edit' && id != null) {
                    _updateData(id, _wasteLevelController.text);
                  }
                  Navigator.of(context).pop();
                } else {
                  Fluttertoast.showToast(msg: 'Please enter a valid waste level');
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available.'));
          }

          final docs = snapshot.data!;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text('Waste Level: ${data['waste_level']}'),
                  subtitle: Text('ID: ${data.id}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showDialog('Edit', data.id);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteData(data.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDialog('Create', null);
        },
        backgroundColor: Colors.teal,
        child: Icon(Icons.add),
      ),
    );
  }
}

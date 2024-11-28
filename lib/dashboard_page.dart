import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  final String channelID = '2475502'; // Replace with your ThingSpeak channel ID
  final String readAPIKey = '7Y5IOLO3GCAE1E8K'; // Replace with your ThingSpeak Read API Key
  String wasteLevel = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchAndStoreWasteLevel();
  }

  // Fetch the waste level data from ThingSpeak
  Future<void> _fetchAndStoreWasteLevel() async {
    final url =
        'https://api.thingspeak.com/channels/$channelID/fields/1.json?api_key=$readAPIKey&results=1';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['feeds'] != null && data['feeds'].isNotEmpty) {
          final level = data['feeds'][0]['field1'] ?? 'No data';
          setState(() {
            wasteLevel = level != 'No data' ? '$level%' : 'No data';
          });
        } else {
          setState(() {
            wasteLevel = 'No data available';
          });
        }
      } else {
        setState(() {
          wasteLevel = 'Error fetching data';
        });
      }
    } catch (e) {
      setState(() {
        wasteLevel = 'Failed to connect';
      });
    }
  }

  // Store the fetched waste level in Firestore
  Future<void> _storeWasteLevelInFirestore(String level) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final collectionRef = firestore.collection('waste_levels');

      // Fetch the latest document to determine the next number
      final querySnapshot = await collectionRef.orderBy('id', descending: true).limit(1).get();
      int nextId = 1; // Default to 1 if no documents exist

      if (querySnapshot.docs.isNotEmpty) {
        final lastDoc = querySnapshot.docs.first;
        nextId = (lastDoc['id'] as int) + 1; // Increment the last ID
      }

      // Remove the percent symbol before storing in Firestore
      final numericLevel = level.replaceAll('%', '');

      // Add the new document with the calculated ID
      await collectionRef.doc(nextId.toString()).set({
        'id': nextId,
        'waste_level': '$numericLevel%', // Store it with the % symbol
        'timestamp': DateTime.now().toIso8601String(),
      });

      if (kDebugMode) {
        print("Data stored successfully with ID: $nextId");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error occurred while storing data in Firestore: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Waste Collection Bot',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Card for Waste Level Display
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      'Waste Level Collected:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      wasteLevel,
                      style: TextStyle(
                        fontSize: 36,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Buttons for Functionality
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFunctionButton(
                    icon: Icons.refresh,
                    label: 'Refresh Data',
                    color: Colors.blue,
                    onPressed: _fetchAndStoreWasteLevel, // Refresh data only
                  ),
                  _buildFunctionButton(
                    icon: Icons.cloud_upload,
                    label: 'Store Data',
                    color: Colors.orange,
                    onPressed: () {
                      if (wasteLevel != 'Loading...' &&
                          wasteLevel != 'Error fetching data' &&
                          wasteLevel != 'Failed to connect') {
                        _storeWasteLevelInFirestore(wasteLevel);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Invalid data. Cannot store waste level.'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to create a styled button
  Widget _buildFunctionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color, // Use backgroundColor instead of primary
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        padding: EdgeInsets.all(16),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.white),
          SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

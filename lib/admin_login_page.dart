import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swc_bot/admin_dashboard.dart';
import 'dashboard_page.dart'; // Import DashboardPage
import 'login_page.dart'; // Import LoginPage

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  final String adminEmail = "uday@gmail.com";

  Future<void> _signInAsAdmin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      //   email: _emailController.text,
      //   password: _passwordController.text,
      // );

      // Check if the signed-in user is an admin
      if (_emailController.text == adminEmail) {
        // Navigate to Admin Dashboard on successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboardPage()),
        );
      } else {
        // Navigate to Regular Dashboard for normal users
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message ?? 'An error occurred';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Login'),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back), // Back button
            onPressed: () {
              // Navigate back to the normal login page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/login_background.jpg'), // Background image
            fit: BoxFit.cover, // This will cover the whole screen
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                ),
                style: TextStyle(
                  color: Colors.white, // Change the text color here
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(
                  color: Colors.white, // Change the text color here
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _signInAsAdmin,
                child: Text('Sign In'),
              ),
              SizedBox(height: 20),

            ],
          ),
        ),
      ),
    );
  }
}

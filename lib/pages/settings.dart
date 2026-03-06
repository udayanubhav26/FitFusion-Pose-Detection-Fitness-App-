import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPage extends StatefulWidget {
  final String userId;
  const SettingsPage({super.key, required this.userId});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = true;
  String name = '';
  String email = '';
  String password = '';
  String imageUrl = 'assets/Images/pushup.png'; // default/fallback

  // Preset images for switching
  final List<String> _presetImages = [
    'assets/Images/pushup.png',
    'assets/Images/strech.png',
    'assets/Images/intro.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      final data = doc.data();
      if (data != null) {
        setState(() {
          name = data['name'] ?? '';
          email = data['email'] ?? '';
          password = data['password'] ?? '';
          imageUrl = data['imageUrl'] ?? _presetImages[0];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error loading user data: $e");
      setState(() => _isLoading = false);
    }
  }

  void _switchImage(String newImage) {
    setState(() {
      imageUrl = newImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 4,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // User image with black border
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.black,
                    child: CircleAvatar(
                      radius: 56,
                      backgroundImage: imageUrl.startsWith('http')
                          ? NetworkImage(imageUrl) as ImageProvider
                          : AssetImage(imageUrl),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Image selector row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _presetImages.map((img) {
                      return GestureDetector(
                        onTap: () => _switchImage(img),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: imageUrl == img ? Colors.black : Colors.grey,
                              width: 2,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 25,
                            backgroundImage: AssetImage(img),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 30),

                  // User info
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Name'),
                    subtitle: Text(name),
                  ),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Email'),
                    subtitle: Text(email),
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Password'),
                    subtitle: Text(password),
                  ),
                ],
              ),
            ),
    );
  }
}

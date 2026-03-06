import 'package:flutter/material.dart';
import 'package:ui/pages/camera.dart';
import 'favorite.dart';
import 'gallery.dart';

class PoseDetectionPage extends StatelessWidget {
  const PoseDetectionPage({super.key});

  void _showDescription(BuildContext context, String title, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Card height
    const double cardHeight = 220;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Pose Detection",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // Live Detection Card
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FavoritePage()));
                  },
                  child: Card(
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    color: Colors.white,
                    child: Container(
                      height: cardHeight,
                      padding: const EdgeInsets.all(30),
                      child: Row(
                        children: [
                          Icon(Icons.videocam, size: 60, color: Colors.deepPurple),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              "Live Detection",
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.info_outline, color: Colors.grey[700]),
                            onPressed: () => _showDescription(
                              context,
                              "Live Detection",
                              "Detect poses live using your camera.",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Row with Camera and Gallery Cards
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CameraPosePage()));
                        },
                        child: Card(
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          color: Colors.white,
                          child: Container(
                            height: cardHeight,
                            padding: const EdgeInsets.all(25),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt, size: 50, color: Colors.teal),
                                const SizedBox(height: 15),
                                Text(
                                  "Camera",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon:
                                      Icon(Icons.info_outline, color: Colors.grey[700]),
                                  onPressed: () => _showDescription(
                                    context,
                                    "Camera",
                                    "Use your camera to detect poses from a photo.",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GalleryPosePage()));
                        },
                        child: Card(
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          color: Colors.white,
                          child: Container(
                            height: cardHeight,
                            padding: const EdgeInsets.all(25),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.photo_library, size: 50, color: Colors.orange),
                                const SizedBox(height: 15),
                                Text(
                                  "Gallery",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon:
                                      Icon(Icons.info_outline, color: Colors.grey[700]),
                                  onPressed: () => _showDescription(
                                    context,
                                    "Gallery",
                                    "Select an image from your gallery for pose detection.",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabasMethod {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection("users");

  // Add new user
  Future<void> addUserInfo(String id, Map<String, dynamic> userInfoMap) async {
    await usersCollection.doc(id).set(userInfoMap);
  }

  // ✅ Fetch user by email and password
  Future<Map<String, dynamic>?> getUserByEmail(String email, String password) async {
    try {
      QuerySnapshot snapshot = await usersCollection
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data() as Map<String, dynamic>;
      } else {
        return null; // No user found
      }
    } catch (e) {
      print("Error fetching user by email: $e");
      return null;
    }
  }
}


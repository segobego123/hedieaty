import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// User Authentication - Sign Up
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Error in sign-up: $e");
      return null;
    }
  }

  /// User Authentication - Sign In
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Error in sign-in: $e");
      return null;
    }
  }

  /// Add Event to Firebase
  Future<void> addEventToFirebase(String userId, Map<String, dynamic> event) async {
    try {
      await _database.child('users/$userId/events').push().set(event);
    } catch (e) {
      print("Error in adding event to Firebase: $e");
    }
  }

  /// Sync Events from Firebase
  Future<List<Map<String, dynamic>>> syncEventsFromFirebase(String userId) async {
    try {
      final snapshot = await _database.child('users/$userId/events').get();
      if (snapshot.exists) {
        return (snapshot.value as Map).values.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error in syncing events: $e");
      return [];
    }
  }

  /// Add Gift to Firebase
  Future<void> addGiftToFirebase(String userId, String eventId, Map<String, dynamic> gift) async {
    try {
      await _database.child('users/$userId/events/$eventId/gifts').push().set(gift);
    } catch (e) {
      print("Error in adding gift to Firebase: $e");
    }
  }

  /// Update Gift Status in Firebase
  Future<void> updateGiftStatus(String userId, String eventId, String giftId, String status) async {
    try {
      await _database.child('users/$userId/events/$eventId/gifts/$giftId').update({'status': status});
    } catch (e) {
      print("Error in updating gift status: $e");
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

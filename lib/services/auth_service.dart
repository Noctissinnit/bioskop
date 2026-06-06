import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'users';

  // Get current user stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update user profile dengan nama
      await userCredential.user?.updateDisplayName(name);
      
      // Simpan user data ke Firestore dengan role 'user'
      if (userCredential.user != null) {
        await _firestore.collection(_usersCollection).doc(userCredential.user!.uid).set({
          'email': email,
          'name': name,
          'role': 'user', // Default role adalah 'user'
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  // Update user display name
  Future<void> updateDisplayName(String name) async {
    try {
      await _firebaseAuth.currentUser?.updateDisplayName(name);
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  // Password reset
  Future<void> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  // Get user role
  Future<String?> getUserRole(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(_usersCollection).doc(userId).get();
      if (doc.exists) {
        return doc['role'] as String?;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Get current user role
  Future<String?> getCurrentUserRole() async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      return await getUserRole(_firebaseAuth.currentUser!.uid);
    } catch (e) {
      rethrow;
    }
  }

  // Set user role (Admin only - untuk promote user ke admin)
  Future<void> setUserRole(String userId, String role) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        'role': role,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get all users stream
  Stream<List<Map<String, dynamic>>> getAllUsersStream() {
    return _firestore.collection(_usersCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'uid': doc.id,
          'email': doc['email'] ?? '',
          'name': doc['name'] ?? '',
          'role': doc['role'] ?? 'user',
          'createdAt': doc['createdAt'],
        };
      }).toList();
    });
  }
}

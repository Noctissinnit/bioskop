import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Get current user stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Get Roles Collection
  Future<Map<String, dynamic>?> getRolesDetails(String roleId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('roles')
          .doc(roleId)
          .get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Error fetching role: $e");
      return null;
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Ini buat insert data singup user ke firestore collection tur
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        'roleId': 'customer_id',
        'created_at': FieldValue.serverTimestamp(),
      });

      await userCredential.user?.updateDisplayName(name);

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
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
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

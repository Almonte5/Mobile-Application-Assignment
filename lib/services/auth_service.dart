import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e.code));
    } catch (_) {
      throw const AuthException('Something went wrong. Please try again.');
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final normalisedEmail = email.trim().toLowerCase();
    final isMqEmail = normalisedEmail.endsWith('@students.mq.edu.au') ||
        normalisedEmail.endsWith('@mq.edu.au');
    if (!isMqEmail) {
      throw const AuthException('Please use your MQ email address.');
    }

    late final UserCredential credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: normalisedEmail,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e.code));
    } catch (_) {
      throw const AuthException('Something went wrong. Please try again.');
    }

    final uid = credential.user!.uid;
    try {
      await _firestore.collection('users').doc(uid).set({
        'email': normalisedEmail,
        'displayName': displayName.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      await credential.user!.delete();
      throw const AuthException(
        'Could not complete signup. Please try again.',
      );
    }
  }

  Future<void> signOut() => _auth.signOut();

  String _mapAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account with that email already exists.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}

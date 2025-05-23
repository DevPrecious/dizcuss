import 'package:dizcuss/pages/auth/auth_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find<AuthController>();
  final _user = Rxn<User>();
  User? get user => _user.value;
  bool get isLoggedIn => user != null;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    _user.bindStream(_auth.authStateChanges());
    _updateOneSignalId(); // Update OneSignal ID when app starts
  }

  Future<bool> login() async {
    try {
      // Sign in with Google
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return false; // User canceled

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      // Create profile if user is new
      if (isNewUser) {
        final user = userCredential.user!;
        final deviceState = await OneSignal.User.pushSubscription;
        final playerId = deviceState.id;

        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': user.displayName,
          'username': '',
          'email': user.email,
          'photoUrl': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'oneSignalPlayerId': playerId,
        });
      } else {
        // Update OneSignal ID for existing users
        await _updateOneSignalId();
      }

      return true;
    } catch (e) {
      print('Error during login: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
      await _auth.signOut();
      Get.offAll(() => const AuthPage());
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  // Update OneSignal player ID in Firestore
  Future<void> _updateOneSignalId() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final deviceState = await OneSignal.User.pushSubscription;
      final playerId = deviceState.id;

      if (playerId != null) {
        await _firestore.collection('users').doc(currentUser.uid).update({
          'oneSignalPlayerId': playerId,
        });
        print('Updated OneSignal ID: $playerId');
      }
    } catch (e) {
      print('Error updating OneSignal ID: $e');
    }
  }
}

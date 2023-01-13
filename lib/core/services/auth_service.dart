import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_chat_app/core/helpers/helper_function.dart';
import 'package:flutter_firebase_chat_app/core/services/database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

//login
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      if (user != null) {
        return true;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

//register
  Future registerWithEmailAndPassword(
      String fullName, String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // update user data
        await DatabaseService(uid: userCredential.user!.uid)
            .savingUserData(fullName, email);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        // SnackBarDialog().showSnackBar(context,
        //     message: 'The password provided is too weak.');
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

//sign out

  Future signOut() async {
    try {
      await HelperFunction.saveUserLoggedInStatus(false);
      await HelperFunction.saveUserEmail('');
      await HelperFunction.saveUserName('');
      return _auth.signOut();
    } catch (e) {
      print(e);
    }
  }
}

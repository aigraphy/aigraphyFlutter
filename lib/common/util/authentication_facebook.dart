import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../../app/widget_support.dart';

mixin AuthenticationFacebook {
  static Future<User?> signInWithFacebook(
      {required BuildContext context}) async {
    User? user;

    final LoginResult result = await FacebookAuth.instance.login();
    final AuthCredential facebookCredential =
        FacebookAuthProvider.credential(result.accessToken!.token);
    try {
      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(facebookCredential);
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        ScaffoldMessenger.of(context).showSnackBar(
          AppWidget.customSnackBar(
            content: 'The account already exists with a different credential.',
          ),
        );
      } else if (e.code == 'invalid-credential') {
        ScaffoldMessenger.of(context).showSnackBar(
          AppWidget.customSnackBar(
            content: 'Error occurred while accessing credentials. Try again.',
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppWidget.customSnackBar(
          content: 'Error occurred using Facebook Sign-In. Try again.',
        ),
      );
    }

    return user;
  }

  static Future<void> logOut({required BuildContext context}) async {
    try {
      await FirebaseAuth.instance.signOut();
      await FacebookAuth.instance.logOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppWidget.customSnackBar(
          content: 'Error signing out. Try again.',
        ),
      );
    }
  }
}

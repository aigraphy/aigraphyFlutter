import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../constant/colors.dart';
import '../constant/styles.dart';

mixin AuthenticationGoogle {
  static Future<User> signInWithGoogle({required BuildContext context}) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn(
      /* MUST CONFIG */
      clientId: Platform.isIOS
          ? '635220140788-ji2cgb94tsf0ttb2a2845e2sr49pus6c.apps.googleusercontent.com'
          : null,
    );

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthenticationGoogle =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthenticationGoogle.accessToken,
        idToken: googleSignInAuthenticationGoogle.idToken,
      );

      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);

        user = userCredential.user!;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          BotToast.showText(
              text: 'The account already exists with a different credential.',
              textStyle: body(color: grey1100));
        } else if (e.code == 'invalid-credential') {
          BotToast.showText(
              text: 'Error occurred while accessing credentials. Try again.',
              textStyle: body(color: grey1100));
        }
      } catch (e) {
        BotToast.showText(
            text: 'Error occurred using Google Sign-In. Try again.',
            textStyle: body(color: grey1100));
      }
    }

    return user!;
  }

  static Future<void> signOut({required BuildContext context}) async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      BotToast.showText(
          text: 'Error signing out. Try again.',
          textStyle: body(color: grey1100));
    }
  }
}

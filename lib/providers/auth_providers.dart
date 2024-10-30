// ignore_for_file: body_might_complete_normally_nullable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/providers/device_token_provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:restart_app/restart_app.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges().map((user) {
    ref.read(currentUserStateProvider.notifier).state = user;

    return user;
  });
});

final currentUserStateProvider = StateProvider<User?>((ref) {
  return null;
});

Future<bool> checkUserNameExists(ref, String username) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final docSnapshot =
      await firestore.collection(DbPaths.collectionusernames).doc("list").get();

  // Check if document exists and has data
  if (!docSnapshot.exists || docSnapshot.data() == null) {
    await firestore.collection(DbPaths.collectionusernames).doc("list").set({
      "usernames": FieldValue.arrayUnion([username])
    }, SetOptions(merge: true));
    return false;
  }

  // Ensure "usernames" field exists and is an array
  final data = docSnapshot.data()!;
  if (data.containsKey('usernames') ||
      (data['usernames'] as List<String>).isNotEmpty) {
    final usernames = data['usernames'];
    if (usernames.contains(username)) {
      return true;
    }
    await firestore.collection(DbPaths.collectionusernames).doc("list").set({
      "usernames": FieldValue.arrayUnion([username])
    }, SetOptions(merge: true));
    return false;
  }

  return true;
}

final authProvider = Provider<AuthProvider>((ref) {
  return AuthProvider();
});

class AuthProvider {
  final _deviceTokenProvider = DeviceTokenProvider();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> passwordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);

      EasyLoading.showSuccess('Password reset email sent.');
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        EasyLoading.showError('No user found with that email.');
      } else {
        EasyLoading.showError('Something went wrong.');
      }
    } catch (e) {
      EasyLoading.showError('Something went wrong.');
      return false;
    }
    return false;
  }

  static const List<String> scopes = <String>[
    'email',
    // 'https://www.googleapis.com/auth/contacts.readonly',
    // 'https://www.googleapis.com/auth/userinfo.profile',
    // 'https://www.googleapis.com/auth/userinfo.email',
  ];

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '961419777800-b12n5j0iqv1j621bnhskk3jhupo56ilh.apps.googleusercontent.com',
    // Optional clientId
    // clientId: 'your-client_id.apps.googleusercontent.com',
    scopes: scopes,
  );

  Future<User?> signInWithGoogle() async {
    // bool isAuthorized = await _googleSignIn.isSignedIn();
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      debugPrint('Google Credential: $credential');

      final userCred =
          await FirebaseAuth.instance.signInWithCredential(credential);

      await _deviceTokenProvider.saveDeviceToken(userCred.user!.uid);
      User? user = userCred.user;
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        EasyLoading.showError(
            'An account already exists with the same email address but different sign-in credentials. Sign in using a provider associated with this email address.');
      }
    } catch (e) {
      EasyLoading.showError('Something went wrong.');
    }
  }

  Future<String?> linkGoogle(WidgetRef ref) async {
    final googleUser = await _googleSignIn.signIn();

    if (googleUser != null) {
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final existingUser = FirebaseAuth.instance.currentUser;
      if (existingUser != null) {
        if (!existingUser.providerData
            .any((element) => element.providerId == 'google.com')) {
          try {
            await existingUser.linkWithCredential(credential);
            debugPrint('Linked With Credential !!!!!!!!!!!!!!!!!!!!!!!!!');
            EasyLoading.showSuccess('User Linked Successfully');
            return existingUser.email;
          } catch (e) {
            if (e is FirebaseAuthException) {
              if (e.code == 'account-exists-with-different-credential') {
                EasyLoading.showError(
                    'An account already exists with the same email address but different sign-in credentials. Sign in using a provider associated with this email address.');
              } else if (e.code == 'credential-already-in-use') {
                EasyLoading.showError(
                    'The account already exists with a different credential.');
              } else if (e.code == 'invalid-credential') {
                EasyLoading.showError('The credential provided is not valid.');
              } else {
                EasyLoading.showError(e.toString());
              }
            } else {
              EasyLoading.showError(e.toString());
            }
          }
        } else if (existingUser.email == googleUser.email) {
          EasyLoading.showSuccess('User Linked Already');
          return existingUser.email;
        } else {
          EasyLoading.showError('Linking Error');
          return null;
        }
        // await existingUser.linkWithCredential(credential);
        // return existingUser.email;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<bool> unlinkGoogleSignIn(WidgetRef ref) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (user.providerData
          .any((element) => element.providerId == 'google.com')) {
        await user.unlink("google.com");
        return true;
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  Future<User?> signInWithPassword(
      {required String email, required String password}) async {
    try {
      final UserCredential userCred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      await _deviceTokenProvider.saveDeviceToken(userCred.user!.phoneNumber!);
      User? user = userCred.user;
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        EasyLoading.showError(
            'An account already exists with the same email address but different sign-in credentials. Sign in using a provider associated with this email address.');
      } else {
        EasyLoading.showError(e.message.toString());
      }
    }
    return null;
  }

  Future<User?> registerWithPassword(
      {required String email, required String password}) async {
    final UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await _deviceTokenProvider.saveDeviceToken(userCred.user!.phoneNumber!);
    User? user = userCred.user;
    try {
      await user?.sendEmailVerification();
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        EasyLoading.showError(
            'An account already exists with the same email address but different sign-in credentials. Sign in using a provider associated with this email address.');
      } else {
        EasyLoading.showError(e.message.toString());
      }
    }
  }

  Future<User?> signInWithApple({List<Scope> scopes = const []}) async {
    // 1. perform the sign-in request
    final result = await TheAppleSignIn.performRequests(
        [AppleIdRequest(requestedScopes: scopes)]);
    // 2. check the result
    switch (result.status) {
      case AuthorizationStatus.authorized:
        final appleIdCredential = result.credential!;
        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken!),
          accessToken:
              String.fromCharCodes(appleIdCredential.authorizationCode!),
        );
        final userCredential = await _auth.signInWithCredential(credential);
        await _deviceTokenProvider
            .saveDeviceToken(userCredential.user!.phoneNumber!);
        final firebaseUser = userCredential.user;
        if (scopes.contains(Scope.fullName)) {
          final fullName = appleIdCredential.fullName;
          if (fullName != null &&
              fullName.givenName != null &&
              fullName.familyName != null) {
            final displayName = '${fullName.givenName} ${fullName.familyName}';
            await firebaseUser!.updateDisplayName(displayName);
          }
        }
        return userCredential.user;
      case AuthorizationStatus.error:
        throw PlatformException(
          code: 'ERROR_AUTHORIZATION_DENIED',
          message: result.error.toString(),
        );

      case AuthorizationStatus.cancelled:
        throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      default:
        throw UnimplementedError();
    }
  }

  // Future<User?> signInWithFacebook() async {
  //   try {
  //     final LoginResult result = await FacebookAuth.instance.login();
  //     log('FB Result: ${result.accessToken}');
  //     if (result.status == LoginStatus.success) {
  //       final OAuthCredential credential =
  //           FacebookAuthProvider.credential(result.accessToken!.token);
  //       log('FB Credentials: $credential');

  //       final userCred =
  //           await FirebaseAuth.instance.signInWithCredential(credential);

  //       log('FB User: ${userCred.user}');
  //       await _deviceTokenProvider.saveDeviceToken(userCred.user!.phoneNumber!);
  //       EasyLoading.showSuccess('Logged in successfully.');

  //       return userCred.user;
  //     } else {
  //       EasyLoading.showError('Something went wrong.');
  //       return null;
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'account-exists-with-different-credential') {
  //       EasyLoading.showError(
  //           'An account already exists with the same email address but different sign-in credentials. Sign in using a provider associated with this email address.');
  //     }
  //   } catch (e) {
  //     EasyLoading.showError('Something went wrong.');
  //   }
  //   return null;
  // }

  // Future<User?> signInWithPhoneNumber(
  //     String smsCode, String verificationId) async {
  //   try {
  //     final PhoneAuthCredential credential = PhoneAuthProvider.credential(
  //       verificationId: verificationId,
  //       smsCode: smsCode,
  //     );
  //     final userCred =
  //         await FirebaseAuth.instance.signInWithCredential(credential);
  //     await _deviceTokenProvider.saveDeviceToken(userCred.user!.phoneNumber!);
  //     return userCred.user;
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'invalid-verification-code') {
  //       EasyLoading.showError('Invalid code.');
  //     }
  //   }
  //   return null;
  // }

  Future<User?> signInWithPhoneNumber(
      String smsCode, String verificationId) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCred =
          await FirebaseAuth.instance.signInWithCredential(credential);
      // Future.delayed(const Duration(seconds: 10), () async {
      //   if (userCred.user == null){
      //   Restart.restartApp();}
      // });
      return userCred.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        EasyLoading.showError('Invalid code.');
      } else {
        await Restart.restartApp();
      }
    } catch (e) {
      await Restart.restartApp();
    }
    return null;
  }

  Future<void> signOut() async {
    Purchases.logOut();
    _deviceTokenProvider.deleteDeviceToken();
    // await GoogleSignIn().signOut();
    // await FacebookAuth.instance.logOut();
    await FirebaseAuth.instance.signOut();
  }
}

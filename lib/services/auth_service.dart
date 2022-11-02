import 'package:dojo_app/models/dojo_user.dart';
import 'package:dojo_app/screens/authentication/sign_in.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dojo_app/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import 'helper_functions.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user obj based on firebase user
  DojoUser? _userFromFirebaseUser(User? user) {
    return user != null ? DojoUser(uid: user.uid, providerData: user.providerData, emailAddress: user.email!, emailVerified: user.emailVerified) : null;
  }

  // auth change user stream
  Stream<DojoUser?> get user {
    return _auth
        .authStateChanges()
        .map(_userFromFirebaseUser);
  }

  // sign in anon
  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signInWithEmailAndPassword(String email, String password, context) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      // Store nickname in globals so it can be accessed universally
      DatabaseServices databaseServices = DatabaseServices();
      await databaseServices.fetchNickname(userID: user!.uid);

      return user;
    } on FirebaseAuthException catch  (error) {
      print(error.toString());

      //Check if email is already in use and redirect to sign-in if true
      if (error.code == 'user-not-found') {
        final snackBar = SnackBar(content: Text('There is no user with that email'),
          duration: const Duration(milliseconds: 5000),);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return null;
      }
      else if (error.code == 'wrong-password'){
        final snackBar = SnackBar(content: Text('Password is incorrect'),
          duration: const Duration(milliseconds: 5000),);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return null;
      }
    }
  }

// register with email and password
  Future registerWithEmailAndPassword(
      String email, String password, String nickname,context) async {
    try {
      //Call Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      /// Does the user exists in USER collection?
      // if yes, then store nickname in globals.nickname
      // if not, then add the user to USER collection
      // in this case (user just registered with email), this will always add the user to the collection
      await manageUserCreation(user);

      return _userFromFirebaseUser(user);

    } on FirebaseAuthException catch  (error) {
      print(error.toString());

      //Check if email is already in use and redirect to sign-in if true
      if (error.code == 'email-already-in-use')
        {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return SignIn(existingUser: true,);
          }));
        }
      else {
        return null;
      }
    }
  }

  Future signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    GoogleSignIn googleSignIn = GoogleSignIn();
    GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    // For unknown reasons, on the first ever attempt of signing in with google
    // 'googleSignInAccount' parameters returns as null
    // but on subsequent sign in attempts, this is not null...
    // So as a workaround hack, we try twice in total
    if (googleSignInAccount == null) {
      printBig('second google Sign In attempt', 'true');
      GoogleSignIn googleSignIn = GoogleSignIn();
      googleSignInAccount = await googleSignIn.signIn();
    }

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential = await auth.signInWithCredential(credential);
        user = userCredential.user;

        /// Does the user exists in USER collection?
        // if yes, then store nickname in globals.nickname
        // if not, then add the user to USER collection
        await manageUserCreation(user);

        return _userFromFirebaseUser(user);

      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          // handle the error here
        }
        else if (e.code == 'invalid-credential') {
          // handle the error here
        }
      } catch (e) {
        // handle the error here
      }
    }

    return _userFromFirebaseUser(user);
  }

  Future signInWithApple({List<Scope> scopes = const []}) async {
    final _firebaseAuth = FirebaseAuth.instance;

    /// 1. perform the sign-in request
    final result = await TheAppleSignIn.performRequests(
        [AppleIdRequest(requestedScopes: scopes)]);

    /// 2. check the result
    switch (result.status) {
      case AuthorizationStatus.authorized:
        final appleIdCredential = result.credential!;
        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken!),
          accessToken:
          String.fromCharCodes(appleIdCredential.authorizationCode!),
        );

        final userCredential = await _firebaseAuth.signInWithCredential(credential);
        final user = userCredential.user!;

        if (scopes.contains(Scope.fullName)) {
          final fullName = appleIdCredential.fullName;
          if (fullName != null &&
              fullName.givenName != null &&
              fullName.familyName != null) {
            final displayName = '${fullName.givenName} ${fullName.familyName}';
            await user.updateDisplayName(displayName);
          }
        }

        /// Does the user exists in USER collection?
        // if yes, then store nickname in globals.nickname
        // if not, then add the user to USER collection
        await manageUserCreation(user);

        // test printing
        // printBig('apple auth provider:', '${user!.providerData[0].providerId}');

        return _userFromFirebaseUser(user);

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

  Future<void> manageUserCreation(user) async {
    // get userInfo, returns Map {} if no user exists
    DatabaseServices databaseServices = DatabaseServices();
    Map userInfo = await databaseServices.fetchUserInfo(userID: user?.uid);

    if (userInfo.isEmpty) {
      /// User does not exist yet, so let's add one to the users collection

      // Set nickname as 'Default' and we will request their real nickname on the next registration step
      String nickname = 'Default';
      globals.nickname = nickname;

      // Add user to USER collection
      // await DatabaseService(uid: user!.uid).addUser(user.uid, nickname);
      await databaseServices.addUser(user!.uid, nickname);
    } else if (userInfo.isNotEmpty) {
      /// User already exists...
      // Set to global variable for nickname
      globals.nickname = userInfo['Nickname'];
    }
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }
}




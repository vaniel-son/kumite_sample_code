import 'package:dojo_app/models/dojo_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseServiceOldMatches {
  final String uid;

  DatabaseServiceOldMatches({required this.uid});

  /// collection reference to query users table
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  ///Maps dojo query for user data to DojoUserData object
  // Used with get userData stream (below), but below reference is not used
  DojoUser _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return DojoUser(
      uid: uid,
    );
  }

  /*///Stream to get any user data from Database.
  // not used anywhere
  Stream<DojoUserData> get userData {
    return userCollection.doc(uid).snapshots().map(_userDataFromSnapshot);
  }*/

  /*///Query Dojo User from database
  // currently only used on game_bloc.dart
  Future<DojoUserData> queryUserData(uid) async {
    var query = await userCollection.doc(uid).get();
    var dojoUserData = query.data();
    var dojoUserDataStore = DojoUserData(
      uid: uid,
      nickname: (dojoUserData as dynamic)['Nickname'],
    );

    return dojoUserDataStore;
  }*/

  ///Get nickname from DB
  // currently used on challenge_list screen, loader
  Future<String> getNickname(uid) async {
    var query = await userCollection.doc(uid).get();
    var dojoUserData = query.data();
    var dojoUserDataStore = DojoUser(
      uid: uid,
    );

    return 'nickname gone missing';
  }

  ///Create User record in database.
  Future<void> addUser(uid, nickname) async {
    // Call the user's CollectionReference to add a new user
    return await userCollection
        .doc(uid)
        .set({
          'User_ID': uid, // John Doe
          'Nickname': nickname, // Stokes and Sons
          'Date_Created': DateTime.now(),
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }
}

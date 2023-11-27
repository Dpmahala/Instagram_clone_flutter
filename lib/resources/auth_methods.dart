import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clone/models/user.dart' as model;
import 'package:instagram_clone/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser.uid).get();
    return model.User.fromSnap(snap);
  }

  // Sign up the user

  Future<String> signUpUser({
    required String email,
    required String passward,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty ||
          passward.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty) {
        // register the user

        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: passward,
        );
        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePicture', file, false);

        print(cred.user!.uid);

        // add user database

        model.User user = model.User(
          username: username,
          email: email,
          uid: cred.user!.uid,
          bio: bio,
          photoUrl: photoUrl,
          followers: [],
          following: [],
        );

        await _firestore.collection('users').doc(cred.user!.uid).set(
              user.toJson(),
            );

        res = 'succsess';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> loginUser({
    required String email,
    required String passward,
  }) async {
    String res = "Some erro occurred";

    try {
      if (email.isNotEmpty || passward.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: passward);
        res = "Succcess";
      } else {
        "Please enter all the fields";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}

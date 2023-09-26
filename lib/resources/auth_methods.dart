import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:b_cara/models/user_coin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:b_cara/models/user.dart' as model;
import 'package:b_cara/resources/storage_methods.dart';
import 'package:flutter/material.dart';

class AuthMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user details
  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();
    debugPrint("${documentSnapshot.data()}");

    return model.User.fromSnap(documentSnapshot);
  }

  // Login User
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Mengecek apakah dokumen dengan UID pengguna sudah ada
      User? cred = FirebaseAuth.instance.currentUser;

      DocumentSnapshot userCoinDoc =
          await _firestore.collection("users_coin").doc(cred!.uid).get();
      var walletAddress = sha256.convert(utf8.encode(email)).toString();
      var privateKey = sha256.convert(utf8.encode(cred.uid + email)).toString();
// Jika dokumen belum ada, tambahkan data UserCoin
      if (!userCoinDoc.exists) {
        UserCoin userCoin = UserCoin(
          walletAddress: walletAddress,
          privateKey: privateKey,
          email: email,
          coinOnHold: 0,
          coinSell: 0,
          coinBuy: 0,
          totalCoinUser: 0,
        );

        await _firestore
            .collection("users_coin")
            .doc(cred.uid)
            .set(userCoin.toJson());
      }

      return 'success';
    } catch (e) {
      // You can handle different exceptions and return meaningful messages here
      return e.toString();
    }
  }

  // Signing Up User
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    File? file, // Made this nullable
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        String photoUrl = '';
        if (file != null) {
          photoUrl = await StorageMethods()
              .uploadImageToStorage('profilePics', file, false);
        }
        var walletAddress = sha256.convert(utf8.encode(email)).toString();
        var privateKey =
            sha256.convert(utf8.encode(cred.user!.uid + email)).toString();
        model.User user = model.User(
          username: username,
          uid: cred.user!.uid,
          photoUrl: photoUrl,
          email: email,
          bio: bio,
          followers: [],
          following: [],
          isOnline: true,
        );

        await _firestore
            .collection("users")
            .doc(cred.user!.uid)
            .set(user.toJson());

        UserCoin userCoin = UserCoin(
            walletAddress: walletAddress,
            privateKey: privateKey,
            email: email,
            coinOnHold: 0,
            coinSell: 0,
            coinBuy: 0,
            totalCoinUser: 0);
        await _firestore
            .collection("users_coin")
            .doc(cred.user!.uid)
            .set(userCoin.toJson());

        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  // Sign Out Method
  Future<void> signOut() async {
    await _auth.signOut();
  }

  void setUserState(bool isOnline) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      'is_online': isOnline,
    });
  }

// Rest of your code (no changes)
}

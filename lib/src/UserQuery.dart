import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_final/src/firebase_auth_implementation/firebase_auth_services.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

bool isEmail(String input) {
  final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
  return emailRegex.hasMatch(input);
}

Future<bool> isUsernameTaken(String username) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      print('Dữ liệu trả về: ${querySnapshot.docs}');
      return querySnapshot.docs.isNotEmpty; 
    } catch (e) {
      print('Lỗi kiểm tra username: $e');
      return true; 
    }
}

Future<bool> isEmailTaken(String email) async {
  try {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: 'randomPassword');
    await credential.user!.delete(); 
    return false;
  } catch (e) {
    print('Lỗi kiểm tra email: $e');
    return true;
  }
}

Future<String?> getEmailFromUsername(String username) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return (querySnapshot.docs.first.data() as Map<String, dynamic>)['email'].toString();
    } else {
      return null;
    }
  } catch (e) {
    print('Lỗi khi lấy email từ username: $e');
    return null;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_final/src/model/Users.dart';
import 'package:flutter_final/src/services/folders_services.dart';
import 'package:logger/logger.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
var logger = Logger();

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
      //logger.e('Dữ liệu trả về: ${querySnapshot.docs}');
      return querySnapshot.docs.isNotEmpty; 
    } catch (e) {
      logger.e('Lỗi kiểm tra username: $e');
      return true; 
    }
}

Future<bool> isEmailTaken(String email) async {
  try {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: 'randomPassword');
    await credential.user!.delete(); 
    return false;
  } catch (e) {
    logger.e('Lỗi kiểm tra email: $e');
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
      return (querySnapshot.docs.first.data() as Map<String, dynamic>)['email'] as String?;
    } else {
      return null;
    }
  } catch (e) {
    logger.e('Lỗi khi lấy email từ username: $e');
    return null;
  }
}

Future<String> getNameFromEmail(String email) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return (querySnapshot.docs.first.data() as Map<String, dynamic>)['name'] as String;
    } else {
      throw Exception('Email not found');
    }
  } catch (e) {
    logger.e('Error getting name from email: $e');
    throw Exception('Error getting name from email');
  }
}

void ForgotPassword(String email) async{
  try{
    await _auth.sendPasswordResetEmail(email: email);
  }catch (e){
    throw Exception('Error sending password reset email');
  }
}

Future<String> getAvatarUrlByUsername(String username) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return (querySnapshot.docs.first.data() as Map<String, dynamic>)['avatarUrl'] as String;
    } else {
      return "";
    }
  } catch (e) {
    logger.e('$e');
    return "";
  }
}

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_final/src/model/Users.dart';
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

void forgotPassword(String email) async{
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

Future<Map<String, dynamic>?> getCurrentUser(String email) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null; 
    }

    final userDoc = querySnapshot.docs.first;
    Map<String, dynamic> userData = userDoc.data();
    return userData;
  } catch (e) {
    logger.e('Error fetching user: $e'); 
    rethrow; 
  }
}

Future<void> uploadImage(File imageFile) async {
    String fileName = Path.basename(imageFile.path);
    Reference storageReference = FirebaseStorage.instance.ref().child('avatars/$fileName');
    UploadTask uploadTask = storageReference.putFile(imageFile);
    await uploadTask.whenComplete(() async {
      String url = await storageReference.getDownloadURL();
     logger.e("Upload completed: $url");
    });
}

Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_final/src/models/users_model.dart';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
var logger = Logger();

bool isEmail(String input) {
  final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
  return emailRegex.hasMatch(input);
}

Future<bool> isUsernameTaken(String username) async {
  try {
    QuerySnapshot querySnapshot = await _firestore.collection('users').where('username', isEqualTo: username).get();
    //logger.e('Dữ liệu trả về: ${querySnapshot.docs}');
    return querySnapshot.docs.isNotEmpty;
  } catch (e) {
    logger.e('Lỗi kiểm tra username: $e');
    return true;
  }
}

Future<bool> isEmailTaken(String email) async {
  try {
    QuerySnapshot querySnapshot = await _firestore.collection('users').where('email', isEqualTo: email).get();
    return querySnapshot.docs.isNotEmpty;
  } catch (e) {
    logger.e('Lỗi kiểm tra email: $e');
    return true;
  }
}

Future<String?> getEmailFromUsername(String username) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').where('username', isEqualTo: username).get();

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
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).get();

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

Future<bool> forgotPassword(String email) async {
  try {
    await _auth.sendPasswordResetEmail(email: email);
    return true;
  } catch (e) {
    logger.e('Error sending password reset email');
    return false;
  }
}

Future<Map<String, dynamic>?> getUserByEmail(String userEmail) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').where("email", isEqualTo: userEmail).get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.data() as Map<String, dynamic>;
    } else {
      return null;
    }
  } catch (e) {
    logger.e('$e');
    return null;
  }
}

Future<Map<String, dynamic>?> getUserByUID(uid) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').where(FieldPath.documentId, isEqualTo: uid).get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.data() as Map<String, dynamic>;
    } else {
      return null;
    }
  } catch (e) {
    logger.e(e);
    return null;
  }
}

Future<String> getAvatarUrlById(String username) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').where(FieldPath.documentId, isEqualTo: username).get();

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
    final querySnapshot = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).get();

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
  String fileName = path.basename(imageFile.path);
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

Future<bool> createUser(email, username, password) async {
  bool hasErr = false;
  _auth.createUserWithEmailAndPassword(email: email, password: password).then((credential) async {
    User? user = credential.user;
    if (user != null) {
      await user.sendEmailVerification().catchError((e) {
        Logger().e('$e');
        hasErr = true;
      });
      Users newUser = Users(
        avatarUrl: '',
        email: email,
        name: username,
        username: username,
      );

      await _firestore.collection('users').doc(user.uid).set(newUser.toMap()).catchError((e) {
        Logger().e('$e');
        hasErr = true;
      });
      return !hasErr;
    }
    hasErr = true;
    return false;
  }).catchError((e) {
    Logger().e('$e');
    return false;
  });

  return !hasErr;
}

Future<bool> verifyEmail(email, password) async {
  try {
    UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    User? user = credential.user;
    if (user != null) {
      bool hasErr = false;
      user.sendEmailVerification().catchError((e) {
        Logger().e('$e');
        hasErr = true;
      });
      return !hasErr;
    }
    return false;
  } catch (e) {
    Logger().e('$e');
    return false;
  }
}

Future<bool> signInWithGoogle() async {
  bool hasErr = false;
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn(
      clientId: '34818372698-h2d5e144aj9gjtigj1s3jlvn9j79l93f.apps.googleusercontent.com',
    ).signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    try {
      UserCredential cred = await FirebaseAuth.instance.signInWithCredential(credential);

      if (cred.additionalUserInfo!.isNewUser) {
        Users newUser = Users(
          avatarUrl: '',
          email: cred.user?.email ?? "",
          name: (cred.user?.displayName ?? ""),
          username: "${(cred.user?.displayName ?? "").split(" ").join("_")}_${DateTime.now().microsecondsSinceEpoch.toString().substring(0, 6)}",
        );

        await _firestore.collection('users').doc(cred.user?.uid).set(newUser.toMap()).catchError((e) {
          Logger().e('$e');
          hasErr = true;
        });
      }

      return !hasErr;
    } catch (e) {
      Logger().e('$e');
      return false;
    }
  } catch (e) {
    Logger().e('exception->$e');
    return false;
  }
}

Future<bool> signInWithFacebook() async {
  try {
    final LoginResult result = await FacebookAuth.instance.login();
    switch (result.status) {
      case LoginStatus.success:
        bool hasErr = false;
        final AuthCredential facebookCredential = FacebookAuthProvider.credential(result.accessToken!.token);
        final cred = await _auth.signInWithCredential(facebookCredential);

        if (cred.additionalUserInfo!.isNewUser) {
          Users newUser = Users(
            avatarUrl: '',
            email: cred.user?.email ?? "",
            name: (cred.user?.displayName ?? ""),
            username: "${(cred.user?.displayName ?? "").split(" ").join("_")}_${DateTime.now().microsecondsSinceEpoch.toString().substring(0, 6)}",
          );

          await _firestore.collection('users').doc(cred.user?.uid).set(newUser.toMap()).catchError((e) {
            Logger().e('$e');
            hasErr = true;
          });
        }

        return !hasErr;
      case LoginStatus.cancelled:
        Logger().e('Login cancelled');
        return false;

      case LoginStatus.failed:
        Logger().e('Login failed');
        return false;

      default:
        return false;
    }
  } catch (e) {
    Logger().e('exception->$e');
    return false;
  }
}

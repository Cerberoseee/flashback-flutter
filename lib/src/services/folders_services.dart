import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_final/src/models/folder_model.dart';
import 'package:flutter_final/src/services/user_services.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

var logger = Logger();
FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<List<Map<String, dynamic>>> getAllFolder() async {
  try {
    QuerySnapshot querySnapshot = await firestore.collection('folders').get();
    List<Map<String, dynamic>> folderList = [];

    for (int i = 0; i < querySnapshot.docs.length; i++) {
      QueryDocumentSnapshot doc = querySnapshot.docs[i];
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      data['id'] = doc.id;
      String username = data['createdBy'].toString();
      String avatarUrl = await getAvatarUrlById(username);

      Map<String, dynamic> folderData = {
        'id': data['id'],
        'folderName': data['folderName'] ?? '',
        'description': data['description'] ?? '',
        'createdBy': {
          'username': username,
          'avatarUrl': avatarUrl,
        },
        'createdOn': data['createdOn'] ?? '',
      };

      folderList.add(folderData);
    }
    return folderList;
  } catch (e) {
    logger.e(e);
    return [];
  }
}

Future<List<Map<String, dynamic>>> getUserFolder(userId, userEmail) async {
  try {
    QuerySnapshot querySnapshot = await firestore.collection('folders').where("createdBy", isEqualTo: userId).get();
    List<Map<String, dynamic>> folderList = [];
    dynamic user = await getUserByEmail(userEmail);

    for (int i = 0; i < querySnapshot.docs.length; i++) {
      QueryDocumentSnapshot doc = querySnapshot.docs[i];
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      data['id'] = doc.id;
      Map<String, dynamic> folderData = {
        'id': data['id'],
        'folderName': data['folderName'] ?? '',
        'description': data['description'] ?? '',
        'createdBy': {
          'username': user["name"],
          'avatarUrl': user["avatarUrl"],
        },
        'createdOn': data['createdOn'] ?? '',
      };

      folderList.add(folderData);
    }
    return folderList;
  } catch (e) {
    logger.e(e);
    return [];
  }
}

Future<List<Map<String, dynamic>>> getRecentFolder() async {
  try {
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<String> recentList = pref.getStringList("recentFolderList") ?? [""];

    QuerySnapshot querySnapshot = await firestore.collection('folders').where(FieldPath.documentId, whereIn: recentList).get();
    List<Map<String, dynamic>> folderList = [];

    for (int i = 0; i < querySnapshot.docs.length; i++) {
      QueryDocumentSnapshot doc = querySnapshot.docs[i];
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      data['id'] = doc.id;
      String username = data['createdBy'].toString();
      String avatarUrl = await getAvatarUrlById(username);

      Map<String, dynamic> folderData = {
        'id': data['id'],
        'folderName': data['folderName'] ?? '',
        'description': data['description'] ?? '',
        'createdBy': {
          'username': username,
          'avatarUrl': avatarUrl,
        },
        'createdOn': data['createdOn'] ?? '',
      };

      folderList.add(folderData);
    }
    return folderList;
  } catch (e) {
    logger.e(e);
    return [];
  }
}

Future<void> createFolder(Folder newFolder) async {
  try {
    Map<String, dynamic> folderData = newFolder.toMap();
    await firestore.collection('folders').add(folderData);
  } catch (e) {
    logger.e('Error creating folder: $e');
  }
}

Future<Map<String, dynamic>?> getFolderDetail(String folderId) async {
  //try {
  DocumentSnapshot folderDoc = await FirebaseFirestore.instance.collection('folders').doc(folderId).get();

  if (folderDoc.exists) {
    Map<String, dynamic> folderData = folderDoc.data() as Map<String, dynamic>;
    String avtUrl = await getAvatarUrlById(folderData['createdBy'].toString());

    List<Map<String, dynamic>>? topicsList = [];
    List<dynamic>? topicsData = folderData['topics'];
    if (topicsData == null) {
      topicsList = null;
    } else {
      for (var topic in topicsData) {
        String createdBy = topic['createdBy'].toString();
        String avtUrl = createdBy.isNotEmpty ? await getAvatarUrlById(createdBy) : '';
        Map<String, dynamic> topicMap = {
          'id': topic['id'],
          'topicName': topic['topicName'],
          'description': topic['description'],
          'createdBy': {
            'username': createdBy,
            'avatarUrl': avtUrl,
          },
          'createdOn': topic['createdOn'],
        };
        topicsList.add(topicMap);
      }
    }
    return {
      'id': folderData['id'],
      'folderName': folderData['folderName'],
      'description': folderData['description'],
      'createdBy': {
        'username': folderData['createdBy'],
        'avatarUrl': avtUrl,
      },
      'topics': topicsList,
      'createdOn': folderData['createdOn'],
    };
  } else {
    logger.e('Document with ID $folderId does not exist');
    return null;
  }
}

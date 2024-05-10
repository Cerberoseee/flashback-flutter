import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter_final/src/models/folder_model.dart';
import 'package:flutter_final/src/services/user_services.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

var logger = Logger();
FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<List<Map<String, dynamic>>> getAllFolder(int limit) async {
  try {
    QuerySnapshot folderQuerySnapshot = await firestore.collection('folders').limit(limit).get();
    QuerySnapshot userQuerySnapshot = await firestore.collection('users').get();

    List<QueryDocumentSnapshot> userData = userQuerySnapshot.docs;
    List<Map<String, dynamic>> res = [];

    for (QueryDocumentSnapshot folder in folderQuerySnapshot.docs) {
      var user = userData.firstWhereOrNull((element) => (folder.data() as Map<String, dynamic>)["createdBy"] == element.id)?.data() ?? {};
      var data = folder.data() as Map<String, dynamic>;
      data['id'] = folder.id;

      data["createdBy"] = user;
      Map<String, dynamic> folderData = {
        'id': data['id'],
        'folderName': data['folderName'] ?? '',
        'description': data['description'] ?? '',
        'createdBy': data['createdBy'],
        'createdOn': data['createdOn'] ?? '',
      };
      res.add(folderData);
    }
    return res;
  } catch (e) {
    logger.e(e);
    return [];
  }
}

Future<List<Map<String, dynamic>>> getUserFolder(String userId, String userEmail, int limit) async {
  try {
    QuerySnapshot querySnapshot = await firestore.collection('folders').where("createdBy", isEqualTo: userId).limit(limit).get();
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
          'username': user["username"],
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

Future<List<Map<String, dynamic>>> getRecentFolder(int limit) async {
  try {
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<String> recentList = pref.getStringList("recentFolderList") ?? [];

    if (recentList.isEmpty) return [];

    QuerySnapshot folderQuerySnapshot = await firestore.collection('folders').where(FieldPath.documentId, whereIn: recentList).limit(limit).get();
    QuerySnapshot userQuerySnapshot = await firestore.collection('users').get();

    List<QueryDocumentSnapshot> userData = userQuerySnapshot.docs;
    List<Map<String, dynamic>> res = [];

    for (QueryDocumentSnapshot folder in folderQuerySnapshot.docs) {
      var user = userData.firstWhereOrNull((element) => (folder.data() as Map<String, dynamic>)["createdBy"] == element.id)?.data() ?? {};
      var data = folder.data() as Map<String, dynamic>;
      data['id'] = folder.id;

      data["createdBy"] = user;
      Map<String, dynamic> folderData = {
        'id': data['id'],
        'folderName': data['folderName'] ?? '',
        'description': data['description'] ?? '',
        'createdBy': data['createdBy'],
        'createdOn': data['createdOn'] ?? '',
      };
      res.add(folderData);
    }
    return res;
  } catch (e) {
    logger.e(e);
    return [];
  }
}

Future<Map<String, dynamic>?> getFolderDetail(String folderId) async {
  try {
    DocumentSnapshot folderDoc = await FirebaseFirestore.instance.collection('folders').doc(folderId).get();
    QuerySnapshot topicQuerySnapshot = await firestore.collection('topics').get();
    QuerySnapshot userQuerySnapshot = await firestore.collection('users').get();

    if (folderDoc.exists) {
      var folderUser = userQuerySnapshot.docs.firstWhereOrNull((element) => (folderDoc.data() as Map<String, dynamic>)["createdBy"] == element.id)?.data() ?? {};

      Map<String, dynamic> folderData = folderDoc.data() as Map<String, dynamic>;
      List<Map<String, dynamic>>? topicsList = [];

      for (QueryDocumentSnapshot topic in topicQuerySnapshot.docs) {
        if (folderData["topics"] != null && (folderData["topics"] as List<dynamic>).contains(topic.id)) {
          var user = userQuerySnapshot.docs.firstWhereOrNull((element) => (topic.data() as Map<String, dynamic>)["createdBy"] == element.id)?.data() ?? {};
          var data = topic.data() as Map<String, dynamic>;
          data['id'] = topic.id;

          data["createdBy"] = user;
          Map<String, dynamic> topicData = {
            'id': data['id'],
            'topicName': data['topicName'] ?? '',
            'description': data['description'] ?? '',
            'createdBy': data['createdBy'],
            'createdOn': data['createdOn'] ?? '',
            'status': data['status'] ?? "",
          };
          topicsList.add(topicData);
        }
      }

      return {
        'id': folderDoc.id,
        'folderName': folderData['folderName'],
        'description': folderData['description'],
        'createdBy': folderUser,
        'topics': topicsList,
        'createdOn': folderData['createdOn'],
        'status': folderData['status'] ?? "",
      };
    } else {
      logger.e('Folder with ID $folderId does not exist');
      return null;
    }
  } catch (e) {
    Logger().e("Error in fetching folder: $e");
    return null;
  }
}

Future<List<Map<String, dynamic>>> searchFolder(int limit, String term) async {
  try {
    if (term == "") return [];
    QuerySnapshot folder1QuerySnapshot = await firestore
        .collection('folders')
        .where("folderNameQuery", isGreaterThanOrEqualTo: term.toLowerCase())
        .where("folderNameQuery", isLessThanOrEqualTo: "${term.toLowerCase()}\uf8ff")
        .limit(limit)
        .get();
    QuerySnapshot folder2QuerySnapshot = await firestore
        .collection('folders')
        .where("descriptionQuery", isGreaterThanOrEqualTo: term.toLowerCase())
        .where("descriptionQuery", isLessThanOrEqualTo: "${term.toLowerCase()}\uf8ff")
        .limit(limit)
        .get();

    QuerySnapshot userQuerySnapshot = await firestore.collection('users').get();

    List<QueryDocumentSnapshot> userData = userQuerySnapshot.docs;
    List<QueryDocumentSnapshot> folderData = folder1QuerySnapshot.docs;
    folderData.addAll(folder2QuerySnapshot.docs);
    final ids = folderData.map((e) => e.id).toSet();
    folderData.retainWhere((x) => ids.remove(x.id));

    List<Map<String, dynamic>> res = [];

    for (QueryDocumentSnapshot folder in folderData) {
      var user = userData.firstWhereOrNull((element) => (folder.data() as Map<String, dynamic>)["createdBy"] == element.id)?.data() ?? {};
      var data = folder.data() as Map<String, dynamic>;
      data['id'] = folder.id;

      data["createdBy"] = user;
      Map<String, dynamic> folderData = {
        'id': data['id'],
        'folderName': data['folderName'] ?? '',
        'description': data['description'] ?? '',
        'createdBy': data['createdBy'],
        'createdOn': data['createdOn'] ?? '',
      };
      res.add(folderData);
    }
    return res;
  } catch (e) {
    logger.e(e);
    return [];
  }
}

Future<bool> createFolder(Folder newFolder) async {
  try {
    Map<String, dynamic> folderData = newFolder.toMap();
    await firestore.collection('folders').add(folderData);
    return true;
  } catch (e) {
    logger.e('Error creating folder: $e');
    return false;
  }
}

Future<bool> deleteFolder(String folderId) async {
  try {
    await FirebaseFirestore.instance.collection('folders').doc(folderId).delete();
    return true;
  } catch (e) {
    logger.e('Error deleting folder: $e');
    return false;
  }
}

Future<bool> patchFolder(String folderId, dynamic data) async {
  try {
    DocumentSnapshot folderDoc = await FirebaseFirestore.instance.collection('folders').doc(folderId).get();
    await folderDoc.reference.update(data);
    return true;
  } catch (e) {
    Logger().e("Error patching: $e");
    return false;
  }
}

Future<List<dynamic>> findFolderHasTopic(String topicId) async {
  try {
    QuerySnapshot folderDoc = await FirebaseFirestore.instance.collection('folders').where("topics", arrayContains: topicId).get();

    return folderDoc.docs.map((e) => e.id).toList();
  } catch (e) {
    Logger().e("Error finding folders: $e");
    return [];
  }
}

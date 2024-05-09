import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter_final/src/models/topic_model.dart';
import 'package:flutter_final/src/services/user_services.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

var logger = Logger();
FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<List<Map<String, dynamic>>> getRecentTopic(int limit) async {
  try {
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<String> recentList = pref.getStringList("recentTopicList") ?? [];

    if (recentList.isEmpty) return [];

    QuerySnapshot topicQuerySnapshot = await firestore.collection('topics').where(FieldPath.documentId, whereIn: recentList).limit(limit).get();
    QuerySnapshot userQuerySnapshot = await firestore.collection('users').get();

    List<QueryDocumentSnapshot> userData = userQuerySnapshot.docs;
    List<Map<String, dynamic>> res = [];

    for (QueryDocumentSnapshot topic in topicQuerySnapshot.docs) {
      var user = userData.firstWhereOrNull((element) => (topic.data() as Map<String, dynamic>)["createdBy"] == element.id)?.data() ?? {};
      var data = topic.data() as Map<String, dynamic>;
      data['id'] = topic.id;

      data["createdBy"] = user;
      Map<String, dynamic> topicData = {
        'id': data['id'],
        'topicName': data['topicName'] ?? '',
        'description': data['description'] ?? '',
        'createdBy': data['createdBy'],
        'createdOn': data['createdOn'] ?? '',
      };
      res.add(topicData);
    }
    return res;
  } catch (e) {
    logger.e(e);
    return [];
  }
}

Future<List<Map<String, dynamic>>> getUserTopic(String userId, String userEmail, int limit) async {
  try {
    QuerySnapshot querySnapshot = await firestore.collection('topics').where("createdBy", isEqualTo: userId).limit(limit).get();
    List<Map<String, dynamic>> topicList = [];
    dynamic user = await getUserByEmail(userEmail);
    List<QueryDocumentSnapshot> doc = querySnapshot.docs;

    for (int i = 0; i < querySnapshot.docs.length; i++) {
      Map<String, dynamic> data = doc[i].data() as Map<String, dynamic>;

      data['id'] = doc[i].id;
      Map<String, dynamic> topicData = {
        'id': data['id'],
        'topicName': data['topicName'] ?? '',
        'description': data['description'] ?? '',
        'createdBy': {
          'username': user["username"],
          'avatarUrl': user["avatarUrl"],
        },
        'createdOn': data['createdOn'] ?? '',
      };

      topicList.add(topicData);
    }
    return topicList;
  } catch (e) {
    logger.e(e);
    return [];
  }
}

Future<bool> createTopic(Topic topic) async {
  try {
    Map<String, dynamic> topicData = topic.toMap();
    await firestore.collection('topics').add(topicData);
    return true;
  } catch (e) {
    logger.e('Error creating folder: $e');
    return false;
  }
}

Future<List<Map<String, dynamic>>> getAllTopic(int limit) async {
  try {
    QuerySnapshot topicQuerySnapshot = await firestore.collection('topics').limit(limit).get();
    QuerySnapshot userQuerySnapshot = await firestore.collection('users').get();

    List<QueryDocumentSnapshot> userData = userQuerySnapshot.docs;
    List<Map<String, dynamic>> res = [];

    for (QueryDocumentSnapshot topic in topicQuerySnapshot.docs) {
      var user = userData.firstWhereOrNull((element) => (topic.data() as Map<String, dynamic>)["createdBy"] == element.id)?.data() ?? {};
      var data = topic.data() as Map<String, dynamic>;
      data['id'] = topic.id;

      data["createdBy"] = user;
      Map<String, dynamic> topicData = {
        'id': data['id'],
        'topicName': data['topicName'] ?? '',
        'description': data['description'] ?? '',
        'createdBy': data['createdBy'],
        'createdOn': data['createdOn'] ?? '',
      };
      res.add(topicData);
    }
    return res;
  } catch (e) {
    logger.e(e);
    return [];
  }
}

Future<List<Map<String, dynamic>>> searchTopic(int limit, String term) async {
  try {
    if (term == "") return [];
    QuerySnapshot topic1QuerySnapshot = await firestore
        .collection('topics')
        .where("topicNameQuery", isGreaterThanOrEqualTo: term.toLowerCase())
        .where("topicNameQuery", isLessThanOrEqualTo: "${term.toLowerCase()}\uf8ff")
        .limit(limit)
        .get();
    QuerySnapshot topic2QuerySnapshot = await firestore
        .collection('topics')
        .where("descriptionQuery", isGreaterThanOrEqualTo: term.toLowerCase())
        .where("descriptionQuery", isLessThanOrEqualTo: "${term.toLowerCase()}\uf8ff")
        .limit(limit)
        .get();
    QuerySnapshot userQuerySnapshot = await firestore.collection('users').get();

    List<QueryDocumentSnapshot> userData = userQuerySnapshot.docs;
    List<QueryDocumentSnapshot> topicData = topic1QuerySnapshot.docs;
    topicData.addAll(topic2QuerySnapshot.docs);
    final ids = topicData.map((e) => e.id).toSet();
    topicData.retainWhere((x) => ids.remove(x.id));

    List<Map<String, dynamic>> res = [];

    for (QueryDocumentSnapshot topic in topicData) {
      var user = userData.firstWhereOrNull((element) => (topic.data() as Map<String, dynamic>)["createdBy"] == element.id)?.data() ?? {};
      var data = topic.data() as Map<String, dynamic>;
      data['id'] = topic.id;

      data["createdBy"] = user;
      Map<String, dynamic> topicData = {
        'id': data['id'],
        'topicName': data['topicName'] ?? '',
        'description': data['description'] ?? '',
        'createdBy': data['createdBy'],
        'createdOn': data['createdOn'] ?? '',
      };
      res.add(topicData);
    }
    return res;
  } catch (e) {
    logger.e(e);
    return [];
  }
}

Future<Map<String, dynamic>?> getTopicDetail(String topicId) async {
  try {
    DocumentSnapshot topicDoc = await FirebaseFirestore.instance.collection('topics').doc(topicId).get();
    QuerySnapshot userQuerySnapshot = await firestore.collection('users').get();

    if (topicDoc.exists) {
      var topicUser = userQuerySnapshot.docs.firstWhereOrNull((element) => (topicDoc.data() as Map<String, dynamic>)["createdBy"] == element.id)?.data() ?? {};
      Map<String, dynamic> folderData = topicDoc.data() as Map<String, dynamic>;

      return {
        'id': topicDoc.id,
        'topicName': folderData['topicName'],
        'description': folderData['description'],
        'createdBy': topicUser,
        'createdOn': folderData['createdOn'],
        'vocabularies': folderData['vocabularies'] ?? [],
        'status': folderData['status'] ?? "",
      };
    } else {
      logger.e('Folder with ID $topicId does not exist');
      return null;
    }
  } catch (e) {
    Logger().e("Error in fetching folder: $e");
    return null;
  }
}

Future<bool> patchTopic(String topicId, dynamic data) async {
  try {
    await FirebaseFirestore.instance.collection('topics').doc(topicId).update(data);
    return true;
  } catch (e) {
    logger.e('Error editting topic: $e');
    return false;
  }
}

Future<bool> deleteTopic(String topicId) async {
  try {
    await FirebaseFirestore.instance.collection('topics').doc(topicId).delete();
    return true;
  } catch (e) {
    logger.e('Error deleting topic: $e');
    return false;
  }
}

Future<bool> addTopicToFolder(String topicId, List<String> folderIdList) async {
  try {
    if (folderIdList.isEmpty) return true;
    QuerySnapshot folderQuerySnapshot = await firestore.collection('folders').where(FieldPath.documentId, whereIn: folderIdList).get();
    if (folderQuerySnapshot.docs.isNotEmpty) {
      for (var folder in folderQuerySnapshot.docs) {
        List<dynamic> topicList = (folder.data() as Map<String, dynamic>)["topics"];
        topicList.add(topicId);
        topicList = topicList.toSet().toList();
        folder.reference.update({"topic": topicList});
      }
    }
    return true;
  } catch (e) {
    Logger().e("Error add topic to folder: $e");
    return false;
  }
}

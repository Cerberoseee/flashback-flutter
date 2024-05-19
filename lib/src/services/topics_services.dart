import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter_final/src/models/topic_model.dart';
import 'package:flutter_final/src/models/user_topic_model.dart';
import 'package:flutter_final/src/models/user_topic_score.dart';
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
    QuerySnapshot topicQuerySnapshot = await firestore.collection('topics').limit(limit).where("status", isEqualTo: "public").get();
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
        // .where("status", isEqualTo: "public")
        .limit(limit)
        .get();
    QuerySnapshot topic2QuerySnapshot = await firestore
        .collection('topics')
        .where("descriptionQuery", isGreaterThanOrEqualTo: term.toLowerCase())
        .where("descriptionQuery", isLessThanOrEqualTo: "${term.toLowerCase()}\uf8ff")
        // .where("status", isEqualTo: "public")
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
      (topicUser as Map<String, dynamic>)["id"] = (topicDoc.data() as Map<String, dynamic>)["createdBy"];
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

Future<bool> addTopicFolderService(String topicId, List<String> folderIdList) async {
  try {
    if (folderIdList.isEmpty) return true;
    QuerySnapshot folderQuerySnapshot = await firestore.collection('folders').where(FieldPath.documentId, whereIn: folderIdList).get();
    if (folderQuerySnapshot.docs.isNotEmpty) {
      for (var folder in folderQuerySnapshot.docs) {
        List<dynamic> topicList = (folder.data() as Map<String, dynamic>)["topics"] ?? [];
        topicList.add(topicId);
        topicList = topicList.toSet().toList();
        folder.reference.update({"topics": topicList});
      }
    }
    return true;
  } catch (e) {
    Logger().e("Error add topic to folder: $e");
    return false;
  }
}

Future<String?> createTopicUserInfo(TopicUserInfo info) async {
  try {
    Map<String, dynamic> infoData = info.toMap();
    var res = await firestore.collection('user_topic_info').add(infoData);
    return res.id;
  } catch (e) {
    logger.e('Error creating folder: $e');
    return null;
  }
}

Future<dynamic> getTopicUserInfo(String topicId, String userId, List<dynamic> vocabList) async {
  try {
    QuerySnapshot infoQuerySnapshot = await firestore.collection('user_topic_info').where('topicId', isEqualTo: topicId).where('userId', isEqualTo: userId).get();

    Map<String, dynamic> infoData;

    if (infoQuerySnapshot.docs.isEmpty) {
      TopicUserInfo newInfo = TopicUserInfo(
          topicId: topicId,
          userId: userId,
          vocabStatus: vocabList
              .map((e) => {
                    "vocabId": e["vocabId"],
                    "isStarred": false,
                    "status": "notLearned",
                  })
              .toList());
      var res = await createTopicUserInfo(newInfo);
      infoData = await FirebaseFirestore.instance.collection('user_topic_info').doc(res).get().then((value) => value.data() as Map<String, dynamic>);
    } else {
      DocumentSnapshot infoDoc = infoQuerySnapshot.docs.first;
      infoData = infoDoc.data() as Map<String, dynamic>;
    }

    return infoData;
  } catch (e) {
    Logger().e("Error get topic user info: $e");
    return {};
  }
}

Future<bool> patchTopicUserInfo(String topicId, String userId, dynamic data) async {
  try {
    QuerySnapshot statusDocSnapshot = await FirebaseFirestore.instance.collection('user_topic_info').where("topicId", isEqualTo: topicId).where("userId", isEqualTo: userId).get();

    await statusDocSnapshot.docs.firstOrNull?.reference.update(data);
    return true;
  } catch (e) {
    Logger().e("Error patching status: $e");
    return false;
  }
}

Future<bool> createScore(UserTopicScore score) async {
  try {
    Map<String, dynamic> scoreData = score.toMap();
    await firestore.collection('user_topic_score').add(scoreData);
    return true;
  } catch (e) {
    logger.e('Error creating folder: $e');
    return false;
  }
}

Future<dynamic> getDetailScore(String topicId, String userId) async {
  try {
    QuerySnapshot infoQuerySnapshot = await firestore.collection('user_topic_score').where('topicId', isEqualTo: topicId).where('userId', isEqualTo: userId).get();

    Map<String, dynamic> infoData;
    if (infoQuerySnapshot.docs.isNotEmpty) {
      DocumentSnapshot infoDoc = infoQuerySnapshot.docs.first;
      infoData = infoDoc.data() as Map<String, dynamic>;
      infoData['id'] = infoDoc.id;
      return infoData;
    }
    return null;
  } catch (e) {
    logger.e('Error creating folder: $e');
    return null;
  }
}

Future<bool> patchScore(String id, dynamic data) async {
  try {
    DocumentSnapshot scoreDoc = await FirebaseFirestore.instance.collection('user_topic_score').doc(id).get();
    await scoreDoc.reference.update(data);
    return true;
  } catch (e) {
    Logger().e("Error patching score: $e");
    return false;
  }
}

Future<dynamic> getAllScore(String topicId) async {
  try {
    QuerySnapshot scoreQuerySnapshot = await firestore.collection('user_topic_score').where('topicId', isEqualTo: topicId).get();

    if (scoreQuerySnapshot.docs.isNotEmpty) {
      var res = [];
      QuerySnapshot userQuerySnapshot = await firestore.collection('users').get();

      for (DocumentSnapshot scoreDoc in scoreQuerySnapshot.docs) {
        var scoreData = scoreDoc.data() as Map<String, dynamic>;

        List<QueryDocumentSnapshot> userData = userQuerySnapshot.docs;
        var user = userData.firstWhereOrNull((element) => scoreData["userId"] == element.id)?.data() ?? {};
        scoreData["user"] = user;

        res.add(scoreData);
      }

      return res;
    }
    return [];
  } catch (e) {
    logger.e('Error creating folder: $e');
    return [];
  }
}

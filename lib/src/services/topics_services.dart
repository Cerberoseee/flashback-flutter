import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_final/src/models/topic_model.dart';
import 'package:flutter_final/src/services/user_services.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

var logger = Logger();
FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<List<Map<String, dynamic>>> getRecentTopic() async {
  try {
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<String> recentList = pref.getStringList("recentTopicList") ?? [""];

    QuerySnapshot querySnapshot = await firestore.collection('topics').where(FieldPath.documentId, whereIn: recentList).get();
    List<Map<String, dynamic>> folderList = [];

    for (int i = 0; i < querySnapshot.docs.length; i++) {
      QueryDocumentSnapshot doc = querySnapshot.docs[i];
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      data['id'] = doc.id;
      String username = data['createdBy'].toString();
      String avatarUrl = await getAvatarUrlById(username);

      Map<String, dynamic> folderData = {
        'id': data['id'],
        'folderName': data['topicName'] ?? '',
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

Future<List<Map<String, dynamic>>> getUserTopic(userId, userEmail) async {
  try {
    QuerySnapshot querySnapshot = await firestore.collection('topics').where("createdBy", isEqualTo: userId).get();
    List<Map<String, dynamic>> topicList = [];
    dynamic user = await getUserByEmail(userEmail);

    for (int i = 0; i < querySnapshot.docs.length; i++) {
      QueryDocumentSnapshot doc = querySnapshot.docs[i];
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      data['id'] = doc.id;
      Map<String, dynamic> topicData = {
        'id': data['id'],
        'topicName': data['topicName'] ?? '',
        'description': data['description'] ?? '',
        'createdBy': {
          'username': user["name"],
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

Future<void> createTopic(Topic topic) async {
  try {
    Map<String, dynamic> topicData = topic.toMap();
    await firestore.collection('topics').add(topicData);
  } catch (e) {
    logger.e('Error creating folder: $e');
  }
}
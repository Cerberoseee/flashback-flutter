import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final/src/services/folders_services.dart';
import 'package:flutter_final/src/services/topics_services.dart';

class AddTopicFolderView extends StatefulWidget {
  const AddTopicFolderView({
    super.key,
    this.folderId = "",
    this.topicList = const [],
  });
  final String folderId;
  final List<dynamic> topicList;

  static const routeName = "/add-topic-to-folder";

  @override
  State<StatefulWidget> createState() => _AddTopicFolderState();
}

class _AddTopicFolderState extends State<AddTopicFolderView> {
  bool _isLoading = false, _isSubmitting = false;

  List<Map<String, dynamic>> _userTopic = [];
  List<Map<String, dynamic>> _recentTopic = [];
  List<Map<String, dynamic>> _publicTopic = [];

  Future<void> _fetchData() async {
    String? userId = FirebaseAuth.instance.currentUser!.uid;
    String? userEmail = FirebaseAuth.instance.currentUser!.email ?? "";

    setState(() {
      _isLoading = true;
    });

    List<Map<String, dynamic>> fetchUserTopic = await getUserTopic(userId, userEmail, 5);
    List<Map<String, dynamic>> fetchRecentTopic = await getRecentTopic(5);
    List<Map<String, dynamic>> fetchPublicTopic = await getAllTopic(5);

    fetchUserTopic = fetchUserTopic.map((e) {
      return {...e, 'isSelected': widget.topicList.contains(e["id"])};
    }).toList();

    fetchRecentTopic = fetchRecentTopic.map((e) {
      return {...e, 'isSelected': widget.topicList.contains(e["id"])};
    }).toList();

    fetchPublicTopic = fetchPublicTopic.map((e) {
      return {...e, 'isSelected': widget.topicList.contains(e["id"])};
    }).toList();

    if (mounted) {
      setState(() {
        _userTopic = fetchUserTopic;
        _recentTopic = fetchRecentTopic;
        _publicTopic = fetchPublicTopic;
        _isLoading = false;
      });
    }
  }

  Future<void> addTopicToFolder() async {
    List<dynamic> temp = [];
    temp.addAll(_userTopic);
    temp.addAll(_recentTopic);
    temp.addAll(_publicTopic);

    List<dynamic> selectedFolder = temp.where((element) => element['isSelected']).map((e) => e["id"]).toSet().toList();
    setState(() {
      _isSubmitting = true;
    });

    if (!selectedFolder.equals(widget.topicList)) {
      await patchFolder(widget.folderId, {"topics": selectedFolder}).then((res) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
        if (res) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Topic added successfully!")));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Topic added failed, please try again!")));
        }
        Navigator.of(context).pop(true);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Topic added successfully!")));
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add to Folder"),
        actions: [
          IconButton(
            onPressed: (_isLoading || _isSubmitting)
                ? null
                : () {
                    addTopicToFolder();
                  },
            icon: const Icon(Icons.done),
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your Topics",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 300,
                      child: _userTopic.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 128,
                                    height: 128,
                                    child: Image.asset(kIsWeb ? "images/topic_empty.png" : "assets/images/topic_empty.png"),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "No Topic found",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pushNamedAndRemoveUntil('/vocab', (Route<dynamic> route) => false);
                                    },
                                    child: const Text(
                                      "Press here to manage your topic",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemBuilder: (context, index) {
                                return CheckboxListTile(
                                  value: _userTopic[index]["isSelected"],
                                  checkColor: Colors.white,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _userTopic[index]["isSelected"] = value!;
                                    });
                                  },
                                  title: Text(_userTopic[index]["topicName"] ?? ""),
                                );
                              },
                              separatorBuilder: (context, index) => const Divider(),
                              itemCount: _userTopic.length,
                            ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Recently added Topics",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 300,
                      child: _publicTopic.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 128,
                                    height: 128,
                                    child: Image.asset(kIsWeb ? "images/topic_empty.png" : "assets/images/topic_empty.png"),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "No Topic found",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemBuilder: (context, index) {
                                return CheckboxListTile(
                                  value: _publicTopic[index]["isSelected"],
                                  checkColor: Colors.white,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _publicTopic[index]["isSelected"] = value!;
                                    });
                                  },
                                  title: Text(_publicTopic[index]["topicName"] ?? ""),
                                );
                              },
                              separatorBuilder: (context, index) => const Divider(),
                              itemCount: _publicTopic.length,
                            ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Recently visited Topics",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 300,
                      child: _recentTopic.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 128,
                                    height: 128,
                                    child: Image.asset(kIsWeb ? "images/topic_empty.png" : "assets/images/topic_empty.png"),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "No Topic found",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pushNamedAndRemoveUntil('/community', (Route<dynamic> route) => false);
                                    },
                                    child: const Text(
                                      "Visit more Topics",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemBuilder: (context, index) {
                                return CheckboxListTile(
                                  value: _recentTopic[index]["isSelected"],
                                  checkColor: Colors.white,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _recentTopic[index]["isSelected"] = value!;
                                    });
                                  },
                                  title: Text(_recentTopic[index]["topicName"] ?? ""),
                                );
                              },
                              separatorBuilder: (context, index) => const Divider(),
                              itemCount: _recentTopic.length,
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

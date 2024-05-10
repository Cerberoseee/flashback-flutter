import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final/src/helper/vocab_import_export.dart';
import 'package:flutter_final/src/models/topic_model.dart';
import 'package:flutter_final/src/services/topics_services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

class AddTopicView extends StatefulWidget {
  const AddTopicView({super.key});

  static const routeName = "/add-topic";

  @override
  State<StatefulWidget> createState() => _AddTopicState();
}

class _AddTopicState extends State<AddTopicView> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  late TextEditingController _editTopicDescController, _editTopicNameController;

  bool _isNameEmpty = false, _isListContainEmpty = false, _isLoading = false;

  final List<Map<String, dynamic>> _listVocabu = List.generate(
    3,
    (index) => {
      "en": "",
      "vi": "",
    },
  );

  @override
  void initState() {
    _editTopicDescController = TextEditingController();
    _editTopicNameController = TextEditingController();
    super.initState();
  }

  void deleteFunc(index) {
    if (_listVocabu.length > 1) {
      _listVocabu.removeAt(index);
      builder(context, animation) {
        return _buildItem(index > 0 ? index - 1 : index, animation);
      }

      _listKey.currentState?.removeItem(index, builder);
    } else {
      return;
    }
  }

  Widget _buildItem(index, animation) {
    return Container(
      margin: const EdgeInsets.only(
        top: 12,
        bottom: 12,
      ),
      child: SizeTransition(
        sizeFactor: animation,
        child: Slidable(
          key: Key(_listVocabu[index]["en"]),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (context) => deleteFunc(index),
                backgroundColor: const Color(0xFFFE4A49),
                foregroundColor: Colors.white,
                icon: Icons.delete,
              ),
              SlidableAction(
                onPressed: (context) {
                  setState(() {
                    _listVocabu.insert(index + 1, {
                      "en": "",
                      "vi": "",
                    });
                  });

                  _listKey.currentState?.insertItem(index + 1);
                },
                backgroundColor: const Color(0xFF76ABAE),
                foregroundColor: Colors.white,
                icon: Icons.add,
              ),
            ],
          ),
          child: Container(
            color: const Color(0xFF222831),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  TextField(
                    controller: TextEditingController()..text = _listVocabu[index]["en"],
                    decoration: const InputDecoration(
                      hintText: "Word",
                      hintStyle: TextStyle(fontWeight: FontWeight.w400),
                      border: UnderlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _listVocabu[index]["en"] = value;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: TextEditingController()..text = _listVocabu[index]["vi"],
                    decoration: const InputDecoration(
                      hintText: "Definition",
                      hintStyle: TextStyle(fontWeight: FontWeight.w400),
                      border: UnderlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _listVocabu[index]["vi"] = value;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void createTopicSubmit() async {
    if (validateAdd()) {
      Topic newTopic = Topic(
        createdBy: FirebaseAuth.instance.currentUser!.uid,
        createdOn: DateTime.now(),
        status: "private",
        description: _editTopicDescController.text,
        topicName: _editTopicNameController.text,
        descriptionQuery: _editTopicDescController.text.toLowerCase(),
        topicNameQuery: _editTopicNameController.text.toLowerCase(),
        vocabularies: _listVocabu.map((e) {
          return {
            "en": e["en"],
            "vi": e["vi"],
            "vocabId": const Uuid().v4(),
          };
        }).toList(),
      );
      setState(() {
        _isLoading = true;
      });
      bool res = await createTopic(newTopic);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res ? "Topic created successfully!" : "Topic created failed, please try again!")));
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/vocab',
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  bool validateAdd() {
    bool isValidated = true;

    if (_editTopicNameController.text.isEmpty && _editTopicNameController.text == "") {
      setState(() {
        _isNameEmpty = true;
      });
      isValidated = false;
    } else {
      setState(() {
        _isNameEmpty = false;
      });
    }

    if (_listVocabu.firstWhereOrNull((element) => (element['vi'] == '' || element['en'] == '' || element['vi'].isEmpty || element['en'].isEmpty)) != null) {
      setState(() {
        _isListContainEmpty = true;
      });
      isValidated = false;
    } else {
      setState(() {
        _isListContainEmpty = false;
      });
    }

    return isValidated;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add new Topic"),
        actions: [
          IconButton(onPressed: createTopicSubmit, icon: const Icon(Icons.done)),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: _isLoading
              ? const Center(
                  child: Column(children: [CircularProgressIndicator(), Text("Adding Topic...")]),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Topic name",
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _editTopicNameController,
                          decoration: InputDecoration(
                            labelStyle: const TextStyle(
                              color: Colors.white,
                            ),
                            border: const OutlineInputBorder(),
                            hintText: 'Enter name',
                            errorText: _isNameEmpty ? "Please enter the topic name!" : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Topic description (Optional)",
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _editTopicDescController,
                          decoration: const InputDecoration(
                            labelStyle: TextStyle(
                              color: Colors.white,
                            ),
                            border: OutlineInputBorder(),
                            hintText: 'Enter description (optional)',
                          ),
                          maxLines: 4,
                          minLines: 4,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    TextButton(
                      onPressed: () async {
                        List<dynamic> vocabList = await VocabImportExport.instance!.importVocab();
                        setState(() {
                          _listVocabu.insertAll(0, vocabList.map((e) => {"en": e[0], "vi": e[1]}));
                          _listKey.currentState!.insertAllItems(0, vocabList.length);
                        });
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add,
                            color: Color(0xFF76ABAE),
                          ),
                          Text(
                            "Add via csv file",
                            style: TextStyle(
                              color: Color(0xFF76ABAE),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    _isListContainEmpty
                        ? Text(
                            "Please fill in all the card you created, or delete the empty cards!",
                            style: TextStyle(color: Colors.red[400]),
                          )
                        : Container(),
                    AnimatedList(
                      key: _listKey,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      initialItemCount: _listVocabu.length,
                      itemBuilder: (context, index, animation) {
                        return _buildItem(index, animation);
                      },
                    ),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF76ABAE),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
            bottomLeft: Radius.circular(30.0),
            bottomRight: Radius.circular(30.0),
          ),
        ),
        onPressed: () {
          setState(() {
            _listVocabu.add({
              "en": "",
              "vi": "",
            });
          });
          _listKey.currentState?.insertItem(_listVocabu.length - 1);
          Timer(
            const Duration(milliseconds: 300),
            () {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.ease,
              );
            },
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

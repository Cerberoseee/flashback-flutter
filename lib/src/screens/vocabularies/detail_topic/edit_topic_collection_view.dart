import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final/src/helper/vocab_import_export.dart';
import 'package:flutter_final/src/services/topics_services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:uuid/uuid.dart';

class EditTopicView extends StatefulWidget {
  final String id;
  final List<Map<String, dynamic>> vocabList;
  static const routeName = "/edit-topic";

  const EditTopicView({super.key, this.id = "", this.vocabList = const []});

  @override
  State<EditTopicView> createState() => _EditTopicViewState();
}

class _EditTopicViewState extends State<EditTopicView> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  bool _isListContainEmpty = false, _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _listVocabu = widget.vocabList;
    _listVocabu.addAll([
      {
        "en": "",
        "vi": "",
      },
      {
        "en": "",
        "vi": "",
      },
      {
        "en": "",
        "vi": "",
      }
    ]);
  }

  void submitData() async {
    bool isValidated = true;

    setState(() {
      _isSubmitting = true;
    });

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

    if (isValidated) {
      await patchTopic(widget.id, {
        "vocabularies": _listVocabu.map((e) {
          if (e["vocabId"] == null) {
            e["vocabId"] = const Uuid().v4();
          }
          return e;
        }).toList()
      }).then((res) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res ? "Topic updated successfully!" : "Something went wrong, please try again!")));
        Navigator.pop(context, true);
      });
    } else {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  List<Map<String, dynamic>> _listVocabu = [];

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

  void deleteFunc(index) {
    if (_listVocabu.length > 2) {
      _listVocabu.removeAt(index);
      builder(context, animation) {
        return _buildItem(index > 0 ? index - 1 : index, animation);
      }

      _listKey.currentState?.removeItem(index, builder);
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: const Color(0xFF222831),
        backgroundColor: const Color(0xFF222831),
        title: const Text(
          "Edit Collection",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _isSubmitting
                ? null
                : () {
                    submitData();
                  },
            icon: const Icon(Icons.done),
          )
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 64.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final/src/services/folders_services.dart';
import 'package:flutter_final/src/widgets/add_edit_dialogue.dart';
import 'package:flutter_final/src/widgets/vocab_list_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailFolderView extends StatefulWidget {
  final String id;
  static const routeName = '/folder';

  const DetailFolderView({super.key, this.id = ""});

  @override
  State<StatefulWidget> createState() => _DetailFolderState();
}

class _DetailFolderState extends State<DetailFolderView> {
  final _editFormKey = GlobalKey<FormState>();

  late TextEditingController _editFolderNameController, _editFolderDescController;
  bool _visibleStatus = false, _isLoading = false, _isDialogueLoading = false;

  @override
  void initState() {
    super.initState();
    _editFolderNameController = TextEditingController();
    _editFolderDescController = TextEditingController();
    fetchData();
  }

  Map<String, dynamic> _detailFolder = {};

  void fetchData() async {
    setState(() {
      _isLoading = true;
    });

    await getFolderDetail(widget.id).then((folder) async {
      if (folder != null) {
        if (mounted) {
          setState(() {
            _detailFolder = folder;
            _visibleStatus = folder["status"] == "public";
          });
          SharedPreferences prefs = await SharedPreferences.getInstance();

          List<String> recentFolderId = prefs.getStringList("recentFolderList") ?? [];
          recentFolderId = recentFolderId.toSet().toList();
          recentFolderId.add(_detailFolder["id"]);
          await prefs.setStringList("recentFolderList", recentFolderId.take(5).toList());
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Something went wrong, please try again!")));
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> showEditDialogue() async {
    await showDialog(
      context: context,
      builder: (ctxParent) => StatefulBuilder(
        builder: (ctx, setChildState) {
          return AlertDialog(
            title: const Text(
              "Edit Folder",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            content: SizedBox(
              width: 400,
              child: AddEditWidget(
                descriptionController: _editFolderDescController,
                nameController: _editFolderNameController,
                formKey: _editFormKey,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: _isDialogueLoading
                    ? null
                    : () async {
                        if (_editFormKey.currentState!.validate()) {
                          setChildState(() {
                            _isDialogueLoading = true;
                          });
                          setState(() {
                            _isDialogueLoading = true;
                          });
                          await patchFolder(_detailFolder["id"], {
                            "folderName": _editFolderNameController.text,
                            "description": _editFolderDescController.text,
                            "folderNameQuery": _editFolderNameController.text.toLowerCase(),
                            "descriptionQuery": _editFolderDescController.text.toLowerCase(),
                          }).then((res) {
                            setChildState(() {
                              _isDialogueLoading = false;
                            });
                            setState(() {
                              _isDialogueLoading = false;
                            });
                            if (res) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Folder edited successfully!")));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Folder edited failed, please try again!")));
                            }
                            Navigator.pop(ctx);
                            fetchData();
                          });
                          // _editFormKey.currentState.save();
                        }
                      },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _isDialogueLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator()) : Container(),
                    _isDialogueLoading ? const SizedBox(width: 12) : Container(),
                    const Text("Confirm"),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> showDelDialogue() async {
    await showDialog(
      context: context,
      builder: (ctxParent) => StatefulBuilder(
        builder: (ctx, setChildState) {
          return AlertDialog(
            title: const Text(
              "Delete Folder",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            content: const SizedBox(
              width: 400,
              child: Text("Are you sure you want to delete this folder? This action only delete the folder but not the topics within it."),
            ),
            actions: [
              TextButton(
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Color(0xFF76ABAE),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctxParent);
                },
              ),
              TextButton(
                onPressed: _isDialogueLoading
                    ? null
                    : () async {
                        setChildState(() {
                          _isDialogueLoading = true;
                        });
                        setState(() {
                          _isDialogueLoading = true;
                        });
                        await deleteFolder(_detailFolder["id"]).then((res) {
                          setChildState(() {
                            _isDialogueLoading = false;
                          });
                          setState(() {
                            _isDialogueLoading = false;
                          });
                          if (res) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Folder deleted successfully!")));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Folder deleted failed, please try again!")));
                          }
                          Navigator.pop(ctxParent);
                          Navigator.pop(context, true);
                        });
                      },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _isDialogueLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator()) : Container(),
                    _isDialogueLoading ? const SizedBox(width: 12) : Container(),
                    const Text("Confirm"),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> showDelTopicDialogue(topicId) async {
    await showDialog(
      context: context,
      builder: (ctxParent) => StatefulBuilder(
        builder: (ctx, setChildState) {
          return AlertDialog(
            title: const Text(
              "Remove Topic",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            content: const SizedBox(
              width: 400,
              child: Text("Are you sure you want to remove this topic from this folder?"),
            ),
            actions: [
              TextButton(
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Color(0xFF76ABAE),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctxParent);
                },
              ),
              TextButton(
                onPressed: _isDialogueLoading
                    ? null
                    : () async {
                        setChildState(() {
                          _isDialogueLoading = true;
                        });
                        setState(() {
                          _isDialogueLoading = true;
                        });
                        List<dynamic> updatedList = (_detailFolder["topics"] as List<dynamic>).map((e) => e["id"]).toList();
                        updatedList.removeWhere((item) => item == topicId);
                        await patchFolder(_detailFolder["id"], {
                          "topics": updatedList,
                        }).then((res) {
                          setChildState(() {
                            _isDialogueLoading = false;
                          });
                          setState(() {
                            _isDialogueLoading = false;
                          });
                          if (res) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Topic removed successfully!")));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Folder removed failed, please try again!")));
                          }
                          Navigator.pop(ctxParent);
                          fetchData();
                        });
                      },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _isDialogueLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator()) : Container(),
                    _isDialogueLoading ? const SizedBox(width: 12) : Container(),
                    const Text("Confirm"),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> showVisibleDialogue() async {
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateChild) {
          return AlertDialog(
            title: const Text(
              "Set Folder Visibility",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RadioListTile(
                  value: true,
                  groupValue: _visibleStatus,
                  title: const Row(children: [Icon(Icons.people_outline), SizedBox(width: 12), Text("Public")]),
                  controlAffinity: ListTileControlAffinity.trailing,
                  onChanged: (value) {
                    setStateChild(() {
                      _visibleStatus = value ?? true;
                    });
                    setState(() {
                      _visibleStatus = value ?? true;
                    });
                  },
                ),
                RadioListTile(
                  value: false,
                  groupValue: _visibleStatus,
                  title: const Row(children: [Icon(Icons.lock_rounded), SizedBox(width: 12), Text("Private")]),
                  controlAffinity: ListTileControlAffinity.trailing,
                  onChanged: (value) {
                    setStateChild(() {
                      _visibleStatus = value ?? false;
                    });
                    setState(() {
                      _visibleStatus = value ?? false;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text(
                  "Close",
                  style: TextStyle(
                    color: Color(0xFF76ABAE),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      ),
    ).then((value) async {
      setState(() {
        _isLoading = true;
      });
      await patchFolder(_detailFolder["id"], {"status": _visibleStatus ? "public" : "private"}).then((res) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        if (res) {
          ScaffoldMessenger.of(context).showSnackBar((const SnackBar(content: Text("Folder visiblity changed!"))));
        } else {
          ScaffoldMessenger.of(context).showSnackBar((const SnackBar(content: Text("Folder visiblity change failed, please try again!"))));
        }
      });
    });
  }

  void showBottomModalSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                    title: const Text("Edit"),
                    onTap: () {
                      Navigator.pop(context);
                      _editFolderNameController.text = _detailFolder["folderName"] ?? "";
                      _editFolderDescController.text = _detailFolder["description"] ?? "";
                      showEditDialogue();
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    title: const Text("Delete"),
                    onTap: () {
                      Navigator.pop(context);
                      showDelDialogue();
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.language,
                      color: Colors.white,
                    ),
                    title: const Text("Set visibility"),
                    onTap: () {
                      Navigator.pop(context);
                      showVisibleDialogue();
                    },
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print(_detailFolder["createdBy"]);
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: const Color(0xFF222831),
        backgroundColor: const Color(0xFF222831),
        elevation: 10.0,
        shadowColor: const Color(0xFF000000),
        title: Text(
          "Folder",
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 24,
          ),
        ),
        actions: [
          !_isLoading && FirebaseAuth.instance.currentUser!.uid == _detailFolder["createdBy"]["id"]
              ? IconButton(
                  onPressed: () {
                    showBottomModalSheet();
                  },
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                )
              : Container(),
        ],
      ),
      body: _isLoading
          ? const Column(
              mainAxisSize: MainAxisSize.max,
              children: [Expanded(child: Center(child: CircularProgressIndicator()))],
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(12.0, 24.0, 12.0, 24.0),
                    decoration: const BoxDecoration(
                      color: Color(0xFF222831),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 16,
                              backgroundImage: _detailFolder["createdBy"]["avatarUrl"] != null
                                  ? NetworkImage(_detailFolder["createdBy"]["avatarUrl"])
                                  : const AssetImage(kIsWeb ? "images/default-avatar.png" : "assets/images/topic_empty.png") as ImageProvider,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: Text(
                                _detailFolder["createdBy"]["username"],
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              DateFormat('yyyy/MM/dd').format(DateTime.parse(_detailFolder["createdOn"])),
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _detailFolder["folderName"],
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _detailFolder["description"],
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${_detailFolder["topics"] != null ? _detailFolder["topics"].length : 0} topic${(_detailFolder["topics"].length > 1 && _detailFolder["topics"].length != null) ? "s" : ""}",
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        FirebaseAuth.instance.currentUser!.uid == _detailFolder["createdBy"]["id"]
                            ? ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(const Color(0xFF76ABAE)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "Add topic",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                onPressed: () async {
                                  if (await Navigator.of(context).pushNamed("/add-topic-to-folder", arguments: {
                                        "folderId": _detailFolder["id"],
                                        "topicList": _detailFolder["topics"].map((e) => e["id"]).toList(),
                                      }) ==
                                      true) {
                                    fetchData();
                                  }
                                },
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  SizedBox(
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _detailFolder["topics"].length,
                        itemBuilder: (context, index) {
                          return VocabListWidget(
                            isDeletable: true,
                            deleteFunc: (context) {
                              showDelTopicDialogue(_detailFolder['topics'][index]["id"]);
                            },
                            onTap: () async {
                              var res = await Navigator.pushNamed(context, '/topic', arguments: {"id": _detailFolder['topics'][index]["id"]});
                              if (res != null) {
                                fetchData();
                              }
                            },
                            title: _detailFolder["topics"][index]["topicName"],
                            description: _detailFolder["topics"][index]["description"],
                            icon: const Icon(Icons.book),
                            userName: _detailFolder["topics"][index]["createdBy"]["username"],
                            imgAvatar: _detailFolder["topics"][index]["createdBy"]["avatarUrl"],

                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_final/src/widgets/add_edit_dialogue.dart';
import 'package:flutter_final/src/widgets/vocab_list_widget.dart';
import 'package:google_fonts/google_fonts.dart';

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
  bool _visibleStatus = false;

  @override
  void initState() {
    super.initState();
    _editFolderNameController = TextEditingController();
    _editFolderDescController = TextEditingController();
  }

  final Map<String, dynamic> _detailFolder = const {
    "id": "1",
    "folderName": "Test",
    "description": "Test description",
    "createdBy": {
      "username": "test",
      "avatarUrl": "",
    },
    "topics": [
      {
        "id": "1",
        "topicName": "Test",
        "description": "test description",
        "createdBy": {
          "username": "test",
          "avatarUrl": "",
        },
        "createdOn": "30/03/2023"
      },
      {
        "id": "1",
        "topicName": "Test",
        "description": "test description",
        "createdBy": {
          "username": "test",
          "avatarUrl": "",
        },
        "createdOn": "30/03/2023"
      },
      {
        "id": "1",
        "topicName": "Test",
        "description": "test description",
        "createdBy": {
          "username": "test",
          "avatarUrl": "",
        },
        "createdOn": "30/03/2023"
      },
      {
        "id": "1",
        "topicName": "Test",
        "description": "test description",
        "createdBy": {
          "username": "test",
          "avatarUrl": "",
        },
        "createdOn": "30/03/2023"
      },
    ],
    "createdOn": "30/03/2023"
  };

  Future<void> showEditDialogue() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text("Confirm"),
            onPressed: () {
              if (_editFormKey.currentState!.validate()) {
                //edit api service goes here
                Navigator.pop(context);
                // _editFormKey.currentState.save();
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> showDelDialogue() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text(
              "Confirm",
              style: TextStyle(
                color: Color(0xFF76ABAE),
              ),
            ),
            onPressed: () {
              //edit api service goes here
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> showDelTopicDialogue(context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Delete Folder",
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
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text(
              "Confirm",
              style: TextStyle(
                color: Color(0xFF76ABAE),
              ),
            ),
            onPressed: () {
              //edit api service goes here
              Navigator.pop(context);
            },
          ),
        ],
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
                      _visibleStatus = value ?? true;
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
    );
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
          IconButton(
            onPressed: () {
              showBottomModalSheet();
            },
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
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
                        backgroundImage:
                            _detailFolder["createdBy"]["avatarUrl"] != "" ? NetworkImage(_detailFolder["createdBy"]["avatarUrl"]) : const AssetImage("/images/default-avatar.png") as ImageProvider,
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
                        _detailFolder["createdOn"],
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
                    "${_detailFolder["topics"] != null ? _detailFolder["topics"].length : 0} topic${(_detailFolder["topics"].length > 1 || _detailFolder["topics"].length != null) ? "s" : ""}",
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  ElevatedButton(
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
                    onPressed: () {},
                  )
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
                      deleteFunc: showDelTopicDialogue,
                      onTap: () {
                        Navigator.pushNamed(context, '/topic', arguments: {"id": _detailFolder['topics'][index]["id"]});
                      },
                      title: _detailFolder["topics"][index]["topicName"],
                      description: _detailFolder["topics"][index]["description"],
                      icon: const Icon(Icons.book),
                      userName: _detailFolder["topics"][index]["createdBy"]["username"],
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

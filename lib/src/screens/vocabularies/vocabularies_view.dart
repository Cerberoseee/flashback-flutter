import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final/src/models/folder_model.dart';
import 'package:flutter_final/src/services/folders_services.dart';
import 'package:flutter_final/src/services/topics_services.dart';
import 'package:flutter_final/src/widgets/add_edit_dialogue.dart';
import 'package:flutter_final/src/widgets/app_bar_widget.dart';
import 'package:flutter_final/src/widgets/bottom_navi_widget.dart';
import 'package:flutter_final/src/widgets/vocab_list_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';

class VocabView extends StatefulWidget {
  const VocabView({super.key});
  static const routeName = '/vocab';

  @override
  State<StatefulWidget> createState() => _VocabViewState();
}

class _VocabViewState extends State<VocabView> with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  late TextEditingController _addFolderNameController, _addFolderDescController;
  final GlobalKey<FormState> _addFormKey = GlobalKey();
  bool _isLoading = false, _isDialogueLoading = false;

  Future<void> showDelTopicDialogue(topicId) async {
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (childCtx, setChildState) {
          return AlertDialog(
            title: const Text(
              "Delete Topic",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            content: const SizedBox(
              width: 400,
              child: Text("Are you sure you want to delete this topic?"),
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
                  Navigator.pop(ctx);
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
                        await deleteTopic(topicId).then((result) {
                          setChildState(() {
                            _isDialogueLoading = false;
                          });
                          setState(() {
                            _isDialogueLoading = false;
                          });

                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result ? "Topic deleted successfully!" : "Topic deleted failed, please try again!"),
                            ),
                          );
                          fetchData();
                        });
                      },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _isDialogueLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator()) : Container(),
                    _isDialogueLoading ? const SizedBox(width: 12) : Container(),
                    const Text(
                      "Confirm",
                      style: TextStyle(
                        color: Color(0xFF76ABAE),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> showDelFolderDialogue(folderId) async {
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (childCtx, setChildState) {
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
                  Navigator.pop(ctx);
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
                        await deleteFolder(folderId).then((result) {
                          setChildState(() {
                            _isDialogueLoading = false;
                          });
                          setState(() {
                            _isDialogueLoading = false;
                          });

                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result ? "Folder deleted successfully!" : "Folder deleted failed, please try again!"),
                            ),
                          );
                          fetchData();
                        });
                      },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _isDialogueLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator()) : Container(),
                    _isDialogueLoading ? const SizedBox(width: 12) : Container(),
                    const Text(
                      "Confirm",
                      style: TextStyle(
                        color: Color(0xFF76ABAE),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _folders = [];
  //  final List<Map<String, dynamic>> _folders = const [
  //   {
  //     "id": "1",
  //     "folderName": "Test",
  //     "description": "test description",
  //     "createdBy": {
  //       "username": "test",
  //       "avatarUrl": "",
  //     },
  //     "createdOn": "30/03/2023"
  //   },
  //   {
  //     "id": "1",
  //     "folderName": "Test",
  //     "description": "test description",
  //     "createdBy": {
  //       "username": "test",
  //       "avatarUrl": "",
  //     },
  //     "createdOn": "30/03/2023"
  //   },
  //   {
  //     "id": "1",
  //     "folderName": "Test",
  //     "description": "test description",
  //     "createdBy": {
  //       "username": "test",
  //       "avatarUrl": "",
  //     },
  //     "createdOn": "30/03/2023"
  //   },
  //   {
  //     "id": "1",
  //     "folderName": "Test",
  //     "description": "test description",
  //     "createdBy": {
  //       "username": "test",
  //       "avatarUrl": "",
  //     },
  //     "createdOn": "30/03/2023"
  //   },
  //   {
  //     "id": "1",
  //     "folderName": "Test",
  //     "description": "test description",
  //     "createdBy": {
  //       "username": "test",
  //       "avatarUrl": "",
  //     },
  //     "createdOn": "30/03/2023"
  //   },
  //   {
  //     "id": "1",
  //     "folderName": "Test",
  //     "description": "test description",
  //     "createdBy": {
  //       "username": "test",
  //       "avatarUrl": "",
  //     },
  //     "createdOn": "30/03/2023"
  //   },
  // ];

  // List<Map<String, dynamic>> _topics = const [
  //   {
  //     "id": "1",
  //     "topicName": "Test",
  //     "description": "test description",
  //     "createdBy": {
  //       "username": "test",
  //       "avatarUrl": "",
  //     },
  //     "createdOn": "30/03/2023"
  //   },
  //   {
  //     "id": "1",
  //     "topicName": "Test",
  //     "description": "test description",
  //     "createdBy": {
  //       "username": "test",
  //       "avatarUrl": "",
  //     },
  //     "createdOn": "30/03/2023"
  //   },
  //   {
  //     "id": "1",
  //     "topicName": "Test",
  //     "description": "test description",
  //     "createdBy": {
  //       "username": "test",
  //       "avatarUrl": "",
  //     },
  //     "createdOn": "30/03/2023"
  //   },
  //   {
  //     "id": "1",
  //     "topicName": "Test",
  //     "description": "test description",
  //     "createdBy": {
  //       "username": "test",
  //       "avatarUrl": "",
  //     },
  //     "createdOn": "30/03/2023"
  //   },
  //   {
  //     "id": "1",
  //     "topicName": "Test",
  //     "description": "test description",
  //     "createdBy": {
  //       "username": "test",
  //       "avatarUrl": "",
  //     },
  //     "createdOn": "30/03/2023"
  //   },
  //   {
  //     "id": "1",
  //     "topicName": "Test",
  //     "description": "test description",
  //     "createdBy": {
  //       "username": "test",
  //       "avatarUrl": "",
  //     },
  //     "createdOn": "30/03/2023"
  //   },
  // ];
  List<Map<String, dynamic>> _topics = [];
  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController();
    _addFolderNameController = TextEditingController();
    _addFolderDescController = TextEditingController();

    fetchData();
    super.initState();
  }

  void fetchData() async {
    _tabController.index = 0;
    setState(() {
      _isLoading = true;
    });
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      String? userEmail = FirebaseAuth.instance.currentUser?.email;

      if (userEmail != null && userId != null) {
        List<Map<String, dynamic>> fetchFolder = await getUserFolder(userId, userEmail, 30);
        List<Map<String, dynamic>> fetchTopic = await getUserTopic(userId, userEmail, 30);
        if (mounted) {
          setState(() {
            _folders = fetchFolder;
            _topics = fetchTopic;
            _isLoading = false;
          });
        }
      }
      print(_topics);
    } catch (e) {
      Logger().e('Error fetching data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void showAddDialogue() async {
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (childCtx, setChildState) {
          return AlertDialog(
            title: const Text(
              "Add Folder",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            content: SizedBox(
              width: 400,
              child: AddEditWidget(
                descriptionController: _addFolderDescController,
                nameController: _addFolderNameController,
                formKey: _addFormKey,
              ),
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
                  Navigator.pop(ctx);
                },
              ),
              TextButton(
                onPressed: _isDialogueLoading
                    ? null
                    : () async {
                        if (_addFormKey.currentState!.validate()) {
                          Folder newFolder = Folder(
                            createdBy: FirebaseAuth.instance.currentUser!.uid,
                            createdOn: DateTime.now(),
                            description: _addFolderDescController.text,
                            descriptionQuery: _addFolderDescController.text.toLowerCase(),
                            folderName: _addFolderNameController.text,
                            folderNameQuery: _addFolderNameController.text.toLowerCase(),
                            status: "private",
                            topic: [],
                          );
                          setChildState(() {
                            _isDialogueLoading = true;
                          });
                          setState(() {
                            _isDialogueLoading = true;
                          });
                          await createFolder(newFolder).then((result) {
                            setChildState(() {
                              _isDialogueLoading = false;
                            });
                            setState(() {
                              _isDialogueLoading = false;
                            });
                            _addFolderDescController.text = "";
                            _addFolderNameController.text = "";
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result ? "Folder created successfully!" : "Folder created failed, please try again!"),
                              ),
                            );
                            fetchData();
                          });
                          // _editFormKey.currentState.save();
                        }
                      },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _isDialogueLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator()) : Container(),
                    _isDialogueLoading ? const SizedBox(width: 12) : Container(),
                    const Text(
                      "Confirm",
                      style: TextStyle(
                        color: Color(0xFF76ABAE),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void toggleBottomModal() {
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
                      Icons.folder,
                      color: Colors.white,
                    ),
                    title: const Text("Add new Folder"),
                    onTap: () {
                      Navigator.pop(context);
                      showAddDialogue();
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.book,
                      color: Colors.white,
                    ),
                    title: const Text("Add new Topic"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, "/add-topic");
                    },
                  )
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
  Widget build(BuildContext buildContext) {
    return Scaffold(
      appBar: AppBarWidget(
        actionList: [
          IconButton(
            onPressed: () {
              toggleBottomModal();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Vocabulary 🔤",
                    style: GoogleFonts.roboto(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFEEEEEE),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  TabBar(
                    indicatorColor: const Color(0xFF76ABAE),
                    labelColor: const Color(0xFF76ABAE),
                    controller: _tabController,
                    onTap: (index) {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(
                          milliseconds: 500,
                        ),
                        curve: Curves.ease,
                      );
                    },
                    tabs: const [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder),
                            SizedBox(width: 6.0),
                            Text("Folders"),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.book),
                            SizedBox(width: 6.0),
                            Text("Topics"),
                          ],
                        ),
                      )
                    ],
                  ),
                  Expanded(
                    flex: 1,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (value) {
                        _tabController.animateTo(
                          value,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      },
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(6),
                          child: _folders.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 128,
                                        height: 128,
                                        child: Image.asset("images/folder_empty.png"),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        "No Folder found",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 24,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const Text(
                                        "Create your own folders by pressing the icon on top right corner",
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  separatorBuilder: (context, index) => const Divider(),
                                  itemCount: _folders.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: const EdgeInsets.only(
                                        top: 6,
                                        bottom: 6,
                                      ),
                                      child: VocabListWidget(
                                        onTap: () async {
                                          var res = await Navigator.pushNamed(context, '/folder', arguments: {"id": _folders[index]["id"]});
                                          if (res == true) {
                                            fetchData();
                                          }
                                        },
                                        title: _folders[index]["folderName"],
                                        description: _folders[index]["description"],
                                        icon: const Icon(Icons.folder),
                                        userName: _folders[index]["createdBy"]["username"],
                                        imgAvatar: _folders[index]["createdBy"]["avatarUrl"],
                                        isDeletable: true,
                                        deleteFunc: (ctx) => showDelFolderDialogue(_folders[index]['id']),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          child: _topics.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 128,
                                        height: 128,
                                        child: Image.asset("images/topic_empty.png"),
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
                                      const Text(
                                        "Create your own topics by pressing the icon on top right corner",
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  separatorBuilder: (context, index) => const Divider(),
                                  itemCount: _topics.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: const EdgeInsets.only(
                                        top: 6,
                                        bottom: 6,
                                      ),
                                      child: VocabListWidget(
                                        onTap: () async {
                                          var res = await Navigator.pushNamed(context, '/topic', arguments: {"id": _topics[index]["id"]});
                                          if (res == true) {
                                            fetchData();
                                          }
                                        },
                                        title: _topics[index]["topicName"],
                                        description: _topics[index]["description"],
                                        icon: const Icon(Icons.book),
                                        userName: _topics[index]["createdBy"]["username"],
                                        imgAvatar: _topics[index]["createdBy"]["avatarUrl"],
                                        isDeletable: true,
                                        deleteFunc: (ctx) => showDelTopicDialogue(_topics[index]["id"]),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNaviBar(
        index: 1,
      ),
    );
  }
}

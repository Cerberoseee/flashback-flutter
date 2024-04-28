import 'package:flutter/material.dart';
import 'package:flutter_final/src/services/folders_services.dart';
import 'package:flutter_final/src/widgets/add_edit_dialogue.dart';
import 'package:flutter_final/src/widgets/app_bar_widget.dart';
import 'package:flutter_final/src/widgets/bottom_navi_widget.dart';
import 'package:flutter_final/src/widgets/vocab_list_widget.dart';
import 'package:google_fonts/google_fonts.dart';

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

  Future<void> showDelTopicDialogue(context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
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

  Future<void> showDelFolderDialogue(context) async {
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

  List<Map<String, dynamic>> _folders = [];
  Future<void> _loadFolders() async {
    _folders = await getAllFolder();
    setState(() {});
  }
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

  final List<Map<String, dynamic>> _topics = const [
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
  ];

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController();
    _addFolderNameController = TextEditingController();
    _addFolderDescController = TextEditingController();

    _loadFolders();
    super.initState();
  }

  void showAddDialogue() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              if (_addFormKey.currentState!.validate()) {
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
      body: Container(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Vocabulary",
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
                    child: ListView.separated(
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: _folders.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(
                            top: 6,
                            bottom: 6,
                          ),
                          child: VocabListWidget(
                            onTap: () {
                              Navigator.pushNamed(context, '/folder', arguments: {"id": _folders[index]["id"]});
                            },
                            title: _folders[index]["folderName"],
                            description: _folders[index]["description"],
                            icon: const Icon(Icons.folder),
                            userName: _folders[index]["createdBy"]["username"],
                            // userName: _folders[index]["createdBy"] is Map<String, dynamic>
                            //           ? _folders[index]["createdBy"]["username"]
                            //           : "Unknown User",

                            // imgAvatar: _folders[index]["createdBy"] is Map<String, dynamic>
                            //           ? _folders[index]["createdBy"]["avatarUrl"]
                            //           : "Unknown IMG",
                            imgAvatar: _folders[index]["createdBy"]["avatarUrl"],
                            isDeletable: true,
                            deleteFunc: (ctx) => showDelFolderDialogue(buildContext),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    child: ListView.separated(
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: _topics.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(
                            top: 6,
                            bottom: 6,
                          ),
                          child: VocabListWidget(
                            onTap: () {
                              Navigator.pushNamed(context, '/topic', arguments: {"id": _topics[index]["id"]});
                            },
                            title: _topics[index]["topicName"],
                            description: _topics[index]["description"],
                            icon: const Icon(Icons.book),
                            userName: _topics[index]["createdBy"]["username"],
                            isDeletable: true,
                            deleteFunc: (ctx) => showDelTopicDialogue(buildContext),
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

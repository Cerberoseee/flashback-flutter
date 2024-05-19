import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_final/src/services/folders_services.dart';
import 'package:flutter_final/src/services/topics_services.dart';
import 'package:flutter_final/src/widgets/vocab_list_widget.dart';

class CommunitySearchView extends StatefulWidget {
  const CommunitySearchView({super.key});
  static const routeName = "/community-search";

  @override
  State<StatefulWidget> createState() => _CommunitySearchState();
}

class _CommunitySearchState extends State<CommunitySearchView> with TickerProviderStateMixin {
  late TextEditingController _searchController;
  late TabController _tabController;
  late PageController _pageController;

  bool _isLoading = false;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController();
  }

  List<Map<String, dynamic>> _folders = [];
  List<Map<String, dynamic>> _topics = [];

  // final List<Map<String, dynamic>> _folders = const [
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

  // final List<Map<String, dynamic>> _topics = const [
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

  Future<void> fetchApi(term) async {
    setState(() {
      _isLoading = true;
    });

    List<Map<String, dynamic>> fetchFolder = await searchFolder(30, term);
    List<Map<String, dynamic>> fetchTopic = await searchTopic(30, term);

    if (mounted) {
      setState(() {
        _folders = fetchFolder;
        _topics = fetchTopic;
        _isLoading = false;
      });
    }
  }

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchApi(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search for something... 🔍',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            _onSearchChanged(value);
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  child: Text("Folders"),
                ),
                Tab(
                  child: Text("Topics"),
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
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Container(
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
                                  userName: _folders[index]["createdBy"]["username"] ?? "",
                                  imgAvatar: _folders[index]["createdBy"]["avatarUrl"] ?? "",
                                  isDeletable: false,
                                ),
                              );
                            },
                          ),
                        ),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Container(
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
                                  userName: _topics[index]["createdBy"]["username"] ?? "",
                                  imgAvatar: _topics[index]["createdBy"]["avatarUrl"] ?? "",
                                  isDeletable: false,
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
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final/src/services/folders_services.dart';
import 'package:logger/logger.dart';

class AddToFolder extends StatefulWidget {
  final String topicId;

  static const routeName = "/add-to-folder";

  const AddToFolder({required this.topicId, super.key});

  @override
  State<StatefulWidget> createState() => _AddToFolderState();
}

class _AddToFolderState extends State<AddToFolder> {
  bool _isLoading = false;

  List<Map<String, dynamic>> _folders = [];

  Future<void> _fetchData() async {
    String? userId = FirebaseAuth.instance.currentUser!.uid;
    String? userEmail = FirebaseAuth.instance.currentUser!.email ?? "";

    setState(() {
      _isLoading = true;
    });

    List<Map<String, dynamic>> fetchFolder = await getUserFolder(userId, userEmail, 5);
    // if (fetchFolder.isNotEmpty) {
    //   fetchFolder.add(fetchFolder[0]);
    //   fetchFolder.add(fetchFolder[0]);
    //   fetchFolder.add(fetchFolder[0]);
    //   fetchFolder.add(fetchFolder[0]);
    // }

    fetchFolder = fetchFolder.map((e) {
      return {...e, 'isSelected': false};
    }).toList();

    if (mounted) {
      setState(() {
        _folders = fetchFolder;
        _isLoading = false;
      });
    }
  }

  Future<void> addToFolder() async {
    List<dynamic> temp = _folders;
    List<dynamic> selectedFolder = temp.where((element) => element['isSelected']).toList();
    Logger().i(selectedFolder);
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
            onPressed: () {
              addToFolder();
            },
            icon: const Icon(Icons.done),
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _folders.isEmpty
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
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil('/vocab', (Route<dynamic> route) => false);
                        },
                        child: const Text(
                          "Press here to manage your folder",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemBuilder: (context, index) {
                    return CheckboxListTile(
                      value: _folders[index]["isSelected"],
                      checkColor: Colors.white,
                      onChanged: (bool? value) {
                        setState(() {
                          _folders[index]["isSelected"] = value!;
                        });
                      },
                      title: Text(_folders[index]["folderName"] ?? ""),
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: _folders.length,
                ),
    );
  }
}

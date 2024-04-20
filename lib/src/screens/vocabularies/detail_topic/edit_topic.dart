import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EditTopicView extends StatefulWidget {
  final String id;
  static const routeName = "/edit_topic";
  
  const EditTopicView({super.key, this.id = ""});

  @override
  State<EditTopicView> createState() => _EditTopicViewState();
}

class _EditTopicViewState extends State<EditTopicView> {
  TextEditingController _collectionController = TextEditingController();
  TextEditingController _describeController = TextEditingController();

  List<Map<String, dynamic>> _listVocabu = List.generate(
    2,
    (index) => {
      "en": "Collection ${index + 1}",
      "vi": "Collection ${index + 1}",
    },
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        surfaceTintColor: const Color(0xFF222831),
        backgroundColor: const Color(0xFF222831),
        title: Text(
          "Edit Collection",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Handle save button pressed
            },
            icon: const Icon(Icons.done),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _collectionController,
              decoration: InputDecoration(
                hintText: "Edit Collection",
                border: UnderlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _describeController,
              decoration: InputDecoration(
                hintText: "Edit Mô tả",
                border: UnderlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _listVocabu.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(_listVocabu[index]["en"]),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.delete, color: Colors.white,),                 
                  ),
                  onDismissed: (direction) {
                    setState(() {
                      if(_listVocabu.length >2){
                        _listVocabu.removeAt(index);
                      }
                      else{
                        return;
                      }
                    });
                  },
                  child: Column(
                    children: [
                      Container(
                        color: Colors.brown,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              TextField(
                                decoration: InputDecoration(
                                  hintText: "Edit Thuật ngữ",
                                  border: UnderlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  _listVocabu[index]["en"] = value;
                                },
                              ),
                              SizedBox(height: 20),
                              TextField(
                                decoration: InputDecoration(
                                  hintText: "Edit Định nghĩa",
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
                      SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: (){
                setState(() {
                  _listVocabu.add({
                      "en": "New Collection",
                      "vi": "New Collection",
                    });
                });
              }, icon: Icon(Icons.add))
            ],
          ),
        ),
      ),
    );
  }
}

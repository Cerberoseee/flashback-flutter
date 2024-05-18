import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final/src/services/topics_services.dart';

class LeaderboardView extends StatefulWidget {
  final String topicId;

  static const routeName = "/topic-leaderboard";

  const LeaderboardView({
    super.key,
    this.topicId = "",
  });
  @override
  State<StatefulWidget> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<LeaderboardView> {
  bool _isLoading = false;

  List<dynamic> userList = [
    // {
    //   "userName": "Lorem ipsum",
    //   "attempt": 1,
    //   "correctAnswer": 10,
    //   "timeDone": 200,
    //   "avatarUrl": 'https://randomuser.me/api/portraits/women/1.jpg',
    // },
    // {
    //   "userName": "Lorem ipsum1",
    //   "attempt": 6,
    //   "correctAnswer": 16,
    //   "timeDone": 300,
    //   "avatarUrl": 'https://randomuser.me/api/portraits/women/2.jpg',
    // },
    // {
    //   "userName": "Lorem ipsum2",
    //   "attempt": 3,
    //   "correctAnswer": 17,
    //   "timeDone": 400,
    //   "avatarUrl": 'https://randomuser.me/api/portraits/women/3.jpg',
    // },
    // {
    //   "userName": "Lorem ipsum3",
    //   "attempt": 2,
    //   "correctAnswer": 4,
    //   "timeDone": 700,
    //   "avatarUrl": 'https://randomuser.me/api/portraits/women/4.jpg',
    // },
    // {
    //   "userName": "Lorem ipsum4",
    //   "attempt": 5,
    //   "correctAnswer": 10,
    //   "timeDone": 100,
    //   "avatarUrl": 'https://randomuser.me/api/portraits/women/5.jpg',
    // },
  ];

  Future<void> fetchDate() async {
    setState(() {
      _isLoading = true;
    });

    await getAllScore(widget.topicId).then((res) {
      res.sort((a, b) {
        if (a['correctAnswer'] as int != b['correctAnswer'] as int) {
          return (b['correctAnswer'] as int).compareTo(a['correctAnswer'] as int);
        } else if (a['timeDone'] as int != b['timeDone'] as int) {
          return (a['timeDone'] as int).compareTo(b['timeDone'] as int);
        } else {
          return (b['attempt'] as int).compareTo(a['attempt'] as int);
        }
      });
      setState(() {
        userList = res;
        _isLoading = false;
      });
      print(userList);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leaderboard"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(36, 12, 24, 36),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 36, right: 36),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "USER",
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xFF8A8A8A),
                            ),
                          ),
                          Text(
                            "POINTS",
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xFF8A8A8A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: userList.length,
                      itemBuilder: (context, index) {
                        String minuteElapsed = (Duration(seconds: userList[index]["timeDone"]).inMinutes).toString().padLeft(2, '0');
                        String secondElapsed = (Duration(seconds: userList[index]["timeDone"]).inSeconds % 60).toString().padLeft(2, '0');
                        return Container(
                          margin: const EdgeInsets.only(
                            top: 12,
                            bottom: 12,
                            right: 12,
                          ),
                          child: ListTile(
                            contentPadding: index == 0 ? const EdgeInsets.only(left: 12, right: 12) : const EdgeInsets.only(left: 24, right: 24),
                            tileColor: index == 0 ? const Color(0xFF76ABAE) : null,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12.0),
                              ),
                            ),
                            leading: SizedBox(
                              width: 90,
                              height: 90,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "${index + 1}.",
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  CircleAvatar(
                                    radius: 32,
                                    backgroundImage: userList[index]["user"]["avatarUrl"] != null
                                        ? NetworkImage(userList[index]["user"]["avatarUrl"])
                                        : const AssetImage(kIsWeb ? "images/default-avatar.png" : "assets/images/default-avatar.png") as ImageProvider,
                                  ),
                                ],
                              ),
                            ),
                            title: Text(userList[index]["user"]["username"]),
                            trailing: Text(
                              userList[index]["correctAnswer"].toString(),
                              style: TextStyle(
                                fontSize: 16,
                                color: index == 0 ? Colors.white : const Color(0xFFABABAB),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Time Elapsed: $minuteElapsed:$secondElapsed",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: index == 0 ? Colors.white : const Color(0xFFABABAB),
                                  ),
                                ),
                                Text(
                                  "Attempt: ${userList[index]["attempt"].toString()}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: index == 0 ? Colors.white : const Color(0xFFABABAB),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
        ),
      ),
    );
  }
}

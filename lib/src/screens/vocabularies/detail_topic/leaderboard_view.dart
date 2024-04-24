import 'package:flutter/material.dart';

class LeaderboardView extends StatefulWidget {
  final List<Map<String, dynamic>> userList;

  static const routeName = "/topic-leaderboard";

  const LeaderboardView({
    super.key,
    this.userList = const [],
  });
  @override
  State<StatefulWidget> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<LeaderboardView> {
  List<Map<String, dynamic>> userList = [
    {
      "userName": "Lorem ipsum",
      "attemp": 1,
      "correct_answer": 10,
      "time_done": 200,
      "avatarUrl": 'https://randomuser.me/api/portraits/women/1.jpg',
    },
    {
      "userName": "Lorem ipsum1",
      "attemp": 6,
      "correct_answer": 16,
      "time_done": 300,
      "avatarUrl": 'https://randomuser.me/api/portraits/women/2.jpg',
    },
    {
      "userName": "Lorem ipsum2",
      "attemp": 3,
      "correct_answer": 17,
      "time_done": 400,
      "avatarUrl": 'https://randomuser.me/api/portraits/women/3.jpg',
    },
    {
      "userName": "Lorem ipsum3",
      "attemp": 2,
      "correct_answer": 4,
      "time_done": 700,
      "avatarUrl": 'https://randomuser.me/api/portraits/women/4.jpg',
    },
    {
      "userName": "Lorem ipsum4",
      "attemp": 5,
      "correct_answer": 10,
      "time_done": 100,
      "avatarUrl": 'https://randomuser.me/api/portraits/women/5.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    userList.sort((a, b) {
      if (a['correct_answer'] != b['correct_answer']) {
        return b['correct_answer'].compareTo(a['correct_answer']);
      } else if (a['time_done'] != b['time_done']) {
        return a['time_done'].compareTo(b['time_done']);
      } else {
        return b['attemp'].compareTo(a['attemp']);
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leaderboard"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(36, 12, 24, 36),
          child: Column(
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
                  String minuteElapsed = (Duration(seconds: userList[index]["time_done"]).inMinutes).toString().padLeft(2, '0');
                  String secondElapsed = (Duration(seconds: userList[index]["time_done"]).inSeconds % 60).toString().padLeft(2, '0');
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
                              backgroundImage: userList[index]["avatarUrl"] != null ? NetworkImage(userList[index]["avatarUrl"]) : const AssetImage("/images/default-avatar.png") as ImageProvider,
                            ),
                          ],
                        ),
                      ),
                      title: Text(userList[index]["userName"]),
                      trailing: Text(
                        userList[index]["correct_answer"].toString(),
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
                              color: index == 0 ? Colors.white : Color(0xFFABABAB),
                            ),
                          ),
                          Text(
                            "Attempt: ${userList[index]["attemp"].toString()}",
                            style: TextStyle(
                              fontSize: 12,
                              color: index == 0 ? Colors.white : Color(0xFFABABAB),
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

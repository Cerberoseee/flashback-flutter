import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(),
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
              labelColor: const Color(0xFF76ABAE) ,
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
                  ListView(
                    children: const [
                      VocabListWidget(
                        title: "test",
                        description: "a",
                        icon: Icon(Icons.folder),
                        userName: "lmaoez",
                      ),
                      VocabListWidget(
                        title: "test",
                        description: "a",
                        icon: Icon(Icons.folder),
                        userName: "lmaoez",
                      ),
                      VocabListWidget(
                        title: "test",
                        description: "a",
                        icon: Icon(Icons.folder),
                        userName: "lmaoez",
                      ),
                      VocabListWidget(
                        title: "test",
                        description: "a",
                        icon: Icon(Icons.folder),
                        userName: "lmaoez",
                      ),
                    ],
                  ),
                  ListView(
                    children: const [
                      VocabListWidget(
                        title: "test",
                        description: "a",
                        icon: Icon(Icons.folder),
                        userName: "lmaoez",
                      ),
                      VocabListWidget(
                        title: "test",
                        description: "a",
                        icon: Icon(Icons.folder),
                        userName: "lmaoez",
                      ),
                      VocabListWidget(
                        title: "test",
                        description: "a",
                        icon: Icon(Icons.folder),
                        userName: "lmaoez",
                      ),
                      VocabListWidget(
                        title: "test",
                        description: "a",
                        icon: Icon(Icons.folder),
                        userName: "lmaoez",
                      ),
                    ],
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

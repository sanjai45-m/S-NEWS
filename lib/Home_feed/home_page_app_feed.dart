import 'dart:async';
import 'package:floating_draggable_widget/floating_draggable_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:SNEWS/Home_feed/stylish_appbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../searchpage/home_search_page.dart';
import '../top_trending/top_trending.dart';
import 'carousel_slider.dart';
import 'home_feed_widgets/new_card.dart';
import 'home_feed_widgets/skeleton_card.dart';
import 'home_feed_widgets/tab_item.dart';
import '../provider/dark_theme_provider.dart';
import 'api.dart';
import 'const_home_feed/consts.dart';
import 'new_details/news.dart';
import 'dart:ui';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  var newsType = NewsType.allNews;
  late Stream<List<Articles>> _newsStream;

  List<TargetFocus> targets = [];
  final GlobalKey keyButton = GlobalKey();
  final GlobalKey keyFAB = GlobalKey();
  late TutorialCoachMark tutorial;

  @override
  void initState() {
    super.initState();
    _updateNewsStream();
    checkAndShowTutorial();
  }

  void initTargets() {
    targets.add(
      TargetFocus(
        identify: "Target 1",
        keyTarget: keyButton,
        contents: [
          TargetContent(
            align: ContentAlign.left,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Search the Latest News",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                SizedBox(height: 10),
                Text(
                  "Use this search icon to find the latest articles on various topics. Tap here to explore trending news and updates from around the world.",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        shape: ShapeLightFocus.RRect,
        identify: "Target 2",
        keyTarget: keyFAB,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Top Trending",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                SizedBox(height: 10),
                Text(
                  "Stay ahead of the curve by exploring the top trending news and keep yourself updated with the latest buzz and hot topics.",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> checkAndShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasShownTutorial = prefs.getBool('hasShownTutorial') ?? false;

    if (!hasShownTutorial) {
      initTargets();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          showTutorial(context);
        });
      });
    }
  }

  void showTutorial(BuildContext context) {
    tutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.purple,
      useSafeArea: true,
      onFinish: () async {
        if (kDebugMode) {
          print("Tutorial finished");
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('hasShownTutorial', true);
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        if (kDebugMode) {
          print("Target: $target");
          print(
              "Clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
        }
      },
      onClickTarget: (target) {
        if (kDebugMode) {
          print(target);
        }
      },
      onSkip: () {
        if (kDebugMode) {
          print("Tutorial skipped");
        }
        tutorial.finish(); // End the tutorial on skip
        // Move SharedPreferences logic outside of this callback
        SharedPreferences.getInstance().then((prefs) {
          prefs.setBool('hasShownTutorial', true);
        });
        return true; // Ensure this is synchronous
      },
    );

    tutorial.show(context: context);

    // Automatically move to the next target after 2 seconds
    Timer(Duration(seconds: 2), () {
      tutorial.next(); // Moves to the next target
    });
  }

  void _updateNewsStream() {
    _newsStream = getNewsStream(newsType);
  }

  Stream<List<Articles>> getNewsStream(NewsType type) async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 2));
      yield await getNews(type);
    }
  }

  Future<List<Articles>> getNews(NewsType type) async {
    try {
      return await Api().getFromJson() ?? [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
      return [];
    }
  }

  void _onTabSelected(NewsType selectedType) {
    setState(() {
      newsType = selectedType;
      if (newsType == NewsType.allNews) {
        _updateNewsStream();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeProvider.darkTheme;
    Color appThemeColor = Theme.of(context).colorScheme.primary;

    return FloatingDraggableWidget(
      floatingWidget: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              var begin = const Offset(-1.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.ease;
              var tween = Tween(begin: begin, end: end).chain(
                CurveTween(curve: curve),
              );
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            pageBuilder: (context, animation, secondaryAnimation) =>
                const Home(), // Adjust this page if needed
          ));
        },
        child: Container(
          key: keyButton,
          padding: const EdgeInsets.all(10.0), // Adds space around the icon
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Colors.blue, Colors.green],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(4, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.search,
            size: 35,
            color: Colors.white,
          ),
        ),
      ),
      floatingWidgetHeight: 60,
      floatingWidgetWidth: 60,
      dx: MediaQuery.of(context).size.width * 0.80,
      dy: MediaQuery.of(context).size.width * 1.70,
      deleteWidgetDecoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white12, Colors.grey],
          begin: Alignment.centerLeft,
          end: Alignment.centerLeft,
          stops: [.0, 1],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(50),
          topRight: Radius.circular(50),
        ),
      ),
      mainScreenWidget: Scaffold(
        appBar: AppBar(
          backgroundColor: isDarkMode ? appThemeColor : appThemeColor,
          title: Padding(
            padding: const EdgeInsets.all(70.0),
            child: Row(
              children: [
                SizedBox(
                    height: 50,
                    width: 50,
                    child: Lottie.network(
                        'https://lottie.host/2e90e9cc-c971-42e6-b867-21a82e78a194/TTDr4fNpP6.json')),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "National News",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.white),
                ),
              ],
            ),
          ),
          centerTitle: true,
          toolbarHeight: 80,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2),
            child: Container(),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              const CarouselsSlider(),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TabItem(
                      text: 'All News',
                      type: NewsType.allNews,
                      currentType: newsType,
                      onTabSelected: _onTabSelected,
                      isDarkMode: isDarkMode,
                    ),
                    TabItem(
                      key: keyFAB,
                      text: 'Top Trending',
                      type: NewsType.topTrending,
                      currentType: newsType,
                      onTabSelected: _onTabSelected,
                      isDarkMode: isDarkMode,
                    ),
                  ],
                ),
              ),
              if (newsType == NewsType.allNews)
                StreamBuilder<List<Articles>>(
                  stream: _newsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        children:
                            List.generate(5, (index) => const SkeletonCard()),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No news articles available.'),
                      );
                    } else {
                      return Column(
                        children: snapshot.data!
                            .map((article) => NewsCard(article: article))
                            .toList(),
                      );
                    }
                  },
                ),
              if (newsType == NewsType.topTrending)
                SafeArea(child: TopTrendingWidget()),
            ],
          ),
        ),
      ),
    );
  }
}

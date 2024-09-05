import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/languageNews/langages_news_details_page.dart';
import 'package:flutter_application_1/languageNews/All_language.dart';
import 'package:flutter_application_1/languageNews/all_languages_skeleton.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../APIs/api_all_languages.dart';
import '../Home_feed/stylish_appbar.dart';
import '../constant_classes/utils.dart';
import '../provider/dark_theme_provider.dart';
import 'language_dropdown.dart';

class TamilNewsHomePage extends StatefulWidget {
  const TamilNewsHomePage({Key? key}) : super(key: key);

  @override
  State<TamilNewsHomePage> createState() => _TamilNewsHomePageState();
}

class _TamilNewsHomePageState extends State<TamilNewsHomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool toggleBackgroundState = false;
  List<News> tamilNews = [];
  bool isLoaded = false;
  late ApiTamil api;

  void setTimeOut() {
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoaded = true;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    api = ApiTamil();
    getNewsByLanguage('tamil'); // Fetch Tamil news by default
    setTimeOut();
  }

  Future<void> getNewsByLanguage(String language) async {
    setState(() {
      isLoaded = false;
    });
    try {
      List<News>? newsArticles = await api.getNewsByLanguage(language);
      setState(() {
        tamilNews = newsArticles ?? [];
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    } finally {
      setState(() {
        isLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeProvider.darkTheme;
    super.build(context);
    final color = Utils(context).getColor;
    final fakeTamilNews = List.filled(
      7,
      News(
        title: 'Loading title...',
        description: 'Loading description...',
        image: '',
      ),
    );

    final tamilNewsToShow = isLoaded ? tamilNews : fakeTamilNews;

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Padding(
          padding: const EdgeInsets.all(70.0),
          child: Row(
            children: [
              SizedBox(height: 60, width: 60, child: Lottie.network('Url')),
              SizedBox(
                width: 10,
              ),
              Text(
                "Other News",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: LanguageDropdown(
              onLanguageChanged: getNewsByLanguage,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Skeletonizer(
              enabled: !isLoaded,
              child: ListView.builder(
                itemCount: tamilNewsToShow.length,
                itemBuilder: (context, index) {
                  final tamil = tamilNewsToShow[index];
                  final tamilNewsSkeleton = TamilNewsSkeleton(
                      url: tamil.image.toString(),
                      title: tamil.title.toString(),
                      description: tamil.description.toString(),
                      webUrl: tamil.url.toString());
                  final heroTag =
                      'news_hero_${tamil.title ?? 'loading'}_$index';
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TamilNewsDetailsPage(
                            tamilNewsSkeleton: tamilNewsSkeleton,
                            heroTag: heroTag,
                          ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: heroTag,
                      child: Card(
                        color: isDarkMode ? Colors.grey[850] : Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Skeleton.replace(
                                  width: 100,
                                  height: 100,
                                  child: Image.network(
                                    tamil.image?.isNotEmpty == true
                                        ? tamil.image!
                                        : "Url",
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.network(
                                        "Url",
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tamil.title ?? 'No Title',
                                      style: GoogleFonts.italiana(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      tamil.description ?? 'No Description',
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (!isLoaded)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

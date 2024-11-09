import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:SNEWS/provider/dark_theme_provider.dart';
import 'package:SNEWS/searchpage/searchWidget.dart';
import 'package:SNEWS/top_trending/top_trending_news.dart';
import 'package:flutter_slide_drawer/flutter_slide_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'apisearch.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<SliderDrawerWidgetState> drawerKey = GlobalKey();
  bool toggleBackgroundState = false;

  List<Articles1> articles = [];
  late TextEditingController _textEditingController;
  List<String> recentSearches = [];
  final ValueNotifier<bool> _showCloseIcon = ValueNotifier<bool>(false);

  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _loadRecentSearches();
    _speech = stt.SpeechToText();
    _initializeSpeechRecognition();
  }

  Future<void> _initializeSpeechRecognition() async {
    bool isPermissionGranted = await _speech.initialize(
      onError: (error) =>
          print('Error initializing speech recognition: $error'),
    );
    if (!isPermissionGranted) {
      print('Microphone permission not granted');
    }
  }

  void _toggleListening() {
    if (_isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
      });
    } else {
      _speech.listen(
        onResult: (result) {
          _textEditingController.text = result.recognizedWords;
          _showCloseIcon.value = _textEditingController.text.isNotEmpty;
          filterSources(result.recognizedWords);
        },
        listenFor: const Duration(minutes: 1),
      );
      setState(() {
        _isListening = true;
      });
    }
  }

  Future<void> _loadRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      recentSearches = prefs.getStringList('recentSearches') ?? [];
    });
  }

  Future<void> _saveRecentSearch(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (recentSearches.contains(query)) {
      recentSearches.remove(query);
    }
    recentSearches.insert(0, query);
    if (recentSearches.length > 7) {
      recentSearches = recentSearches.sublist(0, 7);
    }
    await prefs.setStringList('recentSearches', recentSearches);
  }

  Future<void> getDataFrom(String query) async {
    try {
      final fetchedArticles = await SourcesApi().getFromJsonFilters(query);
      if (fetchedArticles != null) {
        setState(() {
          articles = fetchedArticles;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  void filterSources(String query) {
    if (query.isEmpty) {
      setState(() {
        articles = [];
      });
    } else {
      _saveRecentSearch(query);
      getDataFrom(query);
    }
  }

  Future<void> _clearAllRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      recentSearches.clear();
    });
    await prefs.remove('recentSearches');
  }

  void _removeRecentSearch(String query) {
    setState(() {
      recentSearches.remove(query);
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setStringList('recentSearches', recentSearches);
    });
  }

  void launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      if (kDebugMode) {
        print('Could not launch $url');
      }
    }
  }

  Widget _buildRiveAnimation() {
    try {
      return Column(
        children: [
          Text(
            '"No Results"',
            style: TextStyle(fontSize: 25),
          ),
          Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20)),
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Lottie.asset(
                  'assets/images/riv/Animation - 1722685759727.json')),
        ],
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error loading Rive animation: $e');
      }
      return Center(child: Text('Error loading animation'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).textTheme.bodyText1!.color;
    final query = _textEditingController.text;
    final themeProvider = Provider.of<DarkThemeProvider>(context).darkTheme;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 48.0),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.83,
                      child: Row(
                        children: [
                          Expanded(
                            child: ValueListenableBuilder<bool>(
                              valueListenable: _showCloseIcon,
                              builder: (context, value, child) {
                                return SizedBox(
                                  height: 50,
                                  child: TextField(
                                    style: TextStyle(color: color),
                                    controller: _textEditingController,
                                    onChanged: (query) {
                                      _showCloseIcon.value = query.isNotEmpty;
                                      filterSources(query);
                                    },
                                    decoration: InputDecoration(
                                      hintText: "Type Here...",
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: themeProvider
                                                ? Colors.white
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .primary), // Border color when enabled but not focused
                                        borderRadius: BorderRadius.circular(
                                            8.0), // Optional: Border radius
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                        borderRadius: BorderRadius.circular(
                                            8.0), // Optional: Border radius
                                      ),
                                      suffixIcon: value
                                          ? IconButton(
                                              icon: const Icon(Icons.close),
                                              onPressed: () {
                                                _textEditingController.clear();
                                                _showCloseIcon.value = false;
                                                filterSources('');
                                              },
                                            )
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          CircleAvatar(
                            backgroundColor: _isListening
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[50],
                            child: IconButton(
                              icon: Icon(
                                _isListening
                                    ? Icons.mic_rounded
                                    : Icons.mic_off_rounded,
                                color: _isListening
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.primary,
                              ),
                              onPressed: _toggleListening,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (recentSearches.isNotEmpty)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _clearAllRecentSearches,
                            child: const Text("Clear All"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          spacing: 8.0,
                          children: recentSearches.map((search) {
                            return GestureDetector(
                              onTap: () {
                                _textEditingController.text = search;
                                _showCloseIcon.value = true;
                                filterSources(search);
                              },
                              child: Chip(
                                label: Text(search),
                                deleteIcon: const Icon(Icons.cancel),
                                onDeleted: () {
                                  _removeRecentSearch(search);
                                },
                              ),
                            );
                          }).toList(),
                        ))
                  ],
                ),
              // Display the searched query before the ListView
              if (query.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: RichText(
                    text: TextSpan(
                      text: 'Your search results for ',
                      style: TextStyle(
                          color: themeProvider ? Colors.white : Colors.black,
                          fontSize: 16),
                      children: <TextSpan>[
                        TextSpan(
                            text: '"$query"',
                            style: GoogleFonts.ibmPlexSansArabic(
                              textStyle: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              if (articles.isEmpty)
                _buildRiveAnimation()
              else
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: ListView.builder(
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      final article = articles[index];
                      return GestureDetector(
                        onTap: () {
                          SearchWidget.showBottomSheet(
                              context,
                              article.urlToImage ?? '',
                              article.title ?? "No Title",
                              article.description ?? "No Description",
                              article.url ?? '');
                        },
                        child: Card(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey,
                            ),
                            height: 150,
                            width: double.infinity,
                            child: Row(
                              children: [
                                article.urlToImage != null
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Image.network(
                                            article.urlToImage!,
                                            height: 150,
                                            width: 150,
                                            fit: BoxFit.cover,
                                            errorBuilder: (BuildContext context,
                                                Object exception,
                                                StackTrace? stackTrace) {
                                              return Container(
                                                height: 150,
                                                width: 150,
                                                color: Colors.grey,
                                                child: const Icon(Icons.image,
                                                    color: Colors.red,
                                                    size: 50),
                                              );
                                            },
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    article.title ?? "No Title",
                                    style: const TextStyle(color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

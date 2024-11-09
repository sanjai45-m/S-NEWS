import 'package:card_swiper/card_swiper.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:SNEWS/top_trending/top_trending_news.dart';
import 'package:SNEWS/top_trending/top_trending_news_api.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../constant_classes/utils.dart';

class TopTrendingWidget extends StatefulWidget {
  const TopTrendingWidget({super.key});

  @override
  State<TopTrendingWidget> createState() => _TopTrendingWidgetState();
}

class _TopTrendingWidgetState extends State<TopTrendingWidget> {
  List<Articles1>? topTrendingNews;
  Stream<List<Articles1>>? _streamTopTrendingNews;

  Future<List<Articles1>> getDataFromApi() async {
    try {
      List<Articles1> topTrending =
          await TopTrendingNewsApiIndia().getFromJsonIndiaData() ?? [];
      return topTrending;
    } catch (e) {
      if (kDebugMode) {
        print("Error Fetching $e");
      }
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _streamTopTrendingNews = Stream.fromFuture(getDataFromApi());
  }

  @override
  Widget build(BuildContext context) {
    final size = Utils(context).getScreenSize;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<List<Articles1>>(
      stream: _streamTopTrendingNews,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LoadingAnimationWidget.discreteCircle(
              secondRingColor:
                  isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
              thirdRingColor: Colors.blueAccent,
              size: 50,
              color: Colors.blue,
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        } else {
          final articles = snapshot.data!;
          return SizedBox(
            height: size.height * 0.7, // Set height based on your design
            child: Swiper(
              duration: 1000,
              autoplay: true,
              axisDirection: AxisDirection.right,
              viewportFraction: 0.6,
              layout: SwiperLayout.STACK,
              itemWidth: size.width * 0.9,
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final newsData = articles[index];
                String? originalDateString = newsData.publishedAt;
                DateTime dateTime = DateTime.parse(originalDateString!);
                String formattedDate =
                    DateFormat.yMd().add_jms().format(dateTime);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Material(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    color: isDarkMode ? Colors.grey[900] : Colors.white,
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                            child: FancyShimmerImage(
                              boxFit: BoxFit.cover,
                              errorWidget:
                                  Image.asset('assets/images/empty_image.png'),
                              imageUrl: newsData.urlToImage ??
                                  'https://cdn.pixabay.com/photo/2017/07/15/19/42/train-track-2507499_1280.jpg',
                              width: size.width,
                              height: 200,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    newsData.title ?? 'Title',
                                    style: GoogleFonts.italiana(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    newsData.description ?? 'Description',
                                    style: GoogleFonts.italiana(
                                      fontSize: 16,
                                      color: isDarkMode
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                formattedDate,
                                style: GoogleFonts.italiana(
                                  fontSize: 14,
                                  color: isDarkMode
                                      ? Colors.white60
                                      : Colors.black38,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}

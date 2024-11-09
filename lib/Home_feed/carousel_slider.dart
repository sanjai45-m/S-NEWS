import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:SNEWS/Home_feed/api.dart';
import 'package:SNEWS/provider/dark_theme_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../top_trending/top_trending_news.dart';
import '../provider/dark_theme_provider.dart';

class CarouselsSlider extends StatefulWidget {
  const CarouselsSlider({super.key});

  @override
  State<CarouselsSlider> createState() => _CarouselsSliderState();
}

class _CarouselsSliderState extends State<CarouselsSlider> {
  List<Articles1> articlesImage = [];

  @override
  void initState() {
    super.initState();
    getImage();
  }

  Future<void> getImage() async {
    final carouselImage = await CarouselSliderApi().getFromJsonApiImages();
    if (carouselImage != null) {
      setState(() {
        articlesImage = carouselImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeProvider.darkTheme;
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black.withOpacity(0.4) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 5),
            blurRadius: 15.0,
          ),
        ],
      ),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 250.0,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 4),
          autoPlayAnimationDuration: const Duration(milliseconds: 1200),
          autoPlayCurve: Curves.easeInOut,
          enlargeCenterPage: true,
          viewportFraction: 0.9,
          aspectRatio: 16 / 9,
          initialPage: 0,
        ),
        items: articlesImage.map((article) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 5),
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Stack(
                    children: [
                      Image.network(
                        article.urlToImage ?? '',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image,
                              color: Colors.white, size: 50),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            article.source?.name ?? 'Unknown Source',
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.8),
                                Colors.transparent
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          child: Text(
                            article.title ?? '',
                            style: const TextStyle(
                              fontSize: 20.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  offset: Offset(0.0, 1.0),
                                  blurRadius: 4.0,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

class CarouselSliderApi {
  Future<List<Articles1>?> getFromJsonApiImages() async {
    final apikey = Api().apikey;
    final url =
        Uri.parse('https://newsapi.org/v2/everything?q=science&apiKey=$apikey');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['articles'];
        return data.map((e) => Articles1.fromJson(e)).toList();
      } else {
        throw Exception("Failed to Load Data");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to Load $e");
      }
      return null;
    }
  }
}

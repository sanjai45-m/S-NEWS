import 'package:flutter/material.dart';
import 'package:flutter_application_1/Home_feed/new_details/news_details.dart';
import '../const_home_feed/skeleton_details_page.dart';
import '../new_details/news.dart';

class NewsCard extends StatefulWidget {
  final Articles article;

  const NewsCard({super.key, required this.article});

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  @override
  Widget build(BuildContext context) {
    var newsDetailsSkeleton = NewsDetailsSkeleton(
      content: widget.article.content?.isNotEmpty ?? false
          ? widget.article.content.toString()
          : "No Content",
      name: widget.article.source?.name?.isNotEmpty ?? false
          ? widget.article.source!.name.toString()
          : "No Name",
      url: widget.article.urlToImage?.isNotEmpty ?? false
          ? widget.article.urlToImage.toString()
          : "https://img.freepik.com/free-photo/image-icon-front-side-white-background_187299-40166.jpg",
      title: widget.article.title?.isNotEmpty ?? false
          ? widget.article.title.toString()
          : "No Title",
      description: widget.article.description?.isNotEmpty ?? false
          ? widget.article.description.toString()
          : "No Description",
      webUrl: widget.article.url?.isNotEmpty ?? false
          ? widget.article.url.toString()
          : "https://www.google.com/",
    );

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => NewsDetails(
              newsDetailsSkeleton: newsDetailsSkeleton,
              heroTag: widget.article.urlToImage.toString()),
        ));
      },
      child: Card(
        color: Theme.of(context).cardColor,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(10),
            height: 200,
            width: double.infinity,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    widget.article.urlToImage ??
                        "Url",
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          widget.article.title ?? 'No Title',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          widget.article.description ?? 'No Description',
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey.shade600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import '../Home_feed/bookmarks/product_manage.dart';
import '../provider/user_provider.dart';
import '../webview_tab/news_details_webview.dart';
import 'all_languages_skeleton.dart';

class TamilNewsDetailsPage extends StatefulWidget {
  final TamilNewsSkeleton tamilNewsSkeleton;
  final String heroTag;

  const TamilNewsDetailsPage({
    super.key,
    required this.tamilNewsSkeleton,
    required this.heroTag,
  });

  @override
  State<TamilNewsDetailsPage> createState() => _TamilNewsDetailsPageState();
}

class _TamilNewsDetailsPageState extends State<TamilNewsDetailsPage> {
  bool isBookMarked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkIsBookMarked();
    });
  }

  void checkIsBookMarked() {
    final productsManage = Provider.of<ProductsManage>(context, listen: false);
    if (mounted) {
      setState(() {
        isBookMarked = productsManage.bookmarksList.any((bookmark) =>
        bookmark.url == widget.tamilNewsSkeleton.url &&
            bookmark.title == widget.tamilNewsSkeleton.title);
      });
    }
  }

  void showBookmarkSnackbar(
      BuildContext context, String label, String text, Function fn) {
    final snackBar = SnackBar(
      content: Text(text),
      action: SnackBarAction(
        label: label,
        onPressed: () {
          fn();
        },
      ),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(10),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    final productsManage = Provider.of<ProductsManage>(context, listen: false);
    final phone = Provider.of<UserProvider>(context, listen: false).phoneNumber;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (widget.tamilNewsSkeleton.url.isNotEmpty)
                  ? Hero(
                tag: widget.heroTag,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(30)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(30)),
                        child: Image.network(
                          widget.tamilNewsSkeleton.url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.network(
                              "https://img.freepik.com/free-photo/image-icon-front-side-white-background_187299-40166.jpg",
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 22,
                      left: 10,
                      child: Material(
                        color: Colors.transparent,
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.arrow_back_ios,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: Material(
                        elevation: 5,
                        borderRadius: BorderRadius.circular(30),
                        color: isDarkMode ? Colors.deepPurple : Colors.purple,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              isBookMarked = !isBookMarked;
                              if (isBookMarked) {
                                productsManage.addBookmark(
                                  phone,
                                  AddBookMark(
                                    title: widget.tamilNewsSkeleton.title,
                                    url: widget.tamilNewsSkeleton.url,
                                  ),
                                );
                                Toast.show("Bookmark Added", duration: Toast.lengthShort, gravity: Toast.bottom);

                              } else {
                                productsManage.removeBookmark(
                                  phone,
                                  AddBookMark(
                                    title: widget.tamilNewsSkeleton.title,
                                    url: widget.tamilNewsSkeleton.url,
                                  ),
                                );
                                Toast.show("Bookmark Removed", duration: Toast.lengthShort, gravity: Toast.bottom);

                              }
                            });
                          },
                          icon: Icon(
                            isBookMarked
                                ? Icons.bookmark
                                : Icons.bookmark_add_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  : Image.network(
                "https://img.freepik.com/free-photo/image-icon-front-side-white-background_187299-40166.jpg",
                fit: BoxFit.fitWidth,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SelectableText(
                  widget.tamilNewsSkeleton.title,
                  style: theme.textTheme.headline6?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(thickness: 1, color: Colors.grey),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: widget.tamilNewsSkeleton.description.isNotEmpty
                    ? Text(
                  widget.tamilNewsSkeleton.description,
                  style: theme.textTheme.bodyText2?.copyWith(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepOrange, Colors.pinkAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: Offset(0, 6),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => NewsDetailsWebview(
                          imageUrl: widget.tamilNewsSkeleton.webUrl.toString(),
                        ),
                      ));
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Center(
                      child: Text(
                        'Read Article',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Home_feed/bookmarks/product_manage.dart';
import 'package:flutter_application_1/Home_feed/const_home_feed/skeleton_details_page.dart';
import 'package:toast/toast.dart';
import 'package:flutter_application_1/provider/dark_theme_provider.dart';
import 'package:provider/provider.dart';
import '../../provider/user_provider.dart';
import '../../webview_tab/news_details_webview.dart';

class NewsDetails extends StatefulWidget {
  final NewsDetailsSkeleton newsDetailsSkeleton;
  final String heroTag;

  const NewsDetails({
    super.key,
    required this.newsDetailsSkeleton,
    required this.heroTag,
  });

  @override
  State<NewsDetails> createState() => _NewsDetailsState();
}

class _NewsDetailsState extends State<NewsDetails> {
  bool isBookMarked = false;

  @override
  void initState() {
    super.initState();
    checkIsBookMarked();
  }

  void checkIsBookMarked() {
    final productsManage = Provider.of<ProductsManage>(context, listen: false);
    setState(() {
      isBookMarked = productsManage.bookmarksList.any((bookmark) =>
      bookmark.url == widget.newsDetailsSkeleton.url &&
          bookmark.title == widget.newsDetailsSkeleton.title);
    });
  }

  void showBookmarkSnackBar(BuildContext context, String label, String text,
      Function fn, Color color) {
    final snackBar = SnackBar(
      content: Text(
        text,
        style: TextStyle(color: color),
      ),
      action: SnackBarAction(
        label: label,
        onPressed: () {
          fn();
        },
      ),
      backgroundColor: Colors.black87,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    final productsManage = Provider.of<ProductsManage>(context, listen: false);
    final phone = Provider.of<UserProvider>(context, listen: false).phoneNumber;
    final themeProvider = Provider.of<DarkThemeProvider>(context).darkTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.newsDetailsSkeleton.name),
        backgroundColor: themeProvider ? Colors.black :Theme.of(context).colorScheme.primary,
        foregroundColor: themeProvider ? Colors.white : Colors.white,
        elevation: 1, // Subtle shadow for a cleaner look
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // Share functionality can be added here
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (widget.newsDetailsSkeleton.url.isNotEmpty)
                ? Stack(
              clipBehavior: Clip.none,
              children: [
                Hero(
                  tag: widget.heroTag,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.newsDetailsSkeleton.url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            "Url",
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.purple,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          isBookMarked = !isBookMarked;
                          //we saved in a variable
                          final bookmark = AddBookMark(
                              title: widget.newsDetailsSkeleton.title,
                              url: widget.newsDetailsSkeleton.url);
                          if (isBookMarked) {
                            productsManage.addBookmark(phone, bookmark);
                            Toast.show("Bookmark Added", duration: Toast.lengthShort, gravity: Toast.bottom);
                          } else {
                            productsManage.removeBookmark(phone, bookmark);
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
            )
                : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                "Url",
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SelectableText(
                widget.newsDetailsSkeleton.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: themeProvider ? Colors.white : Colors.black,
                ),
              ),
            ),
            const Divider(thickness: 1, height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.newsDetailsSkeleton.description.isNotEmpty
                    ? widget.newsDetailsSkeleton.description
                    : "No Description",
                style: TextStyle(
                  fontSize: 18,
                  color: themeProvider ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SelectableText(
                widget.newsDetailsSkeleton.content.isNotEmpty
                    ? '"${widget.newsDetailsSkeleton.content}"'
                    : "No Content",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 18,
                  color: themeProvider ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => NewsDetailsWebview(
                        imageUrl: widget.newsDetailsSkeleton.webUrl,
                      ),
                    ));
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Center(
                    child: Text(
                      'Read Article',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

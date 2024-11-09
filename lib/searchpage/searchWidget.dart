import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/dark_theme_provider.dart';
import '../tabs/news_details_webview.dart';

class SearchWidget {
  static void showBottomSheet(
      BuildContext context, // Add context here
      String imageUrl,
      String title,
      String description,
      String url) {
    showModalBottomSheet(
      context: context, // Use the passed context
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        final themeProvider = Provider.of<DarkThemeProvider>(context);
        final isDarkMode = themeProvider.darkTheme;
        return SingleChildScrollView(
          child: SizedBox(
            height: 640,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (imageUrl.isNotEmpty)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          imageUrl,
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return Container(
                              height: 300,
                              width: double.infinity,
                              color: Colors.grey,
                              child: const Icon(Icons.error,
                                  color: Colors.red, size: 50),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[600]!.withOpacity(0.4),
                          ),
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => NewsDetailsWebview(
                        imageUrl: url,
                      ),
                    ));
                  },
                  child: Text(
                    'Read Article',
                    style: TextStyle(
                        color: isDarkMode
                            ? Colors.grey
                            : Theme.of(context).colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

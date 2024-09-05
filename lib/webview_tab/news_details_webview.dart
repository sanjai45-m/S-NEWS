import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../constant_classes/global_methods.dart';

class NewsDetailsWebview extends StatefulWidget {
  final String imageUrl;

  const NewsDetailsWebview({super.key, required this.imageUrl});

  @override
  State<NewsDetailsWebview> createState() => _NewsDetailsWebviewState();
}

class _NewsDetailsWebviewState extends State<NewsDetailsWebview> {
  late final WebViewController _controller;
  double? _progress;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            setState(() {
              _progress = progress / 100;
            });
          },
          onPageStarted: (url) {
            setState(() {
              // Update the app bar title with the URL when a new page starts loading
            });
          },
          onPageFinished: (url) {
            setState(() {
              // Update the app bar title with the URL when the page finishes loading
            });
          },
          onWebResourceError: (error) {
            GlobalMethods.errorDialog(errorMessage: error.description, context: context);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.imageUrl));

    _controller.enableZoom(true);
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        if (await _controller.canGoBack()) {
          _controller.goBack();
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
         // iconTheme: IconThemeData(color: color),
          backgroundColor: Theme.of(context).colorScheme.primary,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back)),
          elevation: 0,
          centerTitle: true,
          title: Text(
            Uri.parse(widget.imageUrl).host, // Display the hostname in the app bar title

          ),
          actions: [
            IconButton(
                onPressed: () async {
                  await _showBottomModelSheet();
                },
                icon: const Icon(Icons.more_horiz_outlined))
          ],
        ),
        body: Column(
          children: [
            LinearProgressIndicator(
              value: _progress,
              color: _progress == 1.0 ? Colors.transparent : Colors.blue,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
            Expanded(child: WebViewWidget(controller: _controller)),
          ],
        ),
      ),
    );
  }

  Future<void> _showBottomModelSheet() async {
    await showModalBottomSheet(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  height: 5,
                  width: 35,
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'More Options',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              ),
              const SizedBox(height: 20),
              const Divider(
                thickness: 2,
              ),
              const SizedBox(height: 20),
              ListTile(
                onTap: () async {
                  try {
                    await Share.share(
                        'Check out my website ${widget.imageUrl}',
                        subject: 'Look what I found!');
                  } catch (e) {
                    GlobalMethods.errorDialog(errorMessage: e.toString(), context: context);
                  }
                },
                leading: const Icon(Icons.share),
                title: const Text("Share"),
              ),
              ListTile(
                onTap: () async {
                  try {
                    if (!await launchUrl(Uri.parse(widget.imageUrl))) {
                      throw Exception('Could not launch ${widget.imageUrl}');
                    }
                  } catch (err) {
                    GlobalMethods.errorDialog(errorMessage: err.toString(), context: context);
                  }
                },
                leading: const Icon(Icons.open_in_browser),
                title: const Text("Open in Browser"),
              ),
              ListTile(
                onTap: () async {
                  try {
                    await _controller.reload();
                    Navigator.pop(context);
                  } catch (err) {
                    GlobalMethods.errorDialog(errorMessage: err.toString(), context: context);
                  }
                },
                leading: const Icon(Icons.refresh),
                title: const Text("Refresh"),
              ),
            ],
          ),
        );
      },
    );
  }
}

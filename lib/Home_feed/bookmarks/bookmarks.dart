import 'package:flutter/material.dart';
import 'package:SNEWS/Home_feed/bookmarks/product_manage.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../provider/user_provider.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});
  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final productsManage = Provider.of<ProductsManage>(context);
    final userProvider = Provider.of<UserProvider>(context);
    void fetchBookmarks() async {
      await productsManage.fetchBookmarks(userProvider.phoneNumber);
    }

    fetchBookmarks();

    List<AddBookMark> manageProduct = productsManage.bookmarksList;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Padding(
            padding: const EdgeInsets.all(70.0),
            child: Row(
              children: [
                SizedBox(
                    height: 50,
                    width: 50,
                    child: Lottie.network(
                        'https://lottie.host/ec60617b-dcfc-4048-9502-e46248d7e483/owoyOKILmO.json')),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "Bookmarks",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
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
        body: manageProduct.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/bookmark.png'),
                    const Text(
                      "No Bookmark is Added!..",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: manageProduct.length,
                itemBuilder: (context, index) => Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        manageProduct[index].url.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  manageProduct[index].url,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.asset(
                                'assets/images/bookmark.png',
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                manageProduct[index].title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  productsManage.removeBookmark(
                                    userProvider.phoneNumber,
                                    manageProduct[index],
                                  );
                                },
                                icon: const Icon(
                                  Icons.delete_forever_outlined,
                                  color: Colors.red,
                                ),
                                label: const Text(
                                  'Remove',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ));
  }
}

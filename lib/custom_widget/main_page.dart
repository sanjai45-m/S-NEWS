import 'package:animated_floating_buttons/widgets/animated_floating_action_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Home_feed/bookmarks/bookmarks.dart';
import '../Home_feed/home_page_app_feed.dart';
import '../Home_feed/bookmarks/product_manage.dart';
import '../provider/dark_theme_provider.dart';
import '../provider/settings_provider.dart';
import '../languageNews/all_news__home_page.dart';
import '../provider/user_provider.dart';
import '../users/community_page.dart';
import '../users/create_group_chat_page.dart';
import '../users/user_list_page.dart';
import 'badge_widget.dart';
import '../settings/settings.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final PageController _pageController = PageController();
  int currentIndex = 0;
  DateTime? lastBackPressed;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final productsManage = Provider.of<ProductsManage>(context, listen: false);

    await settingsProvider.fetchUserPhoneNumber();
    await userProvider.fetchUserData();
    await productsManage.fetchBookmarks(userProvider.phoneNumber);

    setState(() {}); // Trigger a rebuild to ensure the UI is updated
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context).darkTheme;
    final productsManage = Provider.of<ProductsManage>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final GlobalKey<AnimatedFloatingActionButtonState> key =
        GlobalKey<AnimatedFloatingActionButtonState>();

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                if (mounted) {
                  setState(() {
                    currentIndex = index;
                  });
                }
              },
              children: [
                HomePage(key: PageStorageKey('HomePage')),
                BookmarksPage(key: PageStorageKey('BookmarksPage')),
                TamilNewsHomePage(key: PageStorageKey('TamilNewsHomePage')),
                CommunityPage(
                    key: PageStorageKey(
                        'CommunityPage')), // Add CommunityPage here
                Settings(key: PageStorageKey('SettingsPage')),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.only(bottom: 0),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20)),
                  child: BottomNavigationBar(
                    backgroundColor:
                        themeProvider ? Colors.grey[200] : Colors.red,
                    elevation: 0,
                    selectedItemColor: themeProvider
                        ? Colors.black
                        : Theme.of(context).colorScheme.primary,
                    unselectedItemColor:
                        themeProvider ? Colors.black : Colors.grey,
                    currentIndex: currentIndex,
                    onTap: (int val) {
                      setState(() {
                        currentIndex = val;
                      });
                      _pageController.jumpToPage(val);
                    },
                    items: [
                      _buildNavBarItem(
                        icon: const Icon(Icons.home, size: 35),
                        label: 'Home',
                        index: 0,
                        isSelected: currentIndex == 0,
                      ),
                      _buildNavBarItem(
                        icon: BadgeWidgets(
                          count: productsManage.bookmarkCount,
                          color: Colors.red,
                          child: const Icon(Icons.bookmark, size: 35),
                        ),
                        label: 'Bookmarks',
                        index: 1,
                        isSelected: currentIndex == 1,
                      ),
                      _buildNavBarItem(
                        icon: const Icon(Icons.g_translate_rounded, size: 35),
                        label: 'Other News',
                        index: 2,
                        isSelected: currentIndex == 2,
                      ),
                      _buildNavBarItem(
                        icon:
                            const Icon(Icons.supervised_user_circle, size: 35),
                        label: 'Community',
                        index: 3,
                        isSelected: currentIndex == 3,
                      ),
                      _buildNavBarItem(
                        icon: userProvider.profileImageUrl != null
                            ? CircleAvatar(
                                backgroundImage:
                                    NetworkImage(userProvider.profileImageUrl!),
                                radius: 17.5, // Adjust size as needed
                              )
                            : const Icon(Icons.person_2_rounded,
                                size: 35), // Fallback icon
                        label: 'Profile',
                        index: 4,
                        isSelected: currentIndex == 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (currentIndex == 3) // Show FAB only on CommunityPage
              Positioned(
                bottom: 100, // Adjust based on BottomNavigationBar height
                right: 20,
                child: AnimatedFloatingActionButton(
                  key: key,
                  fabButtons: <Widget>[
                    FloatingActionButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CreateChatGroupPage(),
                          ),
                        );
                      },
                      heroTag: "btn1",
                      tooltip: 'Create Chat Group',
                      child: Icon(Icons.add),
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => UsersListPage(),
                          ),
                        );
                      },
                      heroTag: "btn2",
                      tooltip: 'Chat with User',
                      child: Icon(Icons.message),
                    ),
                  ],
                  colorStartAnimation: Theme.of(context).colorScheme.primary,
                  colorEndAnimation: Colors.red,
                  animatedIconData: AnimatedIcons.menu_close,
                ),
              ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavBarItem({
    required Widget icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.4)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: icon,
      ),
      label: label,
      backgroundColor: Provider.of<DarkThemeProvider>(context).darkTheme
          ? Colors.grey[600]
          : Colors.grey[200],
    );
  }

  Future<bool> _onBackPressed() async {
    final currentTime = DateTime.now();
    final backButtonHasNotBeenPressedOrSnackbarHasBeenClosed =
        lastBackPressed == null ||
            currentTime.difference(lastBackPressed!) >
                const Duration(seconds: 2);

    if (currentIndex == 0) {
      if (backButtonHasNotBeenPressedOrSnackbarHasBeenClosed) {
        lastBackPressed = currentTime;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Press back again to exit'),
            duration: Duration(seconds: 2),
          ),
        );
        return Future.value(false);
      }
      return Future.value(true);
    } else {
      setState(() {
        currentIndex = 0;
        _pageController.jumpToPage(0);
      });
      return Future.value(false);
    }
  }
}

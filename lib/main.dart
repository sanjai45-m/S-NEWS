import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Home_feed/bookmarks/bookmarks.dart';
import 'Home_feed/bookmarks/product_manage.dart';
import 'auth/login_page.dart';
import 'constant_classes/theme_data.dart';
import 'custom_widget/main_page.dart';
import 'custom_widget/on_boarding_overlay.dart';
import 'provider/dark_theme_provider.dart';
import 'provider/settings_provider.dart';
import 'provider/user_provider.dart';
import 'users/chat_room_page.dart';
import 'package:http/http.dart' as http;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

Future<void> saveFcmToken(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? phoneNumber = prefs.getString('isPhoneNumber');

  if (phoneNumber != null) {
    final url = 'baseurl/users/$phoneNumber.json';
    final response = await http.patch(
      Uri.parse(url),
      body: json.encode({
        'fcmToken': token,
      }),
    );

    if (response.statusCode != 200) {
      print('Failed to save FCM token: ${response.body}');
    }
  }
}

Future<MyApp> createMyApp() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? phoneNumber = prefs.getString('isPhoneNumber') ?? '';

  return MyApp(isPhoneNumber: phoneNumber);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      
    ),
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  String? fcmToken = await messaging.getToken();
  if (fcmToken != null) {
    await saveFcmToken(fcmToken);
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Handle foreground messages
    print('Received a foreground message: ${message.messageId}');
  });

  runApp(await createMyApp());
}

class MyApp extends StatefulWidget {
  final String isPhoneNumber;

  const MyApp({super.key, required this.isPhoneNumber});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late DarkThemeProvider darkThemeProvider;
  late ProductsManage productsManage;
  bool isFirstLaunch = false;

  @override
  void initState() {
    super.initState();
    darkThemeProvider = DarkThemeProvider();
    productsManage = ProductsManage();
    getDarkTheme();
    _initializeProductsManage();
    checkFirstLaunch();
  }

  Future<void> checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    if (isFirstLaunch) {
      await prefs.setBool('isFirstLaunch', false);
    }

    setState(() {});
  }

  void getDarkTheme() async {
    darkThemeProvider.darkThemes =
        await darkThemeProvider.sharedDarkThemeprefs.getDarkTheme() ?? false;
    setState(() {});
  }

  Future<void> _initializeProductsManage() async {
    await productsManage.loadBookmarkCountFromLocal();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DarkThemeProvider>(
          create: (context) => darkThemeProvider,
        ),
        ChangeNotifierProvider<ProductsManage>(
          create: (context) => productsManage,
        ),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<DarkThemeProvider>(
        builder: (context, getTheme, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: Constants.themeData(getTheme.darkTheme, context),
            home: isFirstLaunch
                ? const OnBoardingOverlay()
                : (widget.isPhoneNumber.isNotEmpty
                    ? const MainPage()
                    : const LoginPage()),
            routes: {
              '/bookmarks': (context) => const BookmarksPage(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/chat') {
                final args = settings.arguments as Map<String, dynamic>;
                final groupName = args['groupName'] as String;
                final groupImageUrl = args['groupImageUrl'] as String;

                return MaterialPageRoute(
                  builder: (context) {
                    return ChatRoomPage(
                      groupName: groupName,
                      groupProfileImage: groupImageUrl,
                    );
                  },
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}

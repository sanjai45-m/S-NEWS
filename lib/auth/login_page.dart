import 'dart:convert';
import 'package:SNEWS/auth/sign_up_page.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../custom_widget/main_page.dart';
import '../provider/dark_theme_provider.dart';
import '../provider/user_provider.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool obscureText = true;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _errorMessage = '';
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      String phone = _phoneController.text.trim();
      String pin = _pinController.text.trim();

      final String url = 'baseurl/users/$phone.json';

      try {
        final http.Response response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          if (response.body != 'null') {
            final Map<String, dynamic> userData = json.decode(response.body);

            if (userData['pin'] == pin) {
              // Set phone number in UserProvider
              Provider.of<UserProvider>(context, listen: false)
                  .setPhoneNumber(phone);

              // Save phone number in SharedPreferences
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('isPhoneNumber', phone);

              // Show success dialog
              AwesomeDialog(
                context: context,
                animType: AnimType.leftSlide,
                headerAnimationLoop: false,
                dialogType: DialogType.success,
                showCloseIcon: true,
                title: 'Success',
                desc: 'Login successful!',
                btnOkOnPress: () {},
                btnOkIcon: Icons.check_circle,
              ).show();

              // Retrieve and save the FCM token
              final fcmToken = await FirebaseMessaging.instance.getToken();
              if (fcmToken != null) {
                await saveFcmToken(fcmToken);
              }

              // Navigate to MainPage after 2 seconds
              Future.delayed(const Duration(seconds: 2), () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MainPage()),
                  (route) => route.settings.name == '/homepage',
                );
              });
            } else {
              setState(() {
                _errorMessage = 'Invalid phone number or PIN';
              });
            }
          } else {
            setState(() {
              _errorMessage = 'Invalid phone number or PIN';
            });
          }
        } else {
          setState(() {
            _errorMessage = 'Failed to login: ${response.body}';
          });
        }
      } catch (error) {
        setState(() {
          _errorMessage = 'Failed to login: $error';
        });
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final darkTheme = Provider.of<DarkThemeProvider>(context).darkTheme;
    return Scaffold(
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Stack(
          children: [
            Image.asset(
              "assets/images/news_front_page.png",
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
            Positioned.fill(
              child: Material(
                color: Colors.black.withOpacity(0.2),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white60,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12.withOpacity(0.2),
                                    spreadRadius: 10,
                                    blurRadius: 10,
                                    offset: const Offset(5, 3),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Center(
                                    child: Text(
                                      'Login',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 32,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    cursorColor: darkTheme
                                        ? Colors.black
                                        : Color(0xFF6200EA),
                                    style: TextStyle(
                                        color: darkTheme
                                            ? Colors.black
                                            : Colors.black),
                                    maxLength: 10,
                                    controller: _phoneController,
                                    decoration: const InputDecoration(
                                      labelText: 'Phone Number',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your phone number';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    cursorColor: darkTheme
                                        ? Colors.black
                                        : Color(0xFF6200EA),
                                    style: TextStyle(
                                        color: darkTheme
                                            ? Colors.black
                                            : Colors.black),
                                    obscureText: obscureText,
                                    maxLength: 4,
                                    controller: _pinController,
                                    decoration: InputDecoration(
                                      counterText: '',
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            obscureText = !obscureText;
                                          });
                                        },
                                        icon: obscureText
                                            ? Icon(
                                                Icons.visibility_off_sharp,
                                                color: darkTheme
                                                    ? Colors.grey
                                                    : Colors.grey,
                                              )
                                            : Icon(
                                                Icons.visibility,
                                                color: darkTheme
                                                    ? Colors.grey
                                                    : Colors.grey,
                                              ),
                                      ),
                                      labelText: 'PIN',
                                      border: const OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your PIN';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: _login,
                                      child: const Text('Login'),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  if (_errorMessage.isNotEmpty)
                                    Text(
                                      _errorMessage,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      const Text(
                                        'Don\'t have an account?',
                                        style:
                                            TextStyle(color: Color(0xFF666666)),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            PageTransition(
                                              duration: const Duration(
                                                  milliseconds: 500),
                                              type: PageTransitionType
                                                  .rightToLeft,
                                              child: const SignupPage(),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'Create Account',
                                          style: TextStyle(
                                              color: Color(0xFF6200EA)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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

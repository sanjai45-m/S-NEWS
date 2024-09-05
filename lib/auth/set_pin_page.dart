import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/login_page.dart';
import 'package:flutter_application_1/provider/dark_theme_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class SetPinPage extends StatefulWidget {
  final String phoneNumber;

  const SetPinPage({super.key, required this.phoneNumber});

  @override
  State<SetPinPage> createState() => _SetPinPageState();
}

class _SetPinPageState extends State<SetPinPage> {
  bool obscureText = true;
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _reEnterPinController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String _errorMessage = '';

  Future<void> _setPin() async {
    if (_formKey.currentState!.validate()) {
      String pin = _pinController.text.trim();
      String reEnterPin = _reEnterPinController.text.trim();

      if (pin != reEnterPin) {
        setState(() {
          _errorMessage = 'PIN mismatch.';
        });
        return;
      }

      // Prepare data to be stored in Firebase
      final Map<String, String> userData = {
        'phone': widget.phoneNumber,
        'pin': pin,
      };

      final String url =
          'Url';

      try {
        final http.Response response = await http.put(
          Uri.parse(url),
          body: json.encode(userData),
        );

        if (response.statusCode == 200) {
          // Navigate to the main page on successful PIN set
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => route.settings.name == '/initialPage', // Adjust as needed
          );


        } else {
          setState(() {
            _errorMessage = 'Failed to set PIN: ${response.body}';
          });
        }
      } catch (error) {
        setState(() {
          _errorMessage = 'Failed to set PIN: $error';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DarkThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          body: Center(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    height: 350,
                    decoration: BoxDecoration(
                      color: Colors.white60,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.6),
                          spreadRadius: 5,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Set a 4-digit PIN',
                          style: TextStyle(

                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.darkTheme
                                  ? Colors.grey[600]
                                  : Colors.black),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding:  EdgeInsets.all(8.0),
                          child: TextFormField(
                            style: TextStyle(
                                color: themeProvider.darkTheme
                                    ? Colors.grey[600]
                                    : Colors.black),
                            obscureText: obscureText,
                            controller: _pinController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                hintStyle: TextStyle(
                                    color: themeProvider.darkTheme
                                        ? Colors.grey[600]
                                        : Colors.black),
                                hintText: 'Enter PIN',
                                errorText: _errorMessage.isEmpty
                                    ? null
                                    : _errorMessage,
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        obscureText = !obscureText;
                                      });
                                    },
                                    icon: obscureText
                                        ? Icon(
                                            Icons.visibility_off_sharp,
                                            color: themeProvider.darkTheme
                                                ? Colors.grey[600]
                                                : Colors.black,
                                          )
                                        : Icon(
                                            Icons.visibility,
                                            color: themeProvider.darkTheme
                                                ? Colors.grey[600]
                                                : Colors.black,
                                          ))),
                            maxLength: 4,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your PIN';
                              } else if (value.length != 4) {
                                return 'PIN must be 4 digits';
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            style: TextStyle(
                                color: themeProvider.darkTheme
                                    ? Colors.grey[600]
                                    : Colors.black),
                            obscureText: obscureText,
                            controller: _reEnterPinController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                hintText: 'Re-Enter PIN',
                                hintStyle: TextStyle(
                                    color: themeProvider.darkTheme
                                        ? Colors.grey[600]
                                        : Colors.black),
                                errorText: _errorMessage.isEmpty
                                    ? null
                                    : _errorMessage,
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        obscureText = !obscureText;
                                      });
                                    },
                                    icon: obscureText
                                        ? Icon(
                                            Icons.visibility_off_sharp,
                                            color: themeProvider.darkTheme
                                                ? Colors.grey[600]
                                                : Colors.black,
                                          )
                                        : Icon(
                                            Icons.visibility,
                                            color: themeProvider.darkTheme
                                                ? Colors.grey[600]
                                                : Colors.black,
                                          ))),
                            maxLength: 4,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your PIN';
                              } else if (value.length != 4) {
                                return 'PIN must be 4 digits';
                              }
                              return null;
                            },
                          ),
                        ),
                         SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _setPin,
                          child: const Text('Set PIN'),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

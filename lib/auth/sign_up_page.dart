import 'package:action_slider/action_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import '../provider/dark_theme_provider.dart';
import 'otpPage.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart' as toast;

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  Color _toggleColor = Colors.lightGreenAccent;
  final TextEditingController phoneController = TextEditingController();
  final String _errorMessage = '';

  Future<bool> _checkValidNumberOrNot() async {
    FocusScope.of(context).unfocus();
    final String phoneNumber = phoneController.text.trim();
    final String url = 'baseurl/$phoneNumber.json';

    try {
      final http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        if (response.body != 'null') {
          toast.ToastContext().init(context);
          toast.Toast.show(
            'Phone number already exists',
            duration: toast.Toast.lengthShort,
            gravity: toast.Toast.bottom,
          );

          return false; // Phone number exists
        } else {
          return true; // Phone number is valid
        }
      } else {
        toast.ToastContext().init(context);
        toast.Toast.show(
          'Failed to check phone number: ${response.body}',
          duration: toast.Toast.lengthShort,
          gravity: toast.Toast.bottom,
        );

        return false;
      }
    } catch (error) {
      toast.ToastContext().init(context);
      toast.Toast.show(
        'Failed to check phone number: $error',
        duration: toast.Toast.lengthShort,
        gravity: toast.Toast.bottom,
      );

      return false;
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<DarkThemeProvider>(
      builder: (context, themeProvider, child) => Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Stack(
                    children: [
                      Image.asset(
                        "assets/images/4957136.png",
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.7,
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Form(
                            key: _formKey,
                            child: Center(
                              child: Container(
                                constraints:
                                    const BoxConstraints(maxWidth: 400),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 18.0),
                                      child: Text(
                                        'Sign Up',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: themeProvider.darkTheme
                                              ? Colors.black
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: IntlPhoneField(
                                        controller: phoneController,
                                        decoration: InputDecoration(
                                          labelText: 'Phone Number',
                                          labelStyle: TextStyle(
                                            color: themeProvider.darkTheme
                                                ? Colors.grey[600]
                                                : Colors.grey[600],
                                          ),
                                          border: const OutlineInputBorder(
                                              borderSide: BorderSide()),
                                        ),
                                        initialCountryCode: 'IN',
                                        style: TextStyle(
                                          color: themeProvider.darkTheme
                                              ? Colors.black
                                              : Colors.black,
                                        ),
                                        showDropdownIcon: false,
                                        onChanged: (phone) {
                                          if (kDebugMode) {
                                            print(phone.completeNumber);
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    ActionSlider.standard(
                                      failureIcon: const Icon(Icons.close),
                                      sliderBehavior: SliderBehavior.stretch,
                                      width: 300.0,
                                      backgroundColor: Colors.white,
                                      toggleColor: _toggleColor,
                                      action: (controller) async {
                                        String localPhoneNumber =
                                            phoneController.text.trim();

                                        if (localPhoneNumber.isEmpty) {
                                          controller
                                              .failure(); // Show close icon for empty input
                                          setState(() {
                                            _toggleColor = Colors.red;
                                          });
                                          toast.ToastContext().init(context);
                                          toast.Toast.show(
                                            'Phone number cannot be empty',
                                            duration: toast.Toast.lengthShort,
                                            gravity: toast.Toast.bottom,
                                          );

                                          await Future.delayed(
                                              const Duration(seconds: 1));
                                          controller.reset();
                                          setState(() {
                                            _toggleColor =
                                                Colors.lightGreenAccent;
                                          });
                                          return;
                                        }

                                        if (localPhoneNumber.length != 10) {
                                          controller
                                              .failure(); // Show close icon for invalid length
                                          setState(() {
                                            _toggleColor = Colors.red;
                                          });
                                          toast.ToastContext().init(context);
                                          toast.Toast.show(
                                            'Phone number must be 10 digits',
                                            duration: toast.Toast.lengthShort,
                                            gravity: toast.Toast.bottom,
                                          );

                                          await Future.delayed(
                                              const Duration(seconds: 1));
                                          controller.reset();
                                          setState(() {
                                            _toggleColor =
                                                Colors.lightGreenAccent;
                                          });
                                          return;
                                        }

                                        controller.loading();
                                        await Future.delayed(const Duration(
                                            seconds: 1)); // Simulating delay
                                        final response =
                                            await _checkValidNumberOrNot();

                                        if (response) {
                                          controller.success();
                                          await Future.delayed(const Duration(
                                              seconds:
                                                  1)); // Show success icon before navigation
                                          Navigator.push(
                                            context,
                                            PageTransition(
                                              type: PageTransitionType.size,
                                              alignment: Alignment.bottomCenter,
                                              child: OtpPage(
                                                phoneNumber: localPhoneNumber,
                                              ),
                                            ),
                                          );
                                        } else {
                                          controller
                                              .failure(); // Show close icon for already existing number
                                          setState(() {
                                            _toggleColor = Colors.red;
                                          });
                                          toast.ToastContext().init(context);
                                          toast.Toast.show(
                                            'Phone number already exists',
                                            duration: toast.Toast.lengthShort,
                                            gravity: toast.Toast.bottom,
                                          );
                                          await Future.delayed(
                                              const Duration(seconds: 1));
                                          controller.reset();
                                          setState(() {
                                            _toggleColor =
                                                Colors.lightGreenAccent;
                                          });
                                        }
                                      },
                                      child: Text(
                                        'Slide to Send OTP',
                                        style: TextStyle(
                                          color: themeProvider.darkTheme
                                              ? Colors.black
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    if (_errorMessage.isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          _errorMessage,
                                          style: const TextStyle(
                                              color: Colors.red),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

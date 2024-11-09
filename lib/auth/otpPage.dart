import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:SNEWS/provider/dark_theme_provider.dart';
import 'package:provider/provider.dart';
import 'set_pin_page.dart';

class OtpPage extends StatefulWidget {
  final String phoneNumber;

  const OtpPage({super.key, required this.phoneNumber});

  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _verificationId;
  String _errorMessage = '';
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());

  @override
  void initState() {
    super.initState();
    _verifyPhoneNumber();
  }

  @override
  void dispose() {
    _controllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _verifyPhoneNumber() async {
    String fullPhoneNumber = '+91${widget.phoneNumber}';

    await _auth.verifyPhoneNumber(
      phoneNumber: fullPhoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        if (mounted) {
          await _auth.signInWithCredential(credential);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => SetPinPage(phoneNumber: widget.phoneNumber),
            ),
          );
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (mounted) {
          setState(() {
            _errorMessage = e.message ?? 'Verification failed';
          });
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
          });
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
          });
        }
      },
    );
  }

  void _signInWithOtp() async {
    String otp =
        _controllers.map((controller) => controller.text.trim()).join('');

    if (_verificationId.isNotEmpty) {
      try {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId,
          smsCode: otp,
        );

        await _auth.signInWithCredential(credential);
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => SetPinPage(
                      phoneNumber: widget.phoneNumber,
                    )),
            ModalRoute.withName(
                '/login'), // Keep the login page in the stack if needed
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = e.toString();
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DarkThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
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
                          height: MediaQuery.of(context).size.height,
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
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
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Enter the OTP sent to your phone',
                                      style: TextStyle(
                                          color: themeProvider.darkTheme
                                              ? Colors.grey[600]
                                              : Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: List.generate(
                                        _controllers.length,
                                        (index) => SizedBox(
                                          width: 50,
                                          child: TextField(
                                            style: TextStyle(
                                                color: themeProvider.darkTheme
                                                    ? Colors.grey[600]
                                                    : Colors.black),
                                            controller: _controllers[index],
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                borderSide: const BorderSide(
                                                  width: 2,
                                                ),
                                              ),
                                              isDense: true,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                              counterText: '',
                                            ),
                                            maxLength: 1,
                                            onChanged: (value) {
                                              if (value.isNotEmpty) {
                                                // Move focus to the next field or submit OTP if last field
                                                if (index <
                                                    _controllers.length - 1) {
                                                  FocusScope.of(context)
                                                      .nextFocus();
                                                } else {
                                                  _signInWithOtp();
                                                }
                                              } else {
                                                _controllers[index].clear();
                                                if (index > 0) {
                                                  FocusScope.of(context)
                                                      .previousFocus();
                                                }
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    // ElevatedButton(
                                    //   onPressed: _signInWithOtp,
                                    //   child: const Text('Verify OTP'),
                                    // ),
                                    const SizedBox(height: 20),
                                    if (_errorMessage.isNotEmpty)
                                      Text(
                                        _errorMessage,
                                        style:
                                            const TextStyle(color: Colors.red),
                                      ),
                                  ],
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
        );
      },
    );
  }
}

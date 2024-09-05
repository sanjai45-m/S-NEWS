import 'dart:io';
import 'package:cool_alert/cool_alert.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Home_feed/stylish_appbar.dart';
import 'package:flutter_application_1/auth/login_page.dart';
import 'package:flutter_application_1/constant_classes/utils.dart';
import 'package:flutter_application_1/settings/profile_page.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import '../provider/dark_theme_provider.dart';
import '../provider/settings_provider.dart';
import '../provider/user_provider.dart';
import 'change_password.dart';
import 'package:toast/toast.dart' as toast;

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isEditing = false;
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _pinController = TextEditingController();
  String? _profileImageUrl;
  final _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStoredNumber();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.fetchUserData().then((_) {
      setState(() {
        _firstNameController.text = userProvider.firstName;
        _emailController.text = userProvider.email;
        _pinController.text = userProvider.pin;
        _profileImageUrl = userProvider.profileImageUrl;
      });
    });
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    _phoneNumberController.text = settingsProvider.userPhoneNumber;
  }

  void _fetchStoredNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phoneNumber = prefs.getString('phoneNumber') ?? '';
    setState(() {
      _phoneNumberController.text = phoneNumber;
    });
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 100,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.purple,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: false,
              aspectRatioPresets: [
                CropAspectRatioPreset.original,
              ],
            ),
            IOSUiSettings(
              title: 'Cropper',
              aspectRatioPresets: [],
            ),
            WebUiSettings(
              context: context,
              presentStyle: WebPresentStyle.dialog,
              size: const CropperSize(
                width: 520,
                height: 520,
              ),
            ),
          ],
        );

        if (croppedFile != null) {
          setState(() {
            _profileImageUrl = croppedFile.path;
          });

          String imageUrl = await _uploadImage(croppedFile.path);
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          await userProvider.updateProfileImage(imageUrl);

          setState(() {
            _profileImageUrl = imageUrl;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error picking image: $e");
      }
    }
  }

  Future<String> _uploadImage(String imagePath) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(
        File(imagePath), SettableMetadata(contentType: 'image/jpeg'));
    return await ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    Color appThemeColor = Theme.of(context).colorScheme.primary;
    super.build(context); // Add this line to ensure the state is preserved
    ToastContext().init(context);
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeProvider.darkTheme;
    final color = Utils(context).getColor;
    final userProvider = Provider.of<UserProvider>(context);
    return Consumer<DarkThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            backgroundColor: isDarkMode ? appThemeColor : appThemeColor,
            title: Padding(
              padding: const EdgeInsets.all(100.0),
              child: Row(
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child: Lottie.network(
                          'Url')),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Settings",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.white),
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
          body: Container(
            color: themeProvider.darkTheme
                ? Colors.black.withOpacity(0.0)
                : Colors.white60.withOpacity(0.1),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: MediaQuery.of(context).size.width * 0.3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              MediaQuery.of(context).size.width * 0.15),
                          child: _profileImageUrl != null
                              ? (_profileImageUrl!.startsWith('http')
                                  ? GestureDetector(
                                      onTap: () {
                                        context.pushTransparentRoute(
                                            ProfilePage());
                                      },
                                      child: Hero(
                                        tag: "profile-1",
                                        child: Image.network(
                                          _profileImageUrl!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  : Image.file(
                                      File(_profileImageUrl!),
                                      fit: BoxFit.cover,
                                    ))
                              : Image.asset(
                                  'assets/images/default_profile.jpg',
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.grey,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: IconButton(
                              icon: const Icon(
                                Icons.camera_alt_outlined,
                                size: 20,
                              ),
                              onPressed: _pickImage,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    height: MediaQuery.of(context).size.height * 0.53,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: themeProvider.darkTheme
                          ? Colors.grey[800]
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black12.withOpacity(0.4)
                              : Colors.grey.withOpacity(0.4),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'User Info',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.darkTheme
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            SizedBox(
                              width: 100,
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 10),
                              child: ElevatedButton.icon(
                                icon: Icon(_isEditing ? Icons.save : Icons.edit,
                                    size: 16),
                                onPressed: () {
                                  setState(() {
                                    if (_isEditing) {
                                      userProvider.updateUserData(
                                        _firstNameController.text,
                                        _emailController.text,
                                        _pinController.text,
                                      );
                                      CoolAlert.show(
                                        context: context,
                                        type: CoolAlertType.success,
                                        text: "Your Profile Updated!",
                                      );
                                    }
                                    _isEditing = !_isEditing;
                                  });
                                },
                                label: Text(_isEditing ? "Save" : "Edit"),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _firstNameController,
                          readOnly: !_isEditing,
                          decoration: InputDecoration(
                            labelText: 'First Name',
                            labelStyle: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : appThemeColor),
                            filled: true,
                            fillColor: Colors.transparent,
                            border: _isEditing
                                ? OutlineInputBorder(
                                    borderSide: BorderSide(color: color),
                                  )
                                : InputBorder.none,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _emailController,
                          readOnly: !_isEditing,
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : appThemeColor),
                            labelText: 'Email',
                            filled: true,
                            fillColor: Colors.transparent,
                            border: _isEditing
                                ? OutlineInputBorder(
                                    borderSide: BorderSide(color: color),
                                  )
                                : InputBorder.none,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: TextEditingController(
                              text: userProvider.phoneNumber),
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : appThemeColor),
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _pinController,
                          obscureText: true,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'PIN',
                            labelStyle: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : appThemeColor),
                            filled: true,
                            fillColor: Colors.transparent,
                            border: _isEditing
                                ? OutlineInputBorder(
                                    borderSide: BorderSide(color: color),
                                  )
                                : InputBorder.none,
                            suffix: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: isDarkMode
                                      ? appThemeColor
                                      : appThemeColor),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ChangePasswordPage()),
                                );
                              },
                              child: const Text("Change"),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    selectedTileColor: appThemeColor,
                    activeColor: appThemeColor,
                    title: Text(
                      themeProvider.darkTheme ? 'Dark' : 'Light',
                      style: const TextStyle(fontSize: 20),
                    ),
                    secondary: Icon(
                      themeProvider.darkTheme
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    value: themeProvider.darkTheme,
                    onChanged: (bool value) {
                      themeProvider.darkThemes = value;
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.privacy_tip,
                      color: appThemeColor,
                    ),
                    title: Text(
                      "Private and Policy ",
                      style: const TextStyle(fontSize: 20),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios_outlined),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.description,
                      color: appThemeColor,
                    ),
                    title: Text(
                      "Terms and Conditions",
                      style: const TextStyle(fontSize: 20),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios_outlined),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Center(
                    child: TextButton.icon(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Logout"),
                              content: const Text(
                                  "Are you sure you want to logout?"),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Dismiss the dialog
                                  },
                                ),
                                TextButton(

                                  child: const Text("Logout"),
                                  onPressed: () async {
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    // Clear all other preferences except 'isFirstLaunch'
                                    await prefs.remove('isPhoneNumber');
                                    await prefs.remove('someOtherKey');
                                    // Ensure 'isFirstLaunch' remains false
                                    toast.Toast.show("Logout Successfully",
                                        duration: toast.Toast.lengthShort,
                                        gravity: toast.Toast.bottom);

                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(builder: (context) => const LoginPage()),
                                          (Route<dynamic> route) => false,
                                    );
                                  },
                                ),

                              ],
                            );
                          },
                        );
                      },
                      label: Text(
                        "Logout",
                        style: TextStyle(color: color, fontSize: 20),
                      ),
                      icon:  Icon(
                        Icons.logout_sharp,
                        color: appThemeColor,
                      ),
                    ),
                  ),
                  const SizedBox(
                      height:
                          120), // Add some space at the bottom to ensure the logout button is visible when scrolled
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

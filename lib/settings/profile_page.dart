import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/user_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return DismissiblePage(
      onDismissed: () {
      Navigator.pop(context);
    },
      child: Scaffold(

        backgroundColor: Colors.black,
        body: Center(
          child: Hero(
              tag: "profile-1",
              child: Image.network(userProvider.profileImageUrl.toString())),
        ),
      ),
    );
  }
}

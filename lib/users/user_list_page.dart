import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:SNEWS/provider/dark_theme_provider.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';

class UsersListPage extends StatelessWidget {
  final DatabaseReference _requestsRef =
      FirebaseDatabase.instance.ref().child('chat_requests');
  final DatabaseReference _usersRef =
      FirebaseDatabase.instance.ref().child('users');

  UsersListPage({super.key});

  Future<void> _sendChatRequest(BuildContext context, String receiverId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final senderId = userProvider.phoneNumber;
    final senderName = userProvider.firstName; // Fetch sender's name
    final senderImageUrl =
        userProvider.profileImageUrl; // Fetch sender's image URL

    final chatRequest = {
      'senderId': senderId,
      'receiverId': receiverId,
      'senderName': senderName,
      'senderImageUrl': senderImageUrl,
      'status': 'pending',
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      await _requestsRef.push().set(chatRequest);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Chat request sent."),
          backgroundColor: Provider.of<DarkThemeProvider>(context).darkTheme
              ? Colors.white
              : Colors.black12,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("You Already Sends Requests."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUserId = userProvider.phoneNumber;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Users',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
      body: StreamBuilder(
        stream: _usersRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.snapshot.value;
          if (data is! Map<dynamic, dynamic>) {
            return const Center(child: Text("Unexpected data format"));
          }

          final Map<dynamic, dynamic> users = data;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userId = users.keys.elementAt(index);
              final userData = users[userId];

              if (userData is! Map<dynamic, dynamic>) {
                return const Center(child: Text("Unexpected user data format"));
              }

              if (userId == currentUserId) {
                return Container();
              }

              return Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: userData['profileImageUrl'] != null &&
                            userData['profileImageUrl'].isNotEmpty
                        ? NetworkImage(userData['profileImageUrl'])
                        : const AssetImage('assets/images/default_profile.jpg')
                            as ImageProvider,
                  ),
                  title: Text(
                    userData['firstName'] ?? 'New User',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.headline6?.color,
                    ),
                  ),
                  tileColor: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  trailing: ElevatedButton(
                    onPressed: () => _sendChatRequest(context, userId),
                    child: const Text("Send Request"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

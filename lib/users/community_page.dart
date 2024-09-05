import 'package:animated_floating_buttons/widgets/animated_floating_action_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_application_1/users/community_skeleton_card.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import '../provider/dark_theme_provider.dart';
import 'chat_room_page.dart';
import '../provider/user_provider.dart';
import 'personal_chat_page.dart'; // Import the PersonalChatPage

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final GlobalKey<AnimatedFloatingActionButtonState> key =
  GlobalKey<AnimatedFloatingActionButtonState>();

  final DatabaseReference _chatGroupsRef =
  FirebaseDatabase.instance.ref().child('chat_groups');
  final DatabaseReference _usersRef =
  FirebaseDatabase.instance.ref().child('users');
  final DatabaseReference _requestsRef =
  FirebaseDatabase.instance.ref().child('chat_requests');
  final DatabaseReference _acceptedChatsRef = FirebaseDatabase.instance
      .ref()
      .child('accepted_chats'); // New reference for accepted chats

  final Set<String> _selectedGroups = {};
  String? _longPressedGroup;

  Future<void> _fetchChatRequests() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserId = userProvider.phoneNumber;

    try {
      final requestsSnapshot = await _requestsRef
          .orderByChild('receiverId')
          .equalTo(currentUserId)
          .get();

      if (!requestsSnapshot.exists) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Chat Request"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("No Chat Request"),
                    Container(
                        height: 200,
                        width: 250,
                        child: RiveAnimation.asset(
                          'assets/lottie/new_notification_here!.riv',
                          fit: BoxFit.contain,
                        ))
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            });
      }

      final requestsMap = requestsSnapshot.value as Map<dynamic, dynamic>?;

      if (requestsMap == null || requestsMap.isEmpty) return;

      final requestsList = requestsMap.entries.toList();

      showDialog(
        traversalEdgeBehavior: TraversalEdgeBehavior.closedLoop,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Chat Requests"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: requestsList.map((entry) {
                final requestData = entry.value as Map<dynamic, dynamic>;

                final userName =
                    requestData['senderName'] as String? ?? 'Unknown User';
                final userImageUrl =
                    requestData['senderImageUrl'] as String? ?? '';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: userImageUrl.isNotEmpty
                        ? NetworkImage(userImageUrl)
                        : const AssetImage('assets/images/default_profile.jpg')
                    as ImageProvider,
                  ),
                  title: Text(userName),
                  subtitle: const Text('Request to chat'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _acceptChatRequest(entry.key, requestData);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _declineChatRequest(entry.key);
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      );
    } catch (e) {
      print("Error fetching chat requests: $e");
    }
  }

  Future<void> _acceptChatRequest(
      String requestId, Map<dynamic, dynamic> requestData) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserId = userProvider.phoneNumber;

    final senderId = requestData['senderId'] as String? ?? '';
    final senderName = requestData['senderName'] as String? ?? 'Unknown User';
    final senderImageUrl = requestData['senderImageUrl'] as String? ?? '';

    // Add to accepted chats for both sender and receiver
    await _acceptedChatsRef.child(currentUserId).child(requestId).set({
      'userId': senderId,
      'userName': senderName,
      'userImageUrl': senderImageUrl,
    });

    await _acceptedChatsRef.child(senderId).child(requestId).set({
      'userId': currentUserId,
      'userName': userProvider.firstName,
      'userImageUrl': userProvider.profileImageUrl,
    });

    // Remove from chat requests
    await _requestsRef.child(requestId).remove();
  }

  Future<void> _declineChatRequest(String requestId) async {
    // Remove from chat requests
    await _requestsRef.child(requestId).remove();
  }

  Future<void> _removeChatGroups() async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
              'Are you sure you want to delete the selected chat groups?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
          ],
        );
      },
    );

    if (confirmation == true) {
      for (String group in _selectedGroups) {
        await _chatGroupsRef.child(group).remove();
      }
      setState(() {
        _selectedGroups.clear();
        _longPressedGroup = null;
      });
    }
  }

  Future<void> _handleAcceptedChats() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserId = userProvider.phoneNumber;

    try {
      final acceptedChatsSnapshot =
      await _acceptedChatsRef.child(currentUserId).get();

      if (!acceptedChatsSnapshot.exists) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Accepted Chats"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("No accepted chats."),
                  Lottie.network(
                      'Url')
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }

      final acceptedChatsMap =
      acceptedChatsSnapshot.value as Map<dynamic, dynamic>?;

      if (acceptedChatsMap == null || acceptedChatsMap.isEmpty) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Accepted Chats"),
              content: const Text("No accepted chats."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }

      final acceptedList = acceptedChatsMap.entries.toList();

      final acceptedChats = acceptedList.map((entry) {
        final chatId = entry.key as String;
        final chatData = entry.value as Map<dynamic, dynamic>;

        return {
          'chatId': chatId,
          'userId': chatData['userId'] as String? ?? '',
          'userName': chatData['userName'] as String? ?? 'Unknown User',
          'userImageUrl': chatData['userImageUrl'] as String? ??
              'assets/images/default_profile.jpg',
        };
      }).toList();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Accepted Chats"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: acceptedChats.map((chat) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: chat['userImageUrl'] != null &&
                        chat['userImageUrl']!.isNotEmpty
                        ? NetworkImage(chat['userImageUrl']!)
                        : const AssetImage('assets/images/default_profile.jpg')
                    as ImageProvider,
                  ),
                  title: Text(chat['userName'] as String),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PersonalChatPage(
                          userId: chat['userId'] as String,
                          userName: chat['userName'] as String,
                          userImageUrl: chat['userImageUrl'] as String,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          );
        },
      );
    } catch (e) {
      print("Error fetching accepted chats: $e");
    }
  }

  Future<int> _getUnreadMessagesCount(String userId, String groupName) async {
    final groupMessagesRef = _chatGroupsRef.child(groupName).child('messages');
    final messagesSnapshot = await groupMessagesRef.get();

    if (!messagesSnapshot.exists) {
      return 0;
    }

    final messagesMap = messagesSnapshot.value as Map<dynamic, dynamic>;
    int unreadCount = 0;

    messagesMap.forEach((key, value) {
      final messageData = value as Map<dynamic, dynamic>;
      if (messageData['receiverId'] == userId &&
          !(messageData['read'] ?? false)) {
        unreadCount++;
      }
    });

    return unreadCount;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userId = userProvider.phoneNumber;
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeProvider.darkTheme;
    Color appThemeColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? appThemeColor : appThemeColor,
        title: Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: Row(
            children: [
              SizedBox(
                  height: 50,
                  width: 50,
                  child: Lottie.network(
                      'Url')),
              Text(
                "Community",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.white),
              ),
            ],
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Lottie.network(
              'uRL',
              height: 30,
              width: 30),
          onPressed: _fetchChatRequests,
        ),
        actions: [
          IconButton(
            icon: Lottie.network(
              'uRL',
            ),
            onPressed: _handleAcceptedChats, // Show accepted chats
          ),
          if (_selectedGroups.isNotEmpty)
            IconButton(
              onPressed: _removeChatGroups,
              icon: const Icon(Icons.delete),
            ),
        ],
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
        stream: _chatGroupsRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            // Display SkeletonCard while loading
            return ListView.builder(
              itemCount: 10, // Number of skeleton cards to display
              itemBuilder: (context, index) {
                return const CommunitySkeletonCard(); // Display skeleton cards
              },
            );
          }

          final Map<dynamic, dynamic> chatGroups =
          snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          return ListView.builder(
            itemCount: chatGroups.length,
            itemBuilder: (context, index) {


              final String groupName = chatGroups.keys.elementAt(index);
              final groupData = chatGroups[groupName] as Map<dynamic, dynamic>;
              final lastMessage = groupData['lastMessage'] ?? {};
              final profileImageUrl = groupData['profileImageUrl'] ?? '';
              final lastSender = lastMessage['firstName'] ?? '😇';
              final messageText = lastMessage['message'] ?? 'Start to Chat';



              return FutureBuilder<int>(
                future: _getUnreadMessagesCount(userId, groupName),
                builder: (context, unreadSnapshot) {
                  final unreadCount = unreadSnapshot.data ?? 0;

                  return Container(
                    margin:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withOpacity(0.2),
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: profileImageUrl.isNotEmpty
                            ? NetworkImage(profileImageUrl)
                            : const AssetImage(
                            'assets/images/default_profile.jpg')
                        as ImageProvider,
                      ),
                      title: Text(groupName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        '$lastSender: $messageText',
                        style:
                        const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          if (_longPressedGroup == groupName)
                            Checkbox(
                              value: _selectedGroups.contains(groupName),
                              onChanged: (bool? isChecked) {
                                setState(() {
                                  if (isChecked == true) {
                                    _selectedGroups.add(groupName);
                                  } else {
                                    _selectedGroups.remove(groupName);
                                  }
                                });
                              },
                            ),
                          if (unreadCount > 0)
                            CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 12,
                              child: Text(
                                unreadCount.toString(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                      onLongPress: () {
                        setState(() {
                          if (_longPressedGroup == groupName) {
                            _longPressedGroup = null;
                          } else {
                            _longPressedGroup = groupName;
                          }
                        });
                      },
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChatRoomPage(
                              groupName: groupName,
                              groupProfileImage: profileImageUrl,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
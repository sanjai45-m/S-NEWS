import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:SNEWS/provider/dark_theme_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../provider/user_provider.dart';
import 'package:http/http.dart' as http;

class ChatRoomPage extends StatefulWidget {
  final String groupName;
  final String groupProfileImage;

  const ChatRoomPage({
    super.key,
    required this.groupName,
    required this.groupProfileImage,
  });

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final DatabaseReference _chatGroupsRef =
      FirebaseDatabase.instance.ref().child('chat_groups');
  final DatabaseReference _chatRef =
      FirebaseDatabase.instance.ref().child('chat');
  final DatabaseReference _usersRef =
      FirebaseDatabase.instance.ref().child('users');
  late StreamSubscription<DatabaseEvent> _chatSubscription;
  List<Map<String, dynamic>> _messages = [];
  ScrollController? _scrollController;
  final ImagePicker _picker = ImagePicker();

  bool isHavingText = false;

  @override
  void initState() {
    super.initState();
    _updateLastReadTimestamp();
    _scrollController = ScrollController();

    _chatSubscription =
        _chatRef.child(widget.groupName).onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      final messages = <Map<String, dynamic>>[];

      data.forEach((key, value) {
        final messageData = value as Map<dynamic, dynamic>?;
        if (messageData != null) {
          messages.add({
            'key': key,
            'phoneNumber': messageData['phoneNumber'],
            'message': messageData['message'],
            'mediaUrl': messageData['mediaUrl'],
            'profileImageUrl': messageData['profileImageUrl'],
            'timestamp': messageData['timestamp'],
            'name': messageData['name'],
          });
        }
      });

      messages.sort((a, b) => DateTime.parse(a['timestamp'] as String)
          .compareTo(DateTime.parse(b['timestamp'] as String)));

      if (mounted) {
        setState(() {
          _messages = messages;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController!
              .jumpTo(_scrollController!.position.maxScrollExtent);
        });
      }
    });

    _messageController.addListener(_updateSendButtonState);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _chatSubscription.cancel();
    _scrollController!.dispose();
    super.dispose();
  }

  void _updateSendButtonState() {
    setState(() {
      isHavingText = _messageController.text.isNotEmpty;
    });
  }

  Future<void> _updateLastReadTimestamp() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.phoneNumber;
    final timestamp = DateTime.now().toIso8601String();

    await _usersRef
        .child(userId)
        .child('lastRead')
        .child(widget.groupName)
        .set(timestamp);
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      final messageText = _messageController.text;
      _messageController.clear();
      _scrollController!.animateTo(
        _scrollController!.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      setState(() {});

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final message = {
        'phoneNumber': userProvider.phoneNumber,
        'message': messageText,
        'profileImageUrl': userProvider.profileImageUrl,
        'timestamp': DateTime.now().toIso8601String(),
        'name': userProvider.firstName,
      };

      try {
        await _chatRef.child(widget.groupName).push().set(message);

        await _chatGroupsRef.child(widget.groupName).update({
          'lastMessage': {
            'message': messageText,
            'timestamp': DateTime.now().toIso8601String(),
            'firstName': userProvider.firstName
          },
        });

        await _notifyAllUsers(
          messageText,
          onSuccess: (msg) {
            print(msg);
          },
          onError: (err) {
            print(err);
          },
        );
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  Future<void> _notifyAllUsers(String message,
      {Function(String)? onSuccess, Function(String)? onError}) async {
    final url = 'baseurl';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': message}),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
        if (onSuccess != null) {
          onSuccess('Notification sent successfully');
        }
      } else {
        print('Failed to send notification: ${response.body}');
        if (onError != null) {
          onError('Failed to send notification: ${response.body}');
        }
      }
    } catch (e) {
      print('Error sending notification: $e');
      if (onError != null) {
        onError('Error sending notification: $e');
      }
    }
  }

  Future<void> _sendMedia(File mediaFile) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final timestamp = DateTime.now().toIso8601String();

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('media/${timestamp}_${mediaFile.uri.pathSegments.last}');
      final uploadTask = storageRef.putFile(mediaFile);

      final taskSnapshot = await uploadTask;

      final mediaUrl = await taskSnapshot.ref.getDownloadURL();

      final message = {
        'phoneNumber': userProvider.phoneNumber,
        'message': '',
        'mediaUrl': mediaUrl,
        'profileImageUrl': userProvider.profileImageUrl,
        'timestamp': timestamp,
        'name': userProvider.firstName,
      };

      await _chatRef.child(widget.groupName).push().set(message);

      await _chatGroupsRef.child(widget.groupName).update({
        'lastMessage': {
          'message': 'Media sent',
          'timestamp': timestamp,
        },
      });
    } catch (e) {
      print('Error uploading media: $e');
    }
  }

  Future<void> _pickMedia() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File mediaFile = File(pickedFile.path);
      await _sendMedia(mediaFile);
    }
  }

  void _showMessageOptions(Map<String, dynamic> message) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit Message'),
                onTap: () {
                  _messageController.text = message['message'] as String;
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Message'),
                onTap: () async {
                  await _chatRef
                      .child(widget.groupName)
                      .child(message['key'])
                      .remove();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy, color: Colors.green),
                title: const Text('Copy Message'),
                onTap: () {
                  Clipboard.setData(
                      ClipboardData(text: message['message'] as String));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _clearAllMessages() async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear All Messages'),
          content: const Text(
            'Are you sure you want to clear all messages? This action cannot be undone.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (confirmation == true) {
      await _chatRef.child(widget.groupName).remove();
    }
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return DateFormat('h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<DarkThemeProvider>(context).darkTheme;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipOval(
              child: CircleAvatar(
                backgroundImage: widget.groupProfileImage.isNotEmpty
                    ? NetworkImage(widget.groupProfileImage)
                    : null,
                child: widget.groupProfileImage.isEmpty
                    ? const Icon(Icons.group, size: 24)
                    : null,
                radius: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.groupName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearAllMessages,
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isCurrentUser =
                    message['phoneNumber'] == userProvider.phoneNumber;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  child: GestureDetector(
                    onLongPress: () => _showMessageOptions(message),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: isCurrentUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!isCurrentUser)
                          CircleAvatar(
                            radius: 18,
                            backgroundImage:
                                message['profileImageUrl'] != null &&
                                        message['profileImageUrl'].isNotEmpty
                                    ? NetworkImage(message['profileImageUrl'])
                                    : null,
                            child: message['profileImageUrl'] == null ||
                                    message['profileImageUrl'].isEmpty
                                ? const Icon(Icons.person, size: 20)
                                : null,
                          ),
                        if (!isCurrentUser) const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isCurrentUser
                                  ? Color(0xFFE7FFDB)
                                  : Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16.0),
                                topRight: Radius.circular(16.0),
                                bottomLeft: isCurrentUser
                                    ? Radius.circular(16.0)
                                    : Radius.circular(0.0),
                                bottomRight: isCurrentUser
                                    ? Radius.circular(0.0)
                                    : Radius.circular(16.0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isCurrentUser)
                                  Text(
                                    message['name'] ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                if (message['mediaUrl'] != null &&
                                    message['mediaUrl'].isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12.0),
                                    child: Image.network(
                                      message['mediaUrl'],
                                      height: 150,
                                      width: 150,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                if (message['message'] != null &&
                                    message['message'].isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      message['message'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: isCurrentUser
                                            ? Colors.black
                                            : Colors.black87,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _formatTimestamp(message['timestamp']),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isCurrentUser
                                            ? Colors.black54
                                            : Colors.black45,
                                      ),
                                    ),
                                    if (isCurrentUser) const SizedBox(width: 4),
                                    if (isCurrentUser)
                                      Icon(
                                        Icons.done_all,
                                        size: 16,
                                        color: (message['isRead'] != null &&
                                                message['isRead'] == true)
                                            ? Colors.blue
                                            : Colors.grey,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isCurrentUser) const SizedBox(width: 8),
                        if (isCurrentUser)
                          CircleAvatar(
                            radius: 18,
                            backgroundImage:
                                message['profileImageUrl'] != null &&
                                        message['profileImageUrl'].isNotEmpty
                                    ? NetworkImage(message['profileImageUrl'])
                                    : null,
                            child: message['profileImageUrl'] == null ||
                                    message['profileImageUrl'].isEmpty
                                ? const Icon(Icons.person, size: 20)
                                : null,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo, color: Colors.blue),
                  onPressed: _pickMedia,
                ),
                Expanded(
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type a message',
                      ),
                      minLines: 1,
                      maxLines: 4,
                      style: TextStyle(
                          fontSize: 16,
                          color: themeProvider ? Colors.black : Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: isHavingText ? Colors.blue : Colors.grey,
                  child: IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    onPressed: isHavingText ? _sendMessage : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';

class PersonalChatPage extends StatefulWidget {
  final String userId;
  final String userName;
  final String userImageUrl;

  const PersonalChatPage({
    Key? key,
    required this.userId,
    required this.userName,
    required this.userImageUrl,
  }) : super(key: key);

  @override
  _PersonalChatPageState createState() => _PersonalChatPageState();
}

class _PersonalChatPageState extends State<PersonalChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final DatabaseReference _personalChatsRef = FirebaseDatabase.instance.ref().child('personal_chats');
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final message = {
        'senderId': userProvider.phoneNumber,
        'receiverId': widget.userId,
        'message': _messageController.text,
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': false,
      };

      await _personalChatsRef.push().set(message);
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }
  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return DateFormat('h:mm a').format(dateTime);
  }
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUserId = userProvider.phoneNumber;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.userImageUrl.isNotEmpty
                  ? NetworkImage(widget.userImageUrl)
                  : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
            ),
            const SizedBox(width: 10),
            Text(widget.userName),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _personalChatsRef.orderByChild('timestamp').onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return Center(child: Lottie.network('Url'));
                }

                final Map<dynamic, dynamic> messages = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                final List<Map<dynamic, dynamic>> messageList = messages.values
                    .cast<Map<dynamic, dynamic>>()
                    .where((message) =>
                (message['senderId'] == currentUserId && message['receiverId'] == widget.userId) ||
                    (message['senderId'] == widget.userId && message['receiverId'] == currentUserId))
                    .toList();

                // Sort messages by timestamp
                messageList.sort((a, b) => DateTime.parse(a['timestamp']).compareTo(DateTime.parse(b['timestamp'])));

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messageList.length,
                  itemBuilder: (context, index) {
                    final message = messageList[index];
                    final isCurrentUser = message['senderId'] == currentUserId;
                    final timestamp = DateTime.parse(message['timestamp']).toLocal();
                    final formattedTime = '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          if (!isCurrentUser)
                            CircleAvatar(
                              radius: 18,
                              backgroundImage: widget.userImageUrl.isNotEmpty
                                  ? NetworkImage(widget.userImageUrl)
                                  : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
                            ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: isCurrentUser ? const Color(0xFFE7FFDB) : Colors.white,
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
                                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                                  child: Column(
                                    crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                    children: [
                                      if (message['mediaUrl'] != null && message['mediaUrl'].isNotEmpty)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12.0),
                                          child: Image.network(
                                            message['mediaUrl'],
                                            height: 150,
                                            width: 150,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      if (message['message'] != null && message['message'].isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4.0),
                                          child: Text(
                                            message['message'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: isCurrentUser ? Colors.black : Colors.black87,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      if (isCurrentUser && message['isRead'] != null)
                                        Icon(
                                          Icons.done_all,
                                          size: 16,
                                          color: (message['isRead'] == true)
                                              ? Colors.blue
                                              : Colors.grey,
                                        ),
                                    ],
                                  ),
                                ),
                                if (index == messageList.length - 1)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                    _formatTimestamp(message['timestamp']),
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Message...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

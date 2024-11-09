import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:SNEWS/provider/dark_theme_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:provider/provider.dart';

class CreateChatGroupPage extends StatefulWidget {
  const CreateChatGroupPage({super.key});

  @override
  _CreateChatGroupPageState createState() => _CreateChatGroupPageState();
}

class _CreateChatGroupPageState extends State<CreateChatGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final DatabaseReference _chatGroupsRef =
      FirebaseDatabase.instance.ref().child('chat_groups');
  String? _imageUrl;

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      String imageUrl = await _uploadImageToFirebase(image.path);
      setState(() {
        _imageUrl = imageUrl;
      });
    }
  }

  Future<String> _uploadImageToFirebase(String imagePath) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('group_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(File(imagePath));
    return await ref.getDownloadURL();
  }

  Future<void> _createChatGroup() async {
    if (_groupNameController.text.isNotEmpty) {
      await _chatGroupsRef.child(_groupNameController.text).set({
        'created_at': DateTime.now().toIso8601String(),
        'profileImageUrl': _imageUrl ?? '',
      });

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context).darkTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Chat Group'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              style: TextStyle(color: Colors.black),
              controller: _groupNameController,
              decoration: InputDecoration(
                labelText: 'Group Name...',
                labelStyle: TextStyle(
                    color: themeProvider ? Color(0xFF808080) : Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickAndUploadImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Pick Image', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
            _imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _imageUrl!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Text('No image selected',
                    style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createChatGroup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Create', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

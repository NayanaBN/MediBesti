import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<types.Message> _messages = [];
  final types.User _currentUser = const types.User(id: 'user_1');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _listenToMessages();
  }

  void _listenToMessages() {
    _firestore.collection('chats').orderBy('createdAt', descending: true).snapshots().listen((snapshot) {
      final messages = snapshot.docs.map((doc) {
        final data = doc.data();
        return types.TextMessage(
          author: types.User(id: data['authorId']),
          createdAt: data['createdAt'],
          id: doc.id,
          text: data['text'],
        );
      }).toList();

      setState(() {
        _messages.clear();
        _messages.addAll(messages);
      });
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final messageId = const Uuid().v4();

    final textMessage = {
      'authorId': _currentUser.id,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'id': messageId,
      'text': message.text,
    };

    _firestore.collection('chats').doc(messageId).set(textMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat with Doctor")),
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _currentUser,
      ),
    );
  }
}

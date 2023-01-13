import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_app/core/helpers/navigation_helper.dart';
import 'package:flutter_firebase_chat_app/core/services/database_service.dart';
import 'package:flutter_firebase_chat_app/core/widgets/base_view.dart';
import 'package:flutter_firebase_chat_app/core/widgets/custom_tile/message_tile.dart';
import 'package:flutter_firebase_chat_app/features/group/group_info.dart';

class ChatPage extends StatefulWidget {
  const ChatPage(
      {Key? key,
      required this.groupId,
      required this.groupName,
      required this.userName})
      : super(key: key);
  final String groupId;
  final String groupName;
  final String userName;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageEditingController = TextEditingController();
  Stream<QuerySnapshot>? chats;
  String adminName = "";

  @override
  void initState() {
    getChatAndAdmin();
    super.initState();
  }

  getChatAndAdmin() async {
    await DatabaseService().getChats(widget.groupId).then((value) {
      setState(() {
        chats = value;
      });
    });
    await DatabaseService().getGroupAdmin(widget.groupId).then((value) {
      setState(() {
        adminName = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: Text(widget.groupName),
          actions: [
            IconButton(
                onPressed: () {
                  nextScreen(
                      context,
                      GroupInfo(
                        groupId: widget.groupId,
                        groupName: widget.groupName,
                        adminName: adminName,
                      ));
                },
                icon: const Icon(Icons.info))
          ],
        ),
        child: Stack(
          children: [
            // chat messages here
            chatMessages(),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                color: Colors.grey[700],
                child: Row(
                  children: [
                    Expanded(
                        child: TextFormField(
                      controller: messageEditingController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          hintText: "Message ...",
                          hintStyle:
                              TextStyle(color: Colors.white, fontSize: 16),
                          border: InputBorder.none),
                    )),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        sendMessage();
                      },
                      child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.all(12),
                          child: const Icon(Icons.send, color: Colors.white)),
                    )
                  ],
                ),
              ),
            )
          ],
        ));
  }

  sendMessage() {
    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageEditingController.text,
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };
      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      messageEditingController.clear();
    }
  }

  chatMessages() {
    return StreamBuilder(
        stream: chats,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  return MessageTile(
                    message: snapshot.data.docs[index]["message"],
                    sender: snapshot.data.docs[index]["sender"],
                    sendByMe:
                        widget.userName == snapshot.data.docs[index]["sender"],
                  );
                });
          } else {
            return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor));
          }
        });
  }
}

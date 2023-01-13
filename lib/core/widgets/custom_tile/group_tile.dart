import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_app/core/helpers/navigation_helper.dart';
import 'package:flutter_firebase_chat_app/features/chat/chat_page.dart';

class GroupTile extends StatefulWidget {
  const GroupTile(
      {Key? key,
      required this.userName,
      required this.groupId,
      required this.groupName})
      : super(key: key);

  final String userName;
  final String groupId;
  final String groupName;

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        nextScreen(
            context,
            ChatPage(
              groupName: widget.groupName,
              groupId: widget.groupId,
              userName: widget.userName,
            ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                widget.groupName.substring(0, 1).toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
            title: Text(widget.groupName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              "Join the conversation as ${widget.userName}",
              style: const TextStyle(fontSize: 13),
            )),
      ),
    );
  }
}

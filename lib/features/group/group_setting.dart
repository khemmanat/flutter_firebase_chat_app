import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_app/core/widgets/base_view.dart';

class GroupSetting extends StatefulWidget {
  const GroupSetting({Key? key, required this.groupId, required this.groupName})
      : super(key: key);
  final String groupId;
  final String groupName;

  @override
  State<GroupSetting> createState() => _GroupSettingState();
}

class _GroupSettingState extends State<GroupSetting> {
  @override
  Widget build(BuildContext context) {
    return BaseView(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                ListTile(
                  title: const Text("Leave Group"),
                  subtitle: const Text("Group Name"),
                  trailing: const Icon(Icons.exit_to_app),
                ),
              ],
            )));
  }
}

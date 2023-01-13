import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_app/core/helpers/navigation_helper.dart';
import 'package:flutter_firebase_chat_app/core/helpers/string_helper.dart';
import 'package:flutter_firebase_chat_app/core/services/database_service.dart';
import 'package:flutter_firebase_chat_app/core/widgets/base_view.dart';
import 'package:flutter_firebase_chat_app/features/home/home_page.dart';

class GroupInfo extends StatefulWidget {
  const GroupInfo(
      {Key? key,
      required this.groupId,
      required this.groupName,
      required this.adminName})
      : super(key: key);
  final String groupId;
  final String groupName;
  final String adminName;

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? members;

  @override
  void initState() {
    getMembers();
    super.initState();
  }

  getMembers() async {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupMembers(widget.groupId)
        .then((value) {
      setState(() {
        members = value;
      });
    });
  }

  String getActualName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  String getActualId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: const Text("Group Info"),
          actions: [
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Exit"),
                          content: const Text(
                              "Are you sure you want to leave the group?"),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("No")),
                            TextButton(
                                onPressed: () async {
                                  DatabaseService(
                                          uid: FirebaseAuth
                                              .instance.currentUser!.uid)
                                      .toggleGroupJoin(
                                          widget.groupId,
                                          getActualName(widget.adminName),
                                          widget.groupName)
                                      .whenComplete(() {
                                    nextScreenReplacement(context, HomePage());
                                  });
                                },
                                child: const Text("Yes")),
                          ],
                        );
                      });
                },
                icon: const Icon(Icons.settings)),
            // IconButton(
            //     onPressed: () {
            //       showDialog(
            //           context: context,
            //           builder: (context) {
            //             return AlertDialog(
            //               title: const Text("Leave Group"),
            //               content: const Text(
            //                   "Are you sure you want to leave this group?"),
            //               actions: [
            //                 TextButton(
            //                     onPressed: () {}, child: const Text("Yes")),
            //                 TextButton(
            //                     onPressed: () {}, child: const Text("No")),
            //               ],
            //             );
            //           });
            //     },
            //     icon: const Icon(
            //       Icons.exit_to_app,
            //       color: Colors.white,
            //     ))
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(children: [
            itemContainer(
                avatarTitle: widget.groupName,
                title: "Group ${widget.groupName}",
                subtitle: "Admin: ${getActualName(widget.adminName)}"),
            memberList(),
          ]),
        ));
  }

  memberList() {
    return StreamBuilder(
        stream: members,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null && snapshot.data['members'].length != 0) {
              return ListView.separated(
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 5),
                  shrinkWrap: true,
                  itemCount: snapshot.data['members'].length,
                  itemBuilder: (context, index) {
                    return itemContainer(
                        color: Colors.white,
                        avatarTitle:
                            getActualName(snapshot.data['members'][index]),
                        title: getActualName(snapshot.data['members'][index]),
                        subtitle: getActualId(snapshot.data['members'][index]));
                  });
            } else {
              return const Center(child: Text("No members"));
            }
          } else {
            return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor));
          }
        });
  }

  Widget itemContainer({
    Color? color,
    required String avatarTitle,
    required String title,
    required String subtitle,
    Color? subtitleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: color ?? Theme.of(context).primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(avatarTitle.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(StringHelper().overFlowText(title, parseLength: 30),
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 5),
              Text(StringHelper().overFlowText(subtitle, parseLength: 20),
                  style: TextStyle(
                    color: subtitleColor ?? Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ))
            ],
          )
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_app/core/helpers/helper_function.dart';
import 'package:flutter_firebase_chat_app/core/helpers/navigation_helper.dart';
import 'package:flutter_firebase_chat_app/core/services/database_service.dart';
import 'package:flutter_firebase_chat_app/core/widgets/base_view.dart';
import 'package:flutter_firebase_chat_app/core/widgets/dialog/snackbar.dart';
import 'package:flutter_firebase_chat_app/features/chat/chat_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  bool _isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool hasUserSearched = false;
  bool isJoined = false;
  String userName = "";
  User? user;

  @override
  void initState() {
    super.initState();
    getCurrentUserIdAndName();
  }

  getCurrentUserIdAndName() async {
    await HelperFunction.getUserName().then((value) {
      setState(() {
        userName = value!;
      });
    });

    user = FirebaseAuth.instance.currentUser;
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
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text('Search',
              style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ),
        child: Column(
          children: [
            Container(
                color: Theme.of(context).primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          hintText: "Search Groups...",
                          hintStyle:
                              TextStyle(color: Colors.white, fontSize: 16),
                          border: InputBorder.none),
                    )),
                    GestureDetector(
                      onTap: () {
                        onSearch();
                      },
                      child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(40)),
                          child: const Icon(
                            Icons.search,
                            color: Colors.white,
                          )),
                    )
                  ],
                )),
            _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor))
                : groupList()
          ],
        ));
  }

  onSearch() async {
    if (searchController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      await DatabaseService()
          .searchByName(searchController.text)
          .then((snapshot) {
        setState(() {
          searchSnapshot = snapshot;
          _isLoading = false;
          hasUserSearched = true;
        });
      });
    }
  }

  groupList() {
    return hasUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchSnapshot!.docs.length,
            itemBuilder: (context, index) {
              return _groupTile(
                userName,
                searchSnapshot!.docs[index]["groupId"],
                searchSnapshot!.docs[index]["groupName"],
                searchSnapshot!.docs[index]["admin"],
              );
            })
        : Container();
  }

  joinedOrNot(
      String userName, String groupId, String groupName, String admin) async {
    await DatabaseService(uid: user!.uid)
        .isUserJoined(groupName, groupId, userName)
        .then((value) {
      setState(() {
        isJoined = value;
      });
    });
  }

  Widget _groupTile(
      String userName, String groupId, String groupName, String admin) {
    // function to check whether user already exists in group
    joinedOrNot(userName, groupId, groupName, admin);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(groupName.substring(0, 1).toUpperCase(),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ),
      title: Text(groupName,
          style: const TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600)),
      subtitle: Text(
        "Admin: ${getActualName(admin)}",
      ),
      trailing: InkWell(
          onTap: () async {
            await DatabaseService(uid: user!.uid)
                .toggleGroupJoin(groupId, userName, groupName);
            if (isJoined) {
              setState(() {
                isJoined = !isJoined;
              });
              SnackBarDialog().showSnackBar(context,
                  color: Colors.green, message: "Successfully joint the group");
              Future.delayed(const Duration(seconds: 2), () {
                nextScreen(
                    context,
                    ChatPage(
                        groupId: groupId,
                        groupName: groupName,
                        userName: userName));
              });
            } else {
              setState(() {
                isJoined = !isJoined;
              });
              SnackBarDialog()
                  .showSnackBar(context, message: "Left the group $groupName");
            }
          },
          child: isJoined
              ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: const Text("Joined",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)))
              : Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).primaryColor,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: const Text("Join Now",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                )),
    );
  }

  onJoin() {}
}

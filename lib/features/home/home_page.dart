import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_app/core/helpers/helper_function.dart';
import 'package:flutter_firebase_chat_app/core/helpers/navigation_helper.dart';
import 'package:flutter_firebase_chat_app/core/services/auth_service.dart';
import 'package:flutter_firebase_chat_app/core/services/database_service.dart';
import 'package:flutter_firebase_chat_app/core/widgets/base_view.dart';
import 'package:flutter_firebase_chat_app/core/widgets/custom_tile/group_tile.dart';
import 'package:flutter_firebase_chat_app/core/widgets/dialog/snackbar.dart';
import 'package:flutter_firebase_chat_app/features/auth/login_page.dart';
import 'package:flutter_firebase_chat_app/features/home/drawers/profile_page.dart';
import 'package:flutter_firebase_chat_app/features/home/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "";
  String userEmail = "";
  final AuthService _authService = AuthService();
  Stream? groups;
  bool _isLoading = false;
  TextEditingController groupNameController = TextEditingController();
  String errorMessageCreateGroup = "";

  @override
  void initState() {
    super.initState();
    gettingUserData();
  }

  gettingUserData() async {
    await HelperFunction.getUserName().then((value) {
      setState(() {
        userName = value!;
      });
    });
    await HelperFunction.getUserEmail().then((value) {
      setState(() {
        userEmail = value!;
      });
    });
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text("Groups",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 27)),
        backgroundColor: Theme.of(context).primaryColor,
        // leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(context, const SearchPage());
              },
              icon: const Icon(Icons.search))
        ],
      ),
      drawer: _drawer(),
      floatingButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          createDialog(context);
        },
        elevation: 0,
        child: const Icon(Icons.add),
      ),
      child: groupList(),
    );
  }

  groupList() {
    return StreamBuilder(
        stream: groups,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          //make some checks
          if (snapshot.hasData) {
            if (snapshot.data["groups"].length != 0 &&
                snapshot.data["groups"] != null) {
              print("Groups Data: ${snapshot.data["groups"]}");
              // return const Text('HELLO');
              return ListView.builder(
                  itemCount: snapshot.data["groups"].length,
                  itemBuilder: (BuildContext context, int index) {
                    int reverseIndex =
                        snapshot.data["groups"].length - index - 1;
                    return GroupTile(
                      userName: snapshot.data['fullName'],
                      groupId: getId(snapshot.data["groups"][reverseIndex]),
                      groupName: getName(snapshot.data["groups"][reverseIndex]),
                    );
                  });
            } else {
              return noGroupWidget();
            }
          } else {
            return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor));
          }
          return Container();
        });
  }

  Widget _drawer() {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: ListView(
          children: [
            Icon(Icons.account_circle, size: 150, color: Colors.grey[700]),
            const SizedBox(height: 15),
            Text(userName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            const Divider(height: 2),
            ListTile(
              selected: true,
              selectedColor: Theme.of(context).primaryColor,
              leading: const Icon(Icons.group),
              title: const Text("Groups"),
              onTap: () async {},
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text("Profile"),
              onTap: () {
                nextScreenReplacement(
                    context,
                    ProfilePage(
                      userName: userName,
                      userEmail: userEmail,
                    ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () async {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Logout"),
                        content: const Text("Are you sure you want to logout?"),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("No")),
                          TextButton(
                              onPressed: () async {
                                _authService.signOut();
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginPage()),
                                    (route) => false);
                              },
                              child: const Text("Yes")),
                        ],
                      );
                    });
              },
            )
          ],
        ),
      ),
    );
  }

  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.group, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
              "You've not joined any groups, taps on the add icon\nto create a group or also search from search button.",
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: () {
                createDialog(context);
              },
              child: const Text("Create Group"))
        ],
      ),
    );
  }

  void createDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text("Create Group"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor))
                      : TextField(
                          controller: groupNameController,
                          decoration: InputDecoration(
                            hintText: "Group Name",
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 1.0),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20))),
                            errorBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red, width: 1.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 1.0),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20))),
                          ),
                        ),
                  const SizedBox(height: 10),
                  Text(errorMessageCreateGroup,
                      style: const TextStyle(color: Colors.red)),
                ],
              ),
              actions: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor),
                    onPressed: () {
                      Navigator.pop(context);
                      groupNameController.clear();
                    },
                    child: const Text("Cancel")),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor),
                    onPressed: () async {
                      onCreateGroup().whenComplete(() {
                        groupNameController.clear();
                      });
                    },
                    child: const Text("Create"))
              ],
            );
          });
        });
  }

  Future onCreateGroup() async {
    if (groupNameController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .createGroup(userName, FirebaseAuth.instance.currentUser!.uid,
              groupNameController.text)
          .whenComplete(() {
        setState(() {
          _isLoading = false;
        });
      });
      Navigator.pop(context);
      SnackBarDialog().showSnackBar(context,
          message: "Group ${groupNameController.text} created successfully",
          color: Colors.green);
    } else {
      setState(() {
        errorMessageCreateGroup = "Group name is required";
      });
      SnackBarDialog().showSnackBar(context,
          message: "Group name cannot be empty", color: Colors.red);
    }
  }
}

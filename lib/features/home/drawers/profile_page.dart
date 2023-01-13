import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_app/core/helpers/helper_function.dart';
import 'package:flutter_firebase_chat_app/core/helpers/navigation_helper.dart';
import 'package:flutter_firebase_chat_app/core/services/auth_service.dart';
import 'package:flutter_firebase_chat_app/core/widgets/base_view.dart';
import 'package:flutter_firebase_chat_app/features/auth/login_page.dart';
import 'package:flutter_firebase_chat_app/features/home/home_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key, required this.userName, required this.userEmail})
      : super(key: key);
  final String userName;
  final String userEmail;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return BaseView(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          title: const Text("Profile",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.bold)),
        ),
        drawer: _drawer(),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 170),
            child: Column(
              children: [
                Icon(Icons.account_circle, size: 200, color: Colors.grey[700]),
                SizedBox(height: 15),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Full Name: ",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.bold)),
                      Text(widget.userName,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.bold))
                    ]),
                const SizedBox(height: 20),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Email: ",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.bold)),
                      Text(widget.userEmail,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.bold))
                    ]),
              ],
            )));
  }

  Widget _drawer() {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: ListView(
          children: [
            Icon(Icons.account_circle, size: 150, color: Colors.grey[700]),
            const SizedBox(height: 15),
            Text(widget.userName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            const Divider(height: 2),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text("Groups"),
              onTap: () async {
                nextScreen(context, const HomePage());
              },
            ),
            ListTile(
              selected: true,
              selectedColor: Theme.of(context).primaryColor,
              leading: const Icon(Icons.account_circle),
              title: const Text("Profile"),
              onTap: () {},
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
}

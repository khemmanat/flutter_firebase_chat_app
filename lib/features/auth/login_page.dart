import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_app/core/constants/color.dart';
import 'package:flutter_firebase_chat_app/core/extensions/validator_extension.dart';
import 'package:flutter_firebase_chat_app/core/helpers/helper_function.dart';
import 'package:flutter_firebase_chat_app/core/helpers/navigation_helper.dart';
import 'package:flutter_firebase_chat_app/core/services/auth_service.dart';
import 'package:flutter_firebase_chat_app/core/services/database_service.dart';
import 'package:flutter_firebase_chat_app/core/widgets/base_view.dart';
import 'package:flutter_firebase_chat_app/core/widgets/decoration/input_decoration.dart';
import 'package:flutter_firebase_chat_app/features/auth/register_page.dart';
import 'package:flutter_firebase_chat_app/features/home/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final loginFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return BaseView(
        hasAppBar: false,
        // appBar: AppBar(
        //   backgroundColor: Theme.of(context).primaryColor,
        // ),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor))
            : SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
                  child: Form(
                      key: loginFormKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Groupie",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 40)),
                          const SizedBox(height: 10),
                          const Text(
                              "Login now to see what they are talking about",
                              style: TextStyle(fontSize: 15)),
                          const SizedBox(height: 10),
                          Image.asset("assets/images/login.png"),
                          // const SizedBox(height: 10),
                          TextFormField(
                            controller: _emailController,
                            // prefix: const Icon(Icons.email),
                            decoration: textInputDecoration.copyWith(
                              labelText: "Email",
                              hintText: "Email...",
                              prefixIcon: Icon(
                                Icons.email,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Email is required!";
                              } else if (!value.isEmail()) {
                                return "Email is not valid!";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: textInputDecoration.copyWith(
                              labelText: "Password",
                              hintText: "Password...",
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Password is required!";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30))),
                              child: const Text("Sign In"),
                              onPressed: () {
                                login();
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          RichText(
                              text: TextSpan(
                                  style: const TextStyle(
                                      fontSize: 15,
                                      color: ThemeColor.primaryBlackColor),
                                  children: [
                                const TextSpan(text: "Don't have an account? "),
                                TextSpan(
                                    text: "Register Here",
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        nextScreen(
                                            context, const RegisterPage());
                                        print("Register Here");
                                      },
                                    style: const TextStyle(
                                        color: ThemeColor.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline))
                              ])),
                        ],
                      )),
                ),
              ));
  }

  login() async {
    if (loginFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService
          .signInWithEmailAndPassword(
              _emailController.text, _passwordController.text)
          .then((value) async {
        if (value == true) {
          QuerySnapshot snapshot =
              await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                  .gettingUserData(_emailController.text);
          //saving user data to shared preferences
          await HelperFunction.saveUserLoggedInStatus(true);
          await HelperFunction.saveUserEmail(_emailController.text);
          await HelperFunction.saveUserName(snapshot.docs[0]['fullName']);
          nextScreenReplacement(context, const HomePage());
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
}

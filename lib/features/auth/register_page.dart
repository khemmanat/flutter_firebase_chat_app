import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_app/core/constants/color.dart';
import 'package:flutter_firebase_chat_app/core/extensions/validator_extension.dart';
import 'package:flutter_firebase_chat_app/core/helpers/helper_function.dart';
import 'package:flutter_firebase_chat_app/core/helpers/navigation_helper.dart';
import 'package:flutter_firebase_chat_app/core/services/auth_service.dart';
import 'package:flutter_firebase_chat_app/core/widgets/base_view.dart';
import 'package:flutter_firebase_chat_app/core/widgets/decoration/input_decoration.dart';
import 'package:flutter_firebase_chat_app/core/widgets/dialog/snackbar.dart';
import 'package:flutter_firebase_chat_app/features/auth/login_page.dart';
import 'package:flutter_firebase_chat_app/features/home/home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;
  final registerFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return BaseView(
        hasAppBar: false,
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor))
            : SingleChildScrollView(
                child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Form(
                    key: registerFormKey,
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
                        Image.asset("assets/images/register.png"),
                        // const SizedBox(height: 10),
                        TextFormField(
                          controller: _fullNameController,
                          // prefix: const Icon(Icons.email),
                          decoration: textInputDecoration.copyWith(
                            labelText: "Full Name",
                            hintText: "Full Name...",
                            prefixIcon: Icon(
                              Icons.person,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Full Name is required!";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
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
                          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                                backgroundColor: Theme.of(context).primaryColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                            child: const Text("Register"),
                            onPressed: () {
                              register();
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
                              const TextSpan(text: "Already have an account? "),
                              TextSpan(
                                  text: "Sign In Here",
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      nextScreenReplacement(
                                          context, const LoginPage());
                                      print("Login Here");
                                    },
                                  style: const TextStyle(
                                      color: ThemeColor.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline))
                            ])),
                      ],
                    )),
              )));
  }

  register() async {
    if (registerFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService
          .registerWithEmailAndPassword(_fullNameController.text,
              _emailController.text, _passwordController.text)
          .then((value) async {
        if (value == true) {
          setState(() {
            _isLoading = false;
          });
          //saving the shared preference state
          await HelperFunction.saveUserLoggedInStatus(true);
          await HelperFunction.saveUserName(_fullNameController.text);
          await HelperFunction.saveUserEmail(_emailController.text);

          //dialog show registered successfully
          SnackBarDialog().showSnackBar(context,
              message: "Registered Successfully", color: Colors.green);

          //clear the text field
          _emailController.clear();
          _passwordController.clear();
          _fullNameController.clear();
          //navigate to home page
          nextScreenReplacement(context, const HomePage());
        } else {
          SnackBarDialog()
              .showSnackBar(context, message: value, color: Colors.red);
          print("Error : $value");
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
}

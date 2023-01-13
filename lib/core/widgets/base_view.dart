import 'package:flutter/material.dart';

class BaseView extends StatelessWidget {
  const BaseView({
    Key? key,
    required this.child,
    this.appBar,
    this.hasAppBar = true,
    this.drawer,
    this.floatingButton,
  }) : super(key: key);

  final Widget child;
  final PreferredSizeWidget? appBar;
  final bool hasAppBar;
  final Widget? drawer;
  final Widget? floatingButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: hasAppBar
          ? appBar ?? AppBar(title: const Text("Flutter Chat App"))
          : null,
      drawer: drawer,
      floatingActionButton: floatingButton,
      body: SafeArea(
          child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: child,
      )),
    );
  }
}

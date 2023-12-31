import 'package:flutter/material.dart';
import 'package:tiyatrokulubu/screens/signin/sign_in.dart';

class HomePageSign extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageSign();
}

class _HomePageSign extends State {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.grey.shade100,
              Colors.grey,
              Colors.grey.shade100,
            ],
          ),
        ),
        child: SignIn(),
      ),
    );
  }
}

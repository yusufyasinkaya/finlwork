import 'package:flutter/cupertino.dart';

class CustomBackgroundImage extends Positioned {
  CustomBackgroundImage({super.key})
      : super.fill(
          child: Image.asset(
            "fotolar/foto.jpeg",
            fit: BoxFit.fill,
          ),
        );
}

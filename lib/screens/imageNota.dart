import 'package:flutter/material.dart';



class ImageNota extends StatelessWidget {
  String url;


  ImageNota(this.url);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.network(url),
    );
  }
}

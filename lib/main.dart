import 'package:compra_rapida_2/screens/home.dart';
import 'package:compra_rapida_2/screens/login.dart';
import 'package:compra_rapida_2/screens/newList.dart';
import 'package:flutter/material.dart';

import 'models/user.dart';

void main() {
  runApp(
    MaterialApp(

      home: Login(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

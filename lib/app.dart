import 'package:flutter/material.dart';

import 'package:virtual_store_manager/screens/login/login_screen.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Virtual Store Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.pinkAccent
      ),
      home: LoginScreen(),
    );
  }
}

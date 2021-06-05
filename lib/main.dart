import 'dart:convert';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/authentication/login.dart';
import 'package:flutter_chat_app/profile.dart';
import 'package:flutter_chat_app/widgets/already_have_an_account_acheck.dart';
import 'package:flutter_chat_app/widgets/rounded_button.dart';
import 'package:flutter_chat_app/widgets/rounded_input_field.dart';
import 'package:flutter_chat_app/widgets/rounded_password_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'authentication/signup.dart';
import 'chat/all.dart';
import 'chat/chat.dart';
import 'group/allgroup.dart';
// import 'package:socket_io_client/socket_io_client.dart';
// import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String val = _prefs.getString("token") ?? "empty";
  String id = _prefs.getString("id") ?? "empty";
  runApp(MyApp1(token: val, id: id));
}

class MyApp1 extends StatelessWidget {
  final token;
  final id;

  const MyApp1({Key key, this.token, this.id}) : super(key: key);
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: token == "empty"
          ? LoginScreen()
          : Home(
              token: token,
              id: int.parse(id),
            ),
    );
  }
}

class Home extends StatefulWidget {
  final id;
  final token;

  const Home({Key key, this.id, this.token}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  PageController _pageController;

  @override
  void initState() {
    print(widget.token);
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: <Widget>[
            All(
              id: widget.id,
              token: widget.token,
            ),
            AllGroup(
              id: widget.id,
              token: widget.token,
            ),
            Profile(
              // id: widget.id,
              token: widget.token,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
          _pageController.jumpToPage(index);
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
              title: Text('Chat'), icon: Icon(Icons.chat_bubble_outline)),
          BottomNavyBarItem(
              title: Text('Group Chat'), icon: Icon(Icons.group_outlined)),
          BottomNavyBarItem(
              title: Text('Profile'), icon: Icon(Icons.person_outline)),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/chat/all.dart';
import 'package:flutter_chat_app/widgets/already_have_an_account_acheck.dart';
import 'package:flutter_chat_app/widgets/rounded_button.dart';
import 'package:flutter_chat_app/widgets/rounded_input_field.dart';
import 'package:flutter_chat_app/widgets/rounded_password_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String username = '';
  String password = '';
  String id;
  String token;

  signup() async {
    String url = 'http://<YOUR_PC_IP_ADDRESS>:8000';
    var body = jsonEncode({'username': username, 'password': password});
    final response = await http.post(
      "$url/api/signup/",
      body: body,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 201) {
      final response = await http.post(
        "$url/api/login/",
        body: body,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        print(responseJson["token"]);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', responseJson["token"].toString());
        prefs.setString('id', responseJson["id"].toString());
        id = responseJson["id"].toString();
        token = responseJson["token"].toString();
        return "Navigate";
      }
    } else {
      return 'User Already Exist';
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "SIGNUP",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: size.height * 0.03),
            RoundedInputField(
              hintText: "Username",
              onChanged: (value) {
                username = value;
              },
            ),
            RoundedPasswordField(
              onChanged: (value) {
                password = value;
              },
            ),
            RoundedButton(
              text: "SIGNUP",
              press: () async {
                final s = await signup();
                if (s == "Navigate") {
                  Navigator.pushReplacement(context,
                      CupertinoPageRoute(builder: (_) {
                    return All(id: id, token: token);
                  }));
                } else {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text("Username already taken"),
                  ));
                }
              },
            ),
            SizedBox(height: size.height * 0.03),
            AlreadyHaveAnAccountCheck(
              login: false,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return LoginScreen();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

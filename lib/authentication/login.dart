import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_chat_app/widgets/rounded_password_field.dart';
import 'package:flutter_chat_app/authentication/signup.dart';
import 'package:flutter_chat_app/chat/all.dart';
import 'package:flutter_chat_app/chat/chat.dart';
import 'package:flutter_chat_app/widgets/already_have_an_account_acheck.dart';
import 'package:flutter_chat_app/widgets/rounded_button.dart';
import 'package:flutter_chat_app/widgets/rounded_input_field.dart';
import 'package:flutter_chat_app/widgets/rounded_password_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController idcontroller = TextEditingController();
  TextEditingController controller = TextEditingController();
  String id;
  String token;
  String username = '';
  String password = '';

  String curr;
  WebSocketChannel channel;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  login() async {
  String url = 'http://<YOUR_PC_IP_ADDRESS>:8000';
    var body = jsonEncode({'username': username, 'password': password});
    final response = await http.post(
      "$url/api/login/",
      body: body,
      headers: {
        'Content-Type': 'application/json',
        "Access-Control-Allow-Origin": "*"
      },
    );
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      print(responseJson["token"]);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', responseJson["token"].toString());
      prefs.setString('id', responseJson["id"].toString());
      id = responseJson["id"].toString();
      token = responseJson["token"].toString();
      return "login";
    } else {
      return "error";
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "LOGIN",
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
                text: "LOGIN",
                press: () async {
                  final s = await login();
                  if (s == "login") {

                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) {
                      return All(id: id, token: token);
                    }));
                  } else {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text("Wrong Credentials"),
                    ));
                  }
                },
              ),
              SizedBox(height: size.height * 0.03),
              AlreadyHaveAnAccountCheck(
                press: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return SignUpScreen();
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 



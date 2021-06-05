import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_chat_app/authentication/login.dart';
import 'package:flutter_chat_app/model/AllModel.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat.dart';

class All extends StatefulWidget {
  final token;
  final id;

  const All({Key key, this.token, this.id}) : super(key: key);
  @override
  _AllState createState() => _AllState();
}

class _AllState extends State<All> {
  Stream<List<All>> all;
  String url = 'http://<YOUR_PC_IP_ADDRESS>:8000';
  final ImagePicker _picker = ImagePicker();
  SharedPreferences prefs;
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async* {
    List<AllModel> todo = [];
    final response = await http.get(
      '$url/api/all/',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${widget.token}'
      },
    );
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      data.forEach((element) {
        todo.add(AllModel.fromjson(element));
      });
    }
    yield todo;
  }

  uploadFile(String path) async {
    Dio dio = new Dio();
    dio.options.headers["Authorization"] = "Token ${widget.token}";
    FormData formData = new FormData.fromMap({
      'avatar': await MultipartFile.fromFile(path, filename: 'upload2.jpg'),
    });
    try {
      await dio.put("$url/api/update/", data: formData);
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            "Chats",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                SharedPreferences pref = await SharedPreferences.getInstance();
                pref.clear();
                Navigator.pushReplacement(context,
                    CupertinoPageRoute(builder: (_) {
                  return LoginScreen();
                }));
              },
            ),
          ]),
      body: Container(
        child: StreamBuilder(
          stream: getData(),
          // initialData: initialData ,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData && snapshot.data.length != 0) {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return snapshot.data[index].id !=
                          int.parse(widget.id.toString())
                      ? ListTile(
                          onTap: () {
                            Navigator.push(context,
                                CupertinoPageRoute(builder: (_) {
                              return ChatRoom(
                                me: widget.id,
                                image: NetworkImage(
                                    "$url/media/${snapshot.data[index].avatar}"),
                                username: snapshot.data[index].username,
                                token: widget.token,
                                notme: snapshot.data[index].id,
                              );
                            }));
                          },
                          leading: snapshot.data[index].avatar != ""
                              ? Hero(
                                  tag: snapshot.data[index].id,
                                  child: CircleAvatar(
                                      radius: 20,
                                      backgroundImage: NetworkImage(
                                          "$url/media/${snapshot.data[index].avatar}")),
                                )
                              : Text(""),
                          title: Text(snapshot.data[index].username),
                        )
                      : SizedBox();
                },
              );
            }
            return Center(child: CircularProgressIndicator()
                // child: child,
                );
          },
        ),
      ),
    );
  }
}

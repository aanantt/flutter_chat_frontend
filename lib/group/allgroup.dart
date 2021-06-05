import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_chat_app/model/GroupModel.dart';

import 'groupchat.dart';
import 'join_or_create.dart';

class AllGroup extends StatefulWidget {
  final token;
  final id;

  const AllGroup({Key key, this.token, this.id}) : super(key: key);
  @override
  _AllGroupState createState() => _AllGroupState();
}

class _AllGroupState extends State<AllGroup> {
  String url = 'http://<YOUR_PC_IP_ADDRESS>:8000';
  final ImagePicker _picker = ImagePicker();
  bool show = false;
  AnimationController controller;
  Animation animation;
  @override
  void initState() {
    super.initState();
    getData();
  }

 

  getData() async* {
    List<GroupModel> todo = [];
    final response = await http.get(
      '$url/api/all/groups/',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${widget.token}'
      },
    );
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      data.forEach((element) {
        todo.add(GroupModel.fromjson(element));
      });
    }
    print(todo);
    yield todo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: show,
            child: FloatingActionButton.extended(
                heroTag: null,
                onPressed: () {
                  Navigator.push(context, CupertinoPageRoute(builder: (_) {
                    return JoinCreate(
                      join: true,
                      id: widget.id,
                      token: widget.token,
                    );
                  })).whenComplete(() {
                    setState(() {
                      getData();
                    });
                  });
                },
                icon: Icon(Icons.group),
                label: Text("Join a Group")),
          ),
          SizedBox(height: 10),
          Visibility(
            visible: show,
            child: FloatingActionButton.extended(
                heroTag: null,
                onPressed: () {
                  Navigator.push(context, CupertinoPageRoute(builder: (_) {
                    return JoinCreate(
                      join: false,
                      id: widget.id,
                      token: widget.token,
                    );
                  })).whenComplete(() {
                    setState(() {
                      getData();
                    });
                  });
                },
                icon: Icon(Icons.group_add),
                label: Text("Create a Group")),
          ),
          SizedBox(height: 10),
          FloatingActionButton.extended(
              heroTag: null,
              onPressed: () {
                setState(() {
                  show = !show;
                });
              },
              icon: Icon(Icons.add),
              label: Text("Add")),
        ],
      ),
      appBar: AppBar(title: Text("Groups", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25))),
      body: Container(
        child: StreamBuilder(
          stream: getData(),
          // initialData: initialData ,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData && snapshot.data.length != 0) {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage("$url${snapshot.data[index].image}")
                    ),
                    onTap: () {
                      Navigator.push(context, CupertinoPageRoute(builder: (_) {
                        return GroupChat(
                          me: widget.id,
                          token: widget.token,
                          image:
                              NetworkImage("$url${snapshot.data[index].image}"),
                          username: snapshot.data[index].name,
                          groupid: snapshot.data[index].id,
                        );
                      })).whenComplete(() {
                        setState(() {
                          getData();
                        });
                      });
                    },
                    title: Text(snapshot.data[index].name),
                    subtitle: Text(snapshot.data[index].description.toString()),
                  );
                },
              );
            }
            return Center(
                // child: child,
                );
          },
        ),
      ),
    );
  }
}

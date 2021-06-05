import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'groupchat.dart';

class JoinCreate extends StatefulWidget {
  final bool join;
  final token;
  final id;

  const JoinCreate({Key key, this.join = false, this.token, this.id})
      : super(key: key);
  @override
  _JoinCreateState createState() => _JoinCreateState();
}

class _JoinCreateState extends State<JoinCreate> {
  bool search = false;
  String url = 'http://<YOUR_PC_IP_ADDRESS>:8000';
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController controller = TextEditingController(text: "");
  TextEditingController description = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
  }

  joinGroup() async {
    final response = await http.put(
      '$url/api/join/group/${controller.text}/',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${widget.token}'
      },
    );
    setState(() {
      search = !search;
    });

    if (response.statusCode == 200) {
      // final data = json.decode(response.body);
      Navigator.of(context).pop();
    } else {
      final z = controller.text;
      controller.clear();
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("$z Group Doesn't Exist :("),
      ));
      print(response.body);
    }
  }

  createGroup() async {
    final response = await http.post('$url/api/all/groups/',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token ${widget.token}'
        },
        body: json.encode(
            {"name": controller.text, "description": description.text}));
    setState(() {
      search = !search;
    });

    if (response.statusCode == 200) {
      Navigator.of(context).pop();
    } else {
      final z = controller.text;
      // controller.clear();
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("$z Group Doesn't Exist :("),
      ));
      print(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: widget.join ? Text("Join Group") : Text("Create Group"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextFormField(
                controller: controller,
                decoration: InputDecoration(labelText: "Group Name")),
          ),
          widget.join == false
              ? Padding(
                  padding: const EdgeInsets.all(15),
                  child: TextFormField(
                      controller: description,
                      decoration: InputDecoration(labelText: "Description")),
                )
              : SizedBox(),
          search
              ? Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: ElevatedButton(
                    child: widget.join ? Text("Join") : Text("Create"),
                    onPressed: () async {
                      setState(() {
                        search = !search;
                      });
                      widget.join ? await joinGroup() : await createGroup();
                    },
                  ),
                )
        ],
      ),
    );
  }
}

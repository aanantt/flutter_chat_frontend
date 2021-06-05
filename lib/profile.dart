import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  final token;

  const Profile({Key key, this.token}) : super(key: key);
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String username;
  var data;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  File image;
  bool changepic = false;
  String url = 'http://<YOUR_PC_IP_ADDRESS>:8000';
  @override
  void initState() {
    super.initState();
  }

  getData() async* {
    final response = await http.get(
      '$url/api/user/',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${widget.token}'
      },
    );
    if (response.statusCode == 200) {
      data = json.decode(response.body);
      yield data;
    }
  }

  update(path) async {
    Dio dio = new Dio();
    FormData formData;
    print(username);
    // if(username == null)
    setState(() {
      username = username ??= data['username'];
    });

    print(username);
    // dio.options.headers['content-Type'] = 'multipart/form-data';
    dio.options.headers["Authorization"] = "Token ${widget.token}";
    if (changepic) {
      final pat = path.path;
      print(pat);
      formData = FormData.fromMap({
        'username': username,
        'avatar': await MultipartFile.fromFile(pat, filename: 'upload2.jpg'),
      });
    } else {
      formData = FormData.fromMap({
        'username': username,
      });
    }

    try {
      await dio.put("$url/api/user/", data: formData);
      setState(() {
        issaving = !issaving;
        changepic = !changepic;
      });
      getData();
    } catch (error) {
      print(error);
    }

    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Updated!!!"),
    ));
  }

  Stream setImage() async* {
    if (mounted) image = image;

    yield image;
  }

  Future<File> profileImg;
  bool issaving = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text("Your Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
          actions: [
            !issaving
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        issaving = !issaving;
                      });
                      print(image);
                      update(image);
                    },
                    icon: Icon(Icons.check, color: Colors.white))
                : SizedBox(
                    height: 4,
                    child: Center(
                        child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.white),
                    )),
                  ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: StreamBuilder(
            stream: getData(),
            // initialData: initialData ,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () async {
                        final img = await ImagePicker.pickImage(
                            source: ImageSource.gallery);
                        setState(() {
                          changepic = !changepic;
                          image = img;
                        });
                      },
                      child: StreamBuilder(
                        builder: (context, data) {
                          if (data.hasData) {
                            return CircleAvatar(
                              backgroundColor: Colors.transparent,
                              backgroundImage: FileImage(data.data),
                              radius: 120,
                            );
                          }
                          return CircleAvatar(
                            backgroundColor: Colors.transparent,
                            backgroundImage: NetworkImage(
                                "$url/media/${snapshot.data["avatar"]}"),
                            radius: 120,
                          );
                        },
                        stream: setImage(),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: TextFormField(
                        initialValue: snapshot.data["username"],
                        onChanged: (c) {
                          setState(() {
                            username = c;
                          });
                        },
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 7,
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35)),
                            hintText: "Username"),
                      ),
                    )
                  ],
                );
              }
              return Container();
            },
          ),
        ));
  }
}

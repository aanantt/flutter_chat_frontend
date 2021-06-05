// import '../app_theme.dart';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
// import 'package:file_picker/file_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_5.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:flutter_chat_app/model/GroupChatModel.dart';
import 'package:flutter_chat_app/model/chatModel.dart';
// import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/html.dart';
// import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class GroupChat extends StatefulWidget {
  final me;
  final username;
  final image;
  final groupid;
  final token;

  const GroupChat(
      {Key key, this.me, this.groupid, this.token, this.username, this.image})
      : super(key: key);

  @override
  _GroupChatState createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  WebSocketChannel channel;
  final ImagePicker _picker = ImagePicker();
  WebSocketChannel channel2;
  Stream<List<Message>> message;
  WebSocketChannel channel1;
  String url = 'http://<YOUR_PC_IP_ADDRESS>:8000';
  String ws = 'ws://<YOUR_PC_IP_ADDRESS>:8000';
  List<GroupMessage> todo = [];
  List<GroupMessage> todo1 = [];
  List data = [
    {"message": "first", "usename": "username"}
  ];
  // FilePickerResult result;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    print(widget.image);
    print(widget.groupid);
    super.initState();
    getData();
    channel2 = IOWebSocketChannel.connect(
        '$ws/ws/delete/${widget.me}/${widget.groupid}/');
    channel = IOWebSocketChannel.connect(
        '$ws/ws/group/${widget.me}/${widget.groupid}/');
    channel1 = IOWebSocketChannel.connect(
        '$ws/ws/group/status/${widget.me}/${widget.groupid}/');
    var data1 = json.encode({"status": "online"});
    channel2.stream.listen((event) {
      setState(() {});
    });
    channel1.sink.add(data1);
    channel.stream.listen((event) {
      todo.insert(0, GroupMessage.fromjson(json.decode(event)));
      log("run init");
      setState(() {});
    });
    print(data);
  }

  leavegroup() async {
    final response = await http.put(
      '$url/api/leave/group/${widget.groupid}/',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${widget.token}'
      },
    );
    if (response.statusCode == 200) {
      Navigator.pop(context);
    }
  }

  getData() async* {
    final response = await http.get(
      '$url/api/group/chat/${widget.groupid}/',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${widget.token}'
      },
    );
    log(response.statusCode.toString());
    if (response.statusCode == 200) {
      todo = [];
      List data = json.decode(response.body);
      data.forEach((element) {
        todo.add(GroupMessage.fromjson(element));
      });
    }
    yield todo;
  }

  @override
  void dispose() {
    channel1.sink.close();
    channel2.sink.close();
    channel.sink.close();
    super.dispose();
  }

  delete(id) async {
    final response = await http.delete(
      '$url/all/chats/message/$id/',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${widget.token}'
      },
    );
    if (response.statusCode == 200) {
      //channels can also be directly use to delete messages
      //just send message id with group id and in backend delete
      // the message with sync_to_async
      channel2.sink.add(json.encode({"status": "deleted"}));
    }
  }

  //TRUE -> SHOW
  bool getusername(message, int index) {
    if (index < message.length - 1) {
      if (message[index + 1].senderid == message[index].senderid) {
        return false;
      }
      return true;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leadingWidth: 80,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              leavegroup();
            },
          ),
        ],
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 10,
            ),
            GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back_ios)),
            Hero(
              tag: widget.groupid,
              child: CircleAvatar(
                radius: 20,
                backgroundImage: widget.image,
              ),
            )
          ],
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.username),
            StreamBuilder(
              stream: channel1.stream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData && snapshot.data.length != 0) {
                  return json.decode(snapshot.data)["sender"].toString() !=
                          widget.me.toString()
                      ? Text(
                          json.decode(snapshot.data)["username"].toString() +
                              " is typing...",
                          style: TextStyle(
                            fontSize: 12,
                          ))
                      : Text("",
                          style: TextStyle(
                            fontSize: 12,
                          ));
                }
                return Container(
                  child: Text("",
                      style: TextStyle(
                        fontSize: 12,
                      )),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: getData(),
              builder: (BuildContext context, AsyncSnapshot data) {
                if (data.hasData) {
                  return data.data.length != 0 ? Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    child: ListView.builder(
                      shrinkWrap: true,
                      reverse: true,
                      itemCount: data.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        // log(data.data.length.toString());
                        return int.parse(
                                    data.data[index].senderid.toString()) ==
                                int.parse(widget.me.toString())
                            ? data.data[index].isfile
                                ? Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      margin: EdgeInsets.only(top: 10),
                                      constraints: BoxConstraints(
                                        maxHeight:
                                            MediaQuery.of(context).size.height *
                                                0.4,
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.84,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(
                                                "$url${data.data[index].file}")),
                                      ),
                                    ))
                                : GestureDetector(
                                    onTap: () {
                                      delete(data.data[index].id);
                                    },
                                    child: ChatBubble(
                                      clipper: ChatBubbleClipper5(
                                          type: BubbleType.sendBubble),
                                      alignment: Alignment.topRight,
                                      margin: EdgeInsets.only(top: 10),
                                      backGroundColor: Colors.blue,
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                        ),
                                        child: Text(
                                          utf8.decode(data.data[index].message
                                              .toString()
                                              .runes
                                              .toList()),
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  )
                            : data.data[index].isfile
                                ? Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      margin: EdgeInsets.only(top: 10),
                                      constraints: BoxConstraints(
                                        maxHeight:
                                            MediaQuery.of(context).size.height *
                                                0.4,
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.84,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(
                                                "$url${data.data[index].file}")),
                                      ),
                                    ))
                                : ChatBubble(
                                    clipper: ChatBubbleClipper5(
                                        type: BubbleType.receiverBubble),
                                    alignment: Alignment.topLeft,
                                    margin: EdgeInsets.only(top: 7),
                                    backGroundColor: Colors.lightBlue[100],
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          getusername(data.data, index)
                                              ? Text(
                                                  data.data[index].username
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))
                                              : SizedBox(),
                                          Text(
                                            utf8.decode(data.data[index].message
                                                .toString()
                                                .runes
                                                .toList()),
                                            style:
                                                TextStyle(color: Colors.black),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                      },
                    ),
                  ):Container();
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                GestureDetector(
                    child: Icon(Icons.image_outlined),
                    onTap: () async {
                      File file;
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'png', 'jpeg'],
                      );
                      if (result != null) {
                        file = File(result.files.single.path);
                      } else {}
                      final pay = json.encode({
                        "isfile": true,
                        "name": 'image',
                        "message": file.readAsBytesSync()
                      });
                      print(result.files.single.name);
                      channel.sink.add(pay);
                    }),
                SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 60,
                  child: TextFormField(
                    maxLines: null,
                    controller: controller,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 7,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(35)),
                        suffixIcon: GestureDetector(
                            onTap: () {
                              var data = json.encode({
                                "isfile": false,
                                "name": "text",
                                "message": controller.text
                              });
                              channel.sink.add(data);
                              controller.clear();
                            },
                            child: Icon(Icons.send)),
                        hintText: "Write a Message..."),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

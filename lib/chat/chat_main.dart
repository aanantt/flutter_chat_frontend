import 'package:flutter/material.dart';

class ChatMain extends StatefulWidget {
  final id;
  final token;

  const ChatMain({Key key, this.id, this.token}) : super(key: key);
  @override
  _ChatMainState createState() => _ChatMainState();
}

class _ChatMainState extends State<ChatMain> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Container(
          child: StreamBuilder(
            // stream: stream ,
            // initialData: initialData ,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData && snapshot.data.length != 0) {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile();
                  },
                );
              }
              return Container();
            },
          ),
        ));
  }
}

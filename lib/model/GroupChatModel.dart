class GroupMessage {
  final int id;
  final int senderid;
  final String message;
  final String username;
  final bool isfile;
  final String file;
  GroupMessage({this.senderid, this.username, this.id, this.message, this.isfile, this.file});
  factory GroupMessage.fromjson(Map<dynamic, dynamic> json) {
    return GroupMessage(
      id: json["id"],
      message: json["message"],
      username: json["sender"]["username"],
      senderid: json["sender"]["id"],
      file: json["file"],
      isfile: json["isfile"],
    );
  }
}

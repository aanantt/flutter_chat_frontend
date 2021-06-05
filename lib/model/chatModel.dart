class Message {
  final int id;
  final String message;
  final int messageUsername;
  final bool isfile;
  final String file;
  Message(
      {this.messageUsername, this.id, this.message, this.isfile, this.file});
  factory Message.fromjson(Map<dynamic, dynamic> json) {
    return Message(
      id: json["id"],
      message: json["message"],
      messageUsername: json["messageUsername"],
      file: json["file"],
      isfile: json["isfile"],
    );
  }
}

class AllModel {
  final int id;
  final String username;
  final String avatar;
  AllModel({this.id, this.username, this.avatar});
  factory AllModel.fromjson(Map<dynamic, dynamic> json) {
    return AllModel(
      id: json["id"],
      username: json["username"],
      avatar: json["avatar"],
    );
  }
}

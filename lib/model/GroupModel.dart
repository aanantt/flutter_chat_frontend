class GroupModel {
  final int id;
  final String name;
  final String image;
  final String description;
  GroupModel({this.id, this.name, this.description, this.image});
  factory GroupModel.fromjson(Map<dynamic, dynamic> json) {
    return GroupModel(
      id: json["id"],
      name: json["name"],
      description: json["description"],
      image: json["image"],
    );
  }
}


class News {
  String? id;
  String? title;
  String? image;
  String? description;
  String? publishedDate;
  String? url;

  News(
      {this.id,
        this.title,
        this.image,
        this.description,
        this.publishedDate,
        this.url});

  News.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    image = json['image'];
    description = json['description'];
    publishedDate = json['published_date'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['image'] = image;
    data['description'] = description;
    data['published_date'] = publishedDate;
    data['url'] = url;
    return data;
  }
}

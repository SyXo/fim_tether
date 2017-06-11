import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';

class User {
  int id;
  String name;

  User({this.id, this.name});

  Map<String, dynamic> toJson() {
    Map data = new Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    return data;
  }

  void fromJson(Map data) {
    id = data['id'];
    name = data['name'];
  }
}

class Chapter {
  int id;
  String title;
  Map<String, int> stats;
  DateTime modified;

  Map<String, dynamic> toJson () {
    Map data = new Map<String, dynamic>();
    data['id'] = id;
    data['title'] = title;
    data['stats'] = stats;
    data['modified'] = modified.toIso8601String();
    return data;
  }
  void fromJson(Map data) {
    id = data['id'];
    title = data['title'];
    stats = data['stats'];
    modified = DateTime.parse(data['modified']);
  }
}

var storyLoader = createHttpClient();

class Story extends Object {
  int id = 0;
  String title = '';
  String summary = '';
  String description = '';
  String imageURL = '';
  String fullImageURL = '';
  Set<String> categories = new Set();
  Set<String> characters = new Set();
  Map<String, int> stats = new Map();
  int status = 0;
  int contentRating = 0;
  User author = new User(id: 0, name: '');
  DateTime published = null;
  DateTime modified = null;
  List<Chapter> chapters = [];
  int likes = 0;
  int dislikes = 0;

  Story({this.id});

  // TODO: do this in a less awful way
  Map<String, dynamic> toJson() {
    Map data = new Map<String, dynamic>();
    data['id'] = id;
    data['title'] = title;
    data['summary'] = summary;
    data['description'] = description;
    data['imageURL'] = imageURL;
    data['fullImageURL'] = fullImageURL;
    data['categories'] = categories;
    data['characters'] = characters;
    data['stats'] = stats;
    data['status'] = status;
    data['contentRating'] = contentRating;
    data['author'] = author;
    if (published != null) data['published'] = published.toIso8601String();
    if (modified != null) data['modified'] = modified.toIso8601String();
    data['chapters'] = chapters;
    data['likes'] = likes;
    data['dislikes'] = dislikes;
    return data;
  }

  void fromJson(Map data) {
    id = data['id'];
    title = data['title'];
    summary = data['summary'];
    description = data['description'];
    imageURL = data['imageURL'];
    fullImageURL = data['fullImageURL'];
    categories = data['categories'];
    characters = data['characters'];
    stats = data['stats'];
    status = data['status'];
    contentRating = data['contentRating'];
    author = new User()..fromJson(data['author']);
    if (data['published']) published = DateTime.parse(data['published']);
    if (data['modified']) modified = DateTime.parse(data['modified']);
    chapters = data['chapters'].map((chapter) {
      return new Chapter()..fromJson(chapter);
    });
    likes = data['likes'];
    dislikes = data['dislikes'];
  }

  Future<File> _getStorageFile() async {
    String directory = (await getApplicationDocumentsDirectory()).path;
    return new File('$directory/story/$id');
  }

  Future<Null> loadFromStorage() async {
    try {
      File file = await _getStorageFile();
      String contents = await file.readAsString();
      fromJson(JSON.decode(contents));
    } on FileSystemException {
      // TODO: possibly handle error
    }
  }

  Future<Null> saveToStorage() async {
    try {
      File file = await _getStorageFile();
      file.writeAsString(JSON.encode(this.toJson()));
    } on FileSystemException {
      // TODO: possibly handle error
    }
  }

  Future<Null> loadFromNetwork() async {
    var res = await storyLoader.get('https://fimfiction.net/api/story'
        '.php?story=$id');
    if (res.statusCode != 200) {
      // TODO: something
    } else {
      Map data = JSON.decode(res.body);
      if (data.containsKey('error')) {
        // TODO: something
      } else {
        Map story = data['story'];
        title = story['title'];
        summary = story['short_description'];
        description = story['description'];
        author.id = story['author']['id'];
        author.name = story['author']['name'];
        modified = new DateTime.fromMillisecondsSinceEpoch(
            story['date_modified'] * 1000,
            isUtc: true);
        imageURL = story['image'];
        fullImageURL = story['full_image'];
        stats['words'] = story['words'];
        stats['views'] = story['views'];
        stats['comments'] = story['comments'];
        likes = story['likes'];
        dislikes = story['dislikes'];
      }
    }
  }

  Future<Null> load () {
    Future storage = loadFromStorage();
    Future network = loadFromNetwork();
    return Future.any([storage, network]);
  }
}

import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'json_coder.dart';
import 'event_emitter.dart';

class User extends Object with JSONCoding {
  int id;
  String name;

  User({this.id, this.name});

  void encode(JSONCoder coder) {
    coder.encode(id, forKey: 'id');
    coder.encode(name, forKey: 'name');
  }

  void decode(JSONCoder coder) {
    id = coder.decodeNum(forKey: 'id');
    name = coder.decodeString(forKey: 'name');
  }
}

class Chapter extends Object with JSONCoding {
  int id;
  String title;
  Map<String, int> stats = new Map();
  DateTime modified;

  void encode(JSONCoder coder) {
    coder.encode(id, forKey: 'id');
    coder.encode(title, forKey: 'title');
    coder.encode(stats, forKey: 'stats');
    coder.encode(modified, forKey: 'modified');
  }

  void decode(JSONCoder coder) {
    id = coder.decodeNum(forKey: 'id');
    title = coder.decodeString(forKey: 'title');
    stats = coder.decodeMap(forKey: 'stats');
    modified = coder.decodeDateTime(forKey: 'modified');
  }
}

var storyLoader = createHttpClient();

class Story extends Object with JSONCoding, EventEmitter {
  int id = 0;
  String title = '';
  String summary = '';
  String description = '';
  String imageURL = '';
  String fullImageURL = '';
  List<String> categories = new List();
  List<String> characters = new List();
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

  void encode(JSONCoder coder) {
    coder.encode(id, forKey: 'id');
    coder.encode(title, forKey: 'title');
    coder.encode(summary, forKey: 'summary');
    coder.encode(description, forKey: 'description');
    coder.encode(imageURL, forKey: 'imageURL');
    coder.encode(fullImageURL, forKey: 'fullImageURL');
    coder.encode(categories, forKey: 'categories');
    coder.encode(characters, forKey: 'characters');
    coder.encode(stats, forKey: 'stats');
    coder.encode(status, forKey: 'status');
    coder.encode(contentRating, forKey: 'contentRating');
    coder.encode(author, forKey: 'author');
    coder.encode(published, forKey: 'published');
    coder.encode(modified, forKey: 'modified');
    coder.encode(chapters, forKey: 'chapters');
    coder.encode(likes, forKey: 'likes');
    coder.encode(dislikes, forKey: 'dislikes');
  }

  void decode(JSONCoder coder) {
    id = coder.decodeNum(forKey: 'id');
    title = coder.decodeString(forKey: 'title');
    summary = coder.decodeString(forKey: 'summary');
    description = coder.decodeString(forKey: 'description');
    imageURL = coder.decodeString(forKey: 'imageURL');
    fullImageURL = coder.decodeString(forKey: 'fullImageURL');
    categories = coder.decodeList(forKey: 'categories');
    characters = coder.decodeList(forKey: 'characters');
    stats = coder.decodeMap(forKey: 'stats');
    status = coder.decodeNum(forKey: 'status');
    contentRating = coder.decodeNum(forKey: 'contentRating');
    author = coder.decodeObject(forKey: 'author', template: new User());
    chapters = coder.decodeList<Chapter>(
        forKey: 'chapters',
        decodeItem: (dynamic item) {
          return new Chapter()..decode(new JSONCoder()..data = item);
        });
    likes = coder.decodeNum(forKey: 'likes');
    dislikes = coder.decodeNum(forKey: 'dislikes');
  }

  Future<File> _getStorageFile() async {
    String directory = (await getApplicationDocumentsDirectory()).path;
    return new File('$directory/story-$id');
  }

  Future<Null> loadFromStorage() async {
    try {
      File file = await _getStorageFile();
      String contents = await file.readAsString();
      decode(new JSONCoder()..data = JSON.decode(contents));

      emit('update', this);
    } on FileSystemException {
      // TODO: possibly handle error
    }
  }

  Future<Null> saveToStorage() async {
    try {
      File file = await _getStorageFile();
      JSONCoder coder = new JSONCoder();
      encode(coder);
      file.writeAsString(JSON.encode(coder));
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

        categories.clear();

        Map<String, bool> storyCategories = story['categories'];
        for (String category in storyCategories.keys) {
          if (storyCategories[category]) {
            categories.add(category);
          }
        }

        List storyChapters = story['chapters'];
        chapters.clear();
        for (Map chapter in storyChapters) {
          chapters.add(new Chapter()
            ..id = chapter['id']
            ..title = chapter['title']
            ..stats['words'] = chapter['words']
            ..stats['views'] = chapter['views']
            ..modified = new DateTime.fromMillisecondsSinceEpoch(
                chapter['date_modified'] * 1000));
        }

        // TODO: characters?

        saveToStorage();
        emit('update', this);
      }
    }
  }

  Future<Null> load() {
    Future storage = loadFromStorage();
    Future network = loadFromNetwork();
    return Future.any([storage, network]);
  }
}

import 'package:flutter/material.dart';
import 'story_view.dart';
import 'data.dart';

class StoriesApp extends StatefulWidget {
  @override
  StoriesAppState createState() => new StoriesAppState();
}

class StoriesAppState extends State<StoriesApp> {
  List<Story> _stories = [];

  @override
  void initState() {
    Story testStory = new Story(id: 240255);
    _stories.add(testStory);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'FiMTether: Stories',
        color: Colors.blue,
        home: new Scaffold(
          appBar: new AppBar(title: new Text('Stories')),
          body: new ListView.builder(
              padding: new EdgeInsets.all(8.0),
              itemCount: _stories.length,
              itemBuilder: (BuildContext context, int index) {
                return new Card(
                    child: new Container(
                        margin: new EdgeInsets.all(10.0),
                        child: new StoryView(story: _stories[index])));
              }),
          floatingActionButton: new FloatingActionButton(
              child: new Icon(Icons.add),
              onPressed: () {
                setState(() {
                  Story story = new Story(id: 240255);
                  _stories.add(story);
                });
              }),
        ));
  }
}

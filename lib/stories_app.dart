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
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'FiMTether: Stories',
        color: Colors.blue,
        home: new Scaffold(
            appBar: new AppBar(title: new Text('Stories')),
            body: new StoryListView()..stories = _stories,
            floatingActionButton: new AddStoryActionButton()
              ..storiesAppState = this));
  }
}

class StoryListView extends StatelessWidget {
  List<Story> stories = [];

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
        padding: new EdgeInsets.all(8.0),
        itemCount: stories.length,
        itemBuilder: (BuildContext context, int index) {
          int _index = index;
          return new GestureDetector(
              child: new Card(
                  child: new Container(
                      margin: new EdgeInsets.all(10.0),
                      child: new StoryView(story: stories[index]))),
              onTapUp: (TapUpDetails details) {
                Navigator.of(context).push(
                    new MaterialPageRoute(builder: (BuildContext context) {
                  // TODO: less hacky way
                  return new Scaffold(
                      appBar: new AppBar(title: new Text(stories[index].title)),
                      body: new ListView.builder(
                          itemCount: stories[index].chapters.length,
                          itemBuilder: (BuildContext context, int index) {
                            Chapter chapter = stories[_index].chapters[index];
                            return new Container(
                                padding: new EdgeInsets.all(4.0),
                                child: new Text('${chapter.title}'));
                          }));
                }));
              });
        });
  }
}

class AddStoryActionButton extends StatelessWidget {
  StoriesAppState storiesAppState;

  @override
  Widget build(BuildContext context) {
    return new FloatingActionButton(
        child: new Icon(Icons.add),
        onPressed: () {
          SimpleDialog dialog = new SimpleDialog(
            title: new Text('Add Story'),
            children: <Widget>[
              new Container(
                  padding: new EdgeInsets.all(8.0),
                  child: new TextField(
                    onSubmitted: (String value) {
                      storiesAppState.setState(() {
                        storiesAppState._stories
                            .add(new Story(id: int.parse(value)));
                      });
                    },
                  ))
            ],
          );
          showDialog(context: context, child: dialog);
        });
  }
}

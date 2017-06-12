import 'package:flutter/material.dart';
import 'story_list.dart';
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
            body: new StoryList()..stories = _stories,
            floatingActionButton: new AddStoryActionButton()
              ..storiesAppState = this));
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

import 'package:flutter/material.dart';
import 'data.dart';

class StoryView extends StatefulWidget {
  Story story;

  StoryView({this.story});

  @override
  StoryViewState createState() => new StoryViewState(story);
}

class StoryViewState extends State<StoryView> {
  Story _story;

  StoryViewState(this._story);

  @override
  void initState() {
    super.initState();

    _story.load();
    _story.on('update', updateHandler);
  }

  void updateHandler(Null) {
    setState(() {
      // HACK
    });
  }

  @override
  void dispose() {
    super.dispose();

    _story.off('update', updateHandler);
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Container(
            padding: new EdgeInsets.symmetric(vertical: 8.0),
            child: new Row(
              children: <Widget>[
                new Expanded(
                    child: new Text(_story.title,
                        style: new TextStyle(fontSize: 18.0))),
                new Container(
                  padding: new EdgeInsets.symmetric(horizontal: 8.0),
                  child: new Text('${_story.likes}'),
                ),
                new Text('${_story.dislikes}')
              ],
            )),
        new LinearProgressIndicator(
            value: (_story.likes > 0 && _story.dislikes > 0)
                ? (_story.likes / (_story.dislikes + _story.likes))
                : 0.0),
        new Row(
          children: <Widget>[new Text(_story.author.name)],
        ),
        new Row(
          children: <Widget>[
            new Container(
              padding: new EdgeInsets.all(4.0),
              width: 100.0,
              child: (_story.imageURL != null && _story.imageURL != '')
                  ? new Image.network(_story.imageURL)
                  : new Container(),
            ),
            new Expanded(
                child: new Text(_story.summary, overflow: TextOverflow.fade))
          ],
        )
      ],
    );
  }
}

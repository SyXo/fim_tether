import 'package:flutter/material.dart';
import 'data.dart';
import 'story.dart';
import 'story_detail.dart';

class StoryList extends StatelessWidget {
  List<Story> stories = new List();

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
      padding: new EdgeInsets.all(8.0),
      physics: new BouncingScrollPhysics(),
      itemCount: stories.length,
      itemBuilder: (BuildContext context, int index) {
        return new GestureDetector(
            child: new Card(
                child: new Container(
                    margin: new EdgeInsets.all(8.0),
                    child: new StoryView(story: stories[index]))),
            onTapUp: (TapUpDetails details) {
              Navigator.of(context).push(
                  new MaterialPageRoute(builder: (BuildContext context) {
                    return new StoryDetail(story: stories[index]);
                  }));
            });
      },
    );
  }
}

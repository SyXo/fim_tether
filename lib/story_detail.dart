import 'package:flutter/material.dart';
import 'story.dart';
import 'data.dart';

class StoryDetail extends StatelessWidget {
  Story story;

  StoryDetail({this.story});

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new CustomScrollView(
      physics: new BouncingScrollPhysics(),
      slivers: <Widget>[
        new SliverAppBar(
            pinned: true,
            expandedHeight: 250.0,
            flexibleSpace: new FlexibleSpaceBar(
                background: new Text('todo'), title: new Text(story.title)),
            actions: <Widget>[
              new IconButton(
                  icon: new Icon(Icons.cloud_download), onPressed: null)
            ]),
        new SliverList(delegate:
            new SliverChildBuilderDelegate((BuildContext context, int index) {
          if (index == 0) {
            return new Container(
                padding: new EdgeInsets.all(8.0),
                child: new Text(story.description));
          } else {
            index -= 1;
            if (index >= story.chapters.length) return null;
            Chapter chapter = story.chapters[index];
            return new ListTile(
                title: new Text(chapter.title),
                subtitle: new Text('${chapter.stats['words']} words'),
                trailing: new IconButton(
                    icon: new Icon(Icons.cloud_download), onPressed: () {}),
                onTap: () {
                  // todo
                });
          }
        }))
      ],
    ));
  }
}

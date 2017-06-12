import 'package:flutter/material.dart';
import 'data.dart';

class ChapterView extends StatefulWidget {
  Chapter chapter;

  ChapterView({this.chapter});

  @override
  ChapterViewState createState() => new ChapterViewState(chapter);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: new Text(chapter.title)),
        body: new CustomScrollView(
          physics: new BouncingScrollPhysics(),
          slivers: <Widget>[
            new RichText(text: new TextSpan(text: chapter.content))
          ],
        ));
  }
}

class ChapterViewState extends State<ChapterView> {
  Chapter _chapter;

  ChapterViewState(this._chapter);

  @override
  void initState() {
    super.initState();

    _chapter.load();
    _chapter.on('update', updateHandler);
  }

  void updateHandler(dynamic data) {
    setState(() {
      // HACK
    });
  }

  @override
  void dispose() {
    super.dispose();

    _chapter.off('update', updateHandler);
  }

  @override
  Widget build(BuildContext context) {
    // all of this is really hacky
    return new Scaffold(
        appBar: new AppBar(title: new Text(_chapter.title)),
        body: new CustomScrollView(
          physics: new BouncingScrollPhysics(),
          slivers: <Widget>[
            new SliverList(
                delegate: new SliverChildListDelegate(<Widget>[
              new Container(
                  padding: new EdgeInsets.all(16.0),
                  child: new RichText(
                      textAlign: TextAlign.justify,
                      text: new TextSpan(
                          text: _chapter.content
                              .replaceAll(new RegExp(r'\n+'), '\n'),
                          style: new TextStyle(
                              fontFamily: 'serif',
                              fontSize: 16.0,
                              color: new Color.fromARGB(255, 0, 0, 0)))))
            ]))
          ],
        ));
  }
}

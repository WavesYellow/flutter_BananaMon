import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game.dart';
import 'lib/flutter/canvas_wrapper.dart';
import 'scene/gameover_scene.dart';
import 'scene/stageloader_scene.dart';
import 'scene/title_scene.dart';
import 'stage/stage.dart';

import 'lib/game_handler.dart';


class MyGame extends BaseGame {
  bool started;

  Map<String, dynamic> map;
  String senceName;

  MyGame() {
    started = false;
    map = new HashMap();
  }


  @override
  void lifecycleStateChange(AppLifecycleState state) {
  }

  _renderFps(Canvas canvas) {
    TextPainter tp = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
            style: TextStyle(
              color: Colors.green,
              fontSize: 20.0,
            ),
            text: "${fps(10).toInt()}"
        )
    );
    tp.layout();
    tp.paint(canvas, Offset.zero);
  }

  @override
  bool debugMode() => true;

  @override
  render(Canvas canvas)  {
    canvas.drawColor(Colors.amber, BlendMode.src);
    canvas.save();
    CanvasWrapper wrapper = CanvasWrapper(canvas, size, 15, 20);
    map[senceName]?.draw(wrapper);
    canvas.restore();
    if (debugMode()) {
      canvas.translate(0.0, 25.0);
      _renderFps(canvas);
    }
  }

  @override
  Future update(double t) async {
    // print('update at ${lastEslapedtime} - ${delta}' );
    if (started) {
      return await map[senceName]?.tick();
    }
  }

}

class MyGameHandler extends GameHandler {
  final MyGame game;

  MyGameHandler(this.game);

  @override
  void add(String name, dynamic scene) {
    game.map[name] = scene;
  }

  @override
  void pause() {
    game.started = false;
    game.map[game.senceName]?.pause();
  }

  @override
  void resume() {
    game.map[game.senceName]?.resume();
    game.started = true;
  }

  @override
  void start(String name, [attr]) {
    print("start scene $name, attr=$attr");
    game.map[game.senceName]?.destroy();
    print("start scene 2");
    game.senceName = name;
    game.map[game.senceName]?.reset(attr);
    game.map[game.senceName]?.resume();
    print("start scene 3");
    game.started = true;
  }


}


Future main() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft
  ]);
  await SystemChrome.setEnabledSystemUIOverlays([]);
  MyGame game = MyGame();
  MyGameHandler iGame = MyGameHandler(game);
  TitleScene title = TitleScene(iGame);
  Stage stage = Stage(iGame);
  GameOverScene over = GameOverScene(iGame);
  StageLoaderScene loader = StageLoaderScene(iGame);
  iGame.add("title", title);
  iGame.add("stage", stage);
  iGame.add("over", over);
  iGame.add("loader", loader);
  runApp(game.widget);
  iGame.start("title");
}




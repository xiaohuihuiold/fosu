import 'package:flutter/material.dart';
import 'package:fosu/scene/map_player_scene.dart';
import 'package:moengine/game/scene/game_scene.dart';

class MapListScene extends GameScene {
  @override
  List<Widget> onBuildUi(BuildContext context) {
    return [
      Center(
        child: RaisedButton(
          child: const Text('测试播放'),
          onPressed: () {
            sceneModule.loadScene(MapPlayerScene());
          },
        ),
      ),
    ];
  }
}

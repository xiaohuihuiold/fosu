import 'package:flutter/material.dart';
import 'package:moengine/game/scene/game_scene.dart';

/// 地图播放页
class MapPlayerScene extends GameScene {
  @override
  List<Widget> onBuildUi(BuildContext context) {
    return [
      Center(
        child: RaisedButton(
          child: const Text('返回'),
          onPressed: () {
            removeScene('测试返回数据');
          },
        ),
      ),
    ];
  }
}

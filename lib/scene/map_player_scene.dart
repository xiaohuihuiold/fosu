import 'package:flutter/material.dart';
import 'package:fosu/common/map/map_loader.dart';
import 'package:moengine/game/scene/game_scene.dart';
import 'package:path_provider/path_provider.dart';

/// 地图播放页
class MapPlayerScene extends GameScene {
  @override
  List<Widget> onBuildUi(BuildContext context) {
    return [
      RaisedButton(
        child: const Text('加载'),
        onPressed: () {},
      ),
    ];
  }
}

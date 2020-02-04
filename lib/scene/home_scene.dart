import 'package:flutter/material.dart';
import 'package:fosu/scene/map_list_scene.dart';
import 'package:moengine/game/scene/game_scene.dart';

/// 主页
class HomeScene extends GameScene {
  @override
  List<Widget> onBuildUi(BuildContext context) {
    double circleRadius = size.height / 1.5;
    return [
      Center(
        child: GestureDetector(
          onTap: () {
            sceneModule.loadScene(MapListScene());
          },
          child: Container(
            width: circleRadius,
            height: circleRadius,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey,
              border: Border.all(
                color: Colors.white,
                width: circleRadius / 20.0,
              ),
              borderRadius: BorderRadius.circular(circleRadius / 2.0),
            ),
            child: Text(
              'TOUCH',
              style: TextStyle(
                color: Colors.white,
                fontSize: 52.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    ];
  }
}

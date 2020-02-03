import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fosu/scene/home_scene.dart';
import 'package:moengine/game/scene/game_scene.dart';
import 'package:moengine/moengine.dart';

/// Splash场景
class SplashScene extends GameScene {
  /// 跳转定时器
  Timer _timer;

  @override
  void onAttach(Moengine moengine) {
    super.onAttach(moengine);
    // 500ms 后跳转到主场景
    _timer = Timer(const Duration(milliseconds: 1000), () {
      sceneModule.loadScene(HomeScene(), remove: true);
    });
  }

  @override
  void onDestroy() {
    _timer.cancel();
    super.onDestroy();
  }

  @override
  List<Widget> onBuildUi(BuildContext context) {
    return [
      Container(
        alignment: Alignment.center,
        child: Center(
          child: Text(
            'FOSU',
            style: TextStyle(
              fontSize: 52.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ];
  }
}

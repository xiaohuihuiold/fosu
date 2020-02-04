import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fosu/common/map/map_loader.dart';
import 'package:moengine/game/scene/game_scene.dart';
import 'package:moengine/moengine.dart';
import 'package:path_provider/path_provider.dart';

/// 地图播放页
class MapPlayerScene extends GameScene {
  /// FPS计数器
  Timer _fpsTimer;
  int _fps = 0;
  int _fpsTemp = 0;
  OSUMapLoader osuMapLoader;

  @override
  void onAttach(Moengine moengine) {
    super.onAttach(moengine);
    // 初始化fps计时器
    _fpsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _fps = _fpsTemp;
      _fpsTemp = 0;
      updateState();
    });
    // 加载地图
    OSUMapLoader.loadFromPath(
            r"/sdcard/osu/499488 Kana Nishino - Sweet Dreams (11t dnb mix)/Kana Nishino - Sweet Dreams (11t dnb mix) (Ascendance) [Nozely's Normal].osu")
        .then((value) {
      osuMapLoader = value;
      updateState();
      print(osuMapLoader);
    });
  }

  @override
  List<Widget> onBuildUi(BuildContext context) {
    return [
      // 展示fps
      Container(
        margin: const EdgeInsets.all(6.0),
        child: Text(
          'FPS: $_fps',
          style: TextStyle(
            color: Colors.white,
            shadows: [BoxShadow(color: Colors.grey, blurRadius: 2.0)],
          ),
        ),
      ),
      // 展示加载进度条
      if (osuMapLoader == null)
        Center(
          child: Container(
            width: size.height / 3,
            height: size.height / 3,
            child: const CircularProgressIndicator(
              strokeWidth: 1.0,
            ),
          ),
        ),
    ];
  }

  @override
  void onUpdate(int deltaTime) {
    _fpsTemp++;
  }

  @override
  void onPause() {}

  @override
  void onDestroy() {
    _fpsTimer.cancel();
    super.onDestroy();
  }
}

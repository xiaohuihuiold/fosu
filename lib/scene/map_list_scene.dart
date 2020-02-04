import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fosu/scene/map_player_scene.dart';
import 'package:moengine/game/scene/game_scene.dart';

class MapListScene extends GameScene {
  @override
  List<Widget> onBuildUi(BuildContext context) {
    return [
      Center(
        child: RaisedButton(
          child: const Text('选择.osu文件'),
          onPressed: () async {
            String osuPath = await FilePicker.getFilePath();
            if (osuPath == null || !osuPath.toUpperCase().endsWith('.OSU')) {
              Fluttertoast.showToast(msg: '请选择.osu文件');
              return;
            }
            sceneModule.loadScene(MapPlayerScene(osuPath));
          },
        ),
      ),
    ];
  }
}

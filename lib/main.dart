import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fosu/scene/splash_scene.dart';
import 'package:moengine/engine/module/scene_module.dart';
import 'package:moengine/moengine.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FOSU',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  /// 初始化引擎并设置方向
  final Moengine _moengine = Moengine(
    orientations: [
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft
    ],
    overlays: [],
  );

  @override
  void initState() {
    super.initState();
    // 加载Splash场景
    _moengine.getModule<SceneModule>().loadScene(SplashScene());
  }

  @override
  void dispose() {
    // 销毁引擎
    _moengine.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: MoengineView(
        moengine: _moengine,
      ),
    );
  }
}

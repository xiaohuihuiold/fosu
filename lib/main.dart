import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fosu/scene/splash_scene.dart';
import 'package:moengine/engine/module/scene_module.dart';
import 'package:moengine/moengine.dart';
import 'package:permission_handler/permission_handler.dart';

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

  /// 请求必要的权限
  Future<Null> _requestPermission() async {
    PermissionStatus storageStatus = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (storageStatus == PermissionStatus.denied) {
      // 权限请求
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.storage]);
      // 没有权限则退出
      if (permissions[PermissionGroup.storage] == PermissionStatus.denied) {
        Fluttertoast.showToast(msg: '未取得储存权限,无法正常运行');
        SystemNavigator.pop();
        return;
      }
    }
    // 请求成功则加载第一个场景
    _moengine.getModule<SceneModule>().loadScene(SplashScene());
  }

  Future<Null> _onFrame(_) async {
    await _requestPermission();
  }

  @override
  void initState() {
    super.initState();
    // 加载Splash场景
    WidgetsBinding.instance.addPostFrameCallback(_onFrame);
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

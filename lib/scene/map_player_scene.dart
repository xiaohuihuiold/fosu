import 'dart:async';
import 'dart:ui' as ui;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fosu/common/util/image_util.dart';
import 'package:moengine/game/game_object.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fosu/common/map/map_info.dart';
import 'package:fosu/common/map/map_loader.dart';
import 'package:fosu/common/map/storyboard_event.dart';
import 'package:fosu/common/map/storyboard_info.dart';
import 'package:moengine/game/component/game_component.dart';
import 'package:moengine/game/scene/game_scene.dart';
import 'package:moengine/moengine.dart';

const double OSB_WIDTH = 640.0;
const double OSB_WIDTH_LARGE = 800.0;
const double OSB_HEIGHT = 480.0;

/// 地图播放页
class MapPlayerScene extends GameScene {
  final String osuPath;

  /// FPS计数器
  Timer _fpsTimer;
  int _fps = 0;
  int _fpsTemp = 0;
  OSUMapLoader _osuMapLoader;

  /// 音频播放器
  final AudioPlayer _audioPlayer = AudioPlayer();

  /// 音频更新计时器
  Timer _positionTimer;
  int _currentTime = 0;
  int _duration = 0;
  bool _canUpdate = false;

  /// 绘制类
  _StoryBoardPainter _painter;

  MapPlayerScene(this.osuPath) : assert(osuPath != null);

  @override
  void onAttach(Moengine moengine) {
    super.onAttach(moengine);

    // 初始化fps计时器
    _fpsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _fps = _fpsTemp;
      _fpsTemp = 0;
      updateState();
    });
    _audioPlayer.onPlayerStateChanged.listen((event) {
      switch (event) {
        case AudioPlayerState.STOPPED:
          _canUpdate = false;
          break;
        case AudioPlayerState.PLAYING:
          Future.delayed(const Duration(seconds: 1))
              .then((value) => _canUpdate = true);
          break;
        case AudioPlayerState.PAUSED:
          _canUpdate = false;
          break;
        case AudioPlayerState.COMPLETED:
          _canUpdate = false;
          break;
      }
    });
    // 初始化音频更新计时器
    _positionTimer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      if (!_canUpdate) {
        return;
      }
      _audioPlayer.getDuration().then((time) {
        _duration = time;
      });
      _audioPlayer.getCurrentPosition().then((time) {
        _currentTime = time;
        update();
      });
    });

    // 加载地图
    OSUMapLoader.loadFromPath(osuPath).then((value) async {
      _osuMapLoader = value;
      if (_osuMapLoader == null) {
        Fluttertoast.showToast(msg: '加载失败');
        return;
      }
      await _osuMapLoader?.initImages();
      _painter = _StoryBoardPainter(_osuMapLoader.mapInfo);

      updateState();
      _play();
    });
    addGameObject(createObject([
      PositionComponent(),
      SizeComponent(size: size),
      SpriteComponent(),
    ]));
    addGameObject(
      createObject([
        PositionComponent(),
        SizeComponent(size: size),
        RenderComponent(customRender: (gameObject, canvas, paint) {
          _painter?.time = _currentTime;
          _painter?.paint(canvas, size);
        }),
      ]),
    );
  }

  Future<Null> _play() async {
    await _audioPlayer.play(
        '${_osuMapLoader.mapInfo.path}/${_osuMapLoader.mapInfo.general.audioFilename}',
        isLocal: true);
  }

  @override
  List<Widget> onBuildUi(BuildContext context) {
    return [
      // 展示fps
      Container(
        margin: const EdgeInsets.all(6.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'FPS: $_fps',
              style: TextStyle(
                fontSize: 10.0,
                color: Colors.white,
                shadows: [BoxShadow(color: Colors.grey, blurRadius: 2.0)],
              ),
            ),
            Text(
              'POSITION: $_currentTime',
              style: TextStyle(
                fontSize: 10.0,
                color: Colors.white,
                shadows: [BoxShadow(color: Colors.grey, blurRadius: 2.0)],
              ),
            ),
          ],
        ),
      ),
      // 显示控制条
      if (_osuMapLoader != null)
        Container(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: kToolbarHeight,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
            ),
            child: Slider(
              value: _currentTime.toDouble(),
              min: 0.0,
              max: _duration.toDouble(),
              onChanged: (time) {
                _audioPlayer?.seek(Duration(milliseconds: time.toInt()));
              },
            ),
          ),
        ),
      // 展示加载进度条
      if (_osuMapLoader == null)
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: size.height / 3,
                height: size.height / 3,
                child: const CircularProgressIndicator(
                  strokeWidth: 1.0,
                ),
              ),
              const SizedBox(height: 10.0),
              Text(
                '加载${path.basename(osuPath)}...',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
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
    _positionTimer.cancel();
    _audioPlayer.stop();
    _audioPlayer.release();
    super.onDestroy();
  }
}

/// 自定义storyboard画板
class _StoryBoardPainter {
  final Paint _girdPaint = Paint();
  final Paint _spritePaint = Paint();
  final Paint _borderPaint = Paint()
    ..color = Colors.redAccent
    ..style = PaintingStyle.stroke;

  Canvas _canvas;
  Size _size;
  double _scale;
  double _offsetX;

  int time;
  final OSUMapInfo mapInfo;

  _StoryBoardPainter(this.mapInfo);

  void paint(Canvas canvas, Size size) {
    _canvas = canvas;
    _size = size;
    _scale = _size.height / OSB_HEIGHT;
    _offsetX = (_size.width - OSB_WIDTH * _scale) / 2.0;
    double offsetXLarge = (_size.width - OSB_WIDTH_LARGE * _scale) / 2.0;

    _clearCanvas();
    // _drawGird();

    if (mapInfo?.events != null) {
      _canvas.save();
      _canvas.clipRect(Rect.fromLTWH(
          offsetXLarge, 0.0, OSB_WIDTH_LARGE * _scale, OSB_HEIGHT * _scale));
      _drawSprites(mapInfo.events.backgrounds);
      _drawSprites(mapInfo.events.foregrounds);
      _canvas.restore();
    }
  }

  void _drawSprites(List<Sprite> sprites) {
    int ti = time;
    sprites.forEach((sprite) {
      SpriteData spriteData = sprite.getSpriteData(ti);
      if (spriteData == null) {
        return;
      }
      _drawImage(sprite, sprite.getImage(ti), spriteData);
    });
  }

  /// 清理画布
  void _clearCanvas() {
    _canvas.drawColor(Colors.white.withOpacity(0), BlendMode.color);
  }

  /// 绘制网格
  void _drawGird() {
    _girdPaint.color = Colors.white54;
    _girdPaint.strokeWidth = 1.5;
    _drawLine(Offset(0, 0), Offset(640.0, 0), _girdPaint);
    _drawLine(Offset(0, 480.0), Offset(640.0, 480.0), _girdPaint);
    _drawLine(Offset(0, 0), Offset(0, 480), _girdPaint);
    _drawLine(Offset(640.0, 0), Offset(640.0, 480.0), _girdPaint);
    _drawLine(Offset(320.0, 0), Offset(320.0, 480), _girdPaint);
    _drawLine(Offset(0.0, 240.0), Offset(640.0, 240.0), _girdPaint);

    _girdPaint.color = Colors.white30;
    _girdPaint.strokeWidth = 1.0;
    for (int w = 1; w < 8; w++) {
      if (w == 4) {
        continue;
      }
      _drawLine(Offset(80.0 * w, 0), Offset(80.0 * w, 480.0), _girdPaint);
    }
    for (int h = 1; h < 6; h++) {
      if (h == 3) {
        continue;
      }
      _drawLine(Offset(0, 80.0 * h), Offset(640.0, 80.0 * h), _girdPaint);
    }
  }

  /// 适应画线
  void _drawLine(Offset start, Offset end, Paint paint) {
    _canvas.drawLine(
      start.translate(_offsetX, 0).scale(_scale, _scale),
      end.translate(_offsetX, 0).scale(_scale, _scale),
      _girdPaint,
    );
  }

  /// 适应画图片
  void _drawImage(Sprite sprite, ui.Image image, SpriteData spriteData) {
    if (spriteData.opacity <= 0.0 ||
        spriteData.scaleX <= 0.0 ||
        spriteData.scaleY <= 0.0) {
      return;
    }
    double scaleX = spriteData.scaleX;
    double scaleY = spriteData.scaleY;
    double angle = spriteData.angle;
    Offset position =
        spriteData.position.scale(_scale, _scale).translate(_offsetX, 0);

    _spritePaint.color = spriteData.color;
    double r = spriteData.color.red / 255.0;
    double g = spriteData.color.green / 255.0;
    double b = spriteData.color.blue / 255.0;
    double a = spriteData.color.alpha / 255.0;
    _spritePaint.colorFilter = ColorFilter.matrix([
      r, 0.0, 0.0, 0.0, 0.0, //
      0.0, g, 0.0, 0.0, 0.0, //
      0.0, 0.0, b, 0.0, 0.0, //
      0.0, 0.0, 0.0, 1.0, 0.0, //
    ]);

    _canvas.save();
    _canvas.translate(position.dx, position.dy);
    _canvas.rotate(angle);
    _canvas.translate(-position.dx, -position.dy);

    position = (spriteData.position - spriteData.offset)
        .scale(_scale, _scale)
        .translate(_offsetX, 0);

    Rect rectPos = Rect.fromLTWH(
      position.dx,
      position.dy,
      image.width * scaleX * _scale,
      image.height * scaleY * _scale,
    );

    _spritePaint.blendMode = BlendMode.srcOver;
    switch (spriteData.parameterType) {
      case ParameterType.H:
        //rectPos = Rect.fromLTRB(rectPos.right, rectPos.top, rectPos.left, rectPos.bottom);
        break;
      case ParameterType.V:
        //rectPos = Rect.fromLTRB(rectPos.top, rectPos.bottom, rectPos.right, rectPos.top);
        break;
      case ParameterType.A:
        _spritePaint.blendMode = BlendMode.plus;
        break;
    }

    _canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      rectPos,
      _spritePaint,
    );
    // 绘制边框
    // _canvas.drawRect(rectPos, _borderPaint);
    /// TODO: DEBUG
    if (sprite.startTime == 123895 &&
        sprite.endTime == 125780 &&
        sprite.events.length == 6) {
      /*print('////////');
      sprite.events.forEach((e) {
        print('${e.startTime} ${e.endTime} $e');
      });*/
      _canvas.drawRect(rectPos, _borderPaint);
    }
    _canvas.restore();
  }
}

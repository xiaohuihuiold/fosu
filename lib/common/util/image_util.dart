import 'dart:io';
import 'dart:ui';

class ImageUtil {
  /// 加载图片
  static final Map<String, Image> _imageCache = Map();

  static Future<Image> loadImage(String path) async {
    Image image = _imageCache[path.trim()];
    if (image != null) {
      return image;
    }
    File file = File(path);
    if (!(await file.exists())) {
      return null;
    }
    Codec codec = await instantiateImageCodec(
        file.readAsBytesSync().buffer.asUint8List());
    FrameInfo frameInfo = await codec.getNextFrame();
    image = frameInfo.image;
    _imageCache[path.trim()] = image;
    return image;
  }

  static void clearImage() {
    _imageCache.clear();
  }
}

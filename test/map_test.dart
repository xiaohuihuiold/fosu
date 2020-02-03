import 'dart:isolate';

import 'package:flutter_test/flutter_test.dart';
import 'package:fosu/common/map/map_loader.dart';

void main() {
  test('map test', () async {
    ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(echo, receivePort.sendPort);
    SendPort sendPort = await receivePort.first;
    OSUMapLoader msg = await send(sendPort, '测试');
    print(msg.mapInfo);
  });
}

void echo(SendPort sendPort) async {
  ReceivePort receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);
  await for (var msg in receivePort) {
    print(msg[0]);
    SendPort send = msg[1];
    send.send(OSUMapLoader());
  }
}

Future send(SendPort port, msg) {
  ReceivePort receivePort = ReceivePort();
  port.send([msg, receivePort.sendPort]);
  return receivePort.first;
}

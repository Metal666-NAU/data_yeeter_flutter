import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'settings.dart';

class WebSocketConnection {
  late final WebSocketChannel _webSocketChannel;

  WebSocketConnection(final Future<void> Function(dynamic)? onMessage) {
    _webSocketChannel = WebSocketChannel.connect(
      Uri.parse((kDebugMode
          ? Settings.debugServerAddress.valueOrDefault
          : Settings.productionServerAddress.valueOrDefault)!),
    )..stream.listen(
        onMessage,
        onDone: () => log('Websocket closed'),
        onError: (final e) =>
            log('Websocket emitted an error: ${e.toString()}'),
      );
  }

  void send(
    final String type, [
    final dynamic message,
  ]) {
    _webSocketChannel.sink.add(jsonEncode({
      'type': type,
      if (message != null) 'message': message,
    }));
  }

  Future<void> dispose() async {
    await _webSocketChannel.sink.close();
  }
}

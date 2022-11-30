import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:path/path.dart';

import 'settings.dart';
import 'webrtc.dart';
import 'websockets.dart';

class FileShareRepository {
  WebSocketConnection? _webSocketConnection;
  WebRTCConnection? _webRtcConnection;

  Future<Stream<List<int>>?> startFileShare({
    required final String targetUuid,
    required final String filePath,
  }) async {
    if (_webSocketConnection != null) {
      return null;
    }

    final StreamController<List<int>> chunkStream =
        StreamController<List<int>>();

    _webSocketConnection = WebSocketConnection((final message) async {
      final Map<String, dynamic> data = jsonDecode(message);

      switch (data['type']) {
        case 'init':
          {
            _webSocketConnection!.send(
              'sendFile',
              {
                'uuid': Settings.uuid.value,
                'otherUuid': targetUuid,
                'fileName': basename(filePath),
                'fileSize': await File(filePath).length(),
              },
            );

            break;
          }
        case 'startSignalling':
          {
            await _createWebRTCConnection(chunkStream);

            final String? offer = await _webRtcConnection!.createOffer();

            if (offer == null) {
              return;
            }

            _webSocketConnection!.send('offer', offer);

            break;
          }
        case 'answer':
          {
            final String? answer = data['message'];

            if (answer == null) {
              return;
            }

            _startBroadcastingCandidates();

            await _webRtcConnection!.startStream(
              answer,
              filePath,
            );

            break;
          }
        case 'candidate':
          {
            await _webRtcConnection!.addCandidate(RTCIceCandidate(
              data['message']['candidate'],
              data['message']['sdpMid'],
              data['message']['sdpMLineIndex'],
            ));

            break;
          }
      }
    });

    return chunkStream.stream;
  }

  Future<Stream<List<int>>?> connectToFileShare({
    required final String sourceUuid,
    required final Future<void> Function(
      String fileName,
      int fileSize,
    )
        onFileInfo,
  }) async {
    if (_webSocketConnection != null) {
      return null;
    }

    final StreamController<List<int>> chunkStream =
        StreamController<List<int>>();

    _webSocketConnection = WebSocketConnection((final message) async {
      final Map<String, dynamic> data = jsonDecode(message);

      switch (data['type']) {
        case 'init':
          {
            _webSocketConnection!.send(
              'connectToFileShare',
              {
                'uuid': Settings.uuid.value,
                'otherUuid': sourceUuid,
              },
            );

            break;
          }
        case 'fileInfo':
          {
            await onFileInfo(
              data['message']['name'],
              data['message']['size'],
            );

            break;
          }
        case 'offer':
          {
            await _createWebRTCConnection(chunkStream);

            final String? answer =
                await _webRtcConnection!.createAnswer(data['message']);

            if (answer == null) {
              return;
            }

            _webSocketConnection!.send('answer', answer);

            _startBroadcastingCandidates();

            break;
          }
        case 'candidate':
          {
            await _webRtcConnection!.addCandidate(RTCIceCandidate(
              data['message']['candidate'],
              data['message']['sdpMid'],
              data['message']['sdpMLineIndex'],
            ));

            break;
          }
      }
    });

    return chunkStream.stream;
  }

  void receiveFile() => _webSocketConnection!.send('receiveFile');

  Future<void> cancel() async {
    await _webSocketConnection?.dispose();
    await _webRtcConnection?.dispose();

    _webSocketConnection = null;
    _webRtcConnection = null;
  }

  Future<void> _createWebRTCConnection(
      final StreamController<List<int>> chunkStream) async {
    await _webRtcConnection?.dispose();

    _webRtcConnection = WebRTCConnection(chunkStream);

    await _webRtcConnection!.connect();
  }

  void _startBroadcastingCandidates() =>
      _webRtcConnection!.candidateStream.stream
          .listen((final candidate) => _webSocketConnection?.send(
                'candidate',
                {
                  'candidate': candidate?.candidate,
                  'sdpMLineIndex': candidate?.sdpMLineIndex,
                  'sdpMid': candidate?.sdpMid,
                },
              ));
}

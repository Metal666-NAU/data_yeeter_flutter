import 'dart:async';
import 'dart:convert';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:path/path.dart';

import 'settings.dart';
import 'webrtc.dart';
import 'websockets.dart';

class FileShareRepository {
  final StreamController<int> sizeStream = StreamController.broadcast();
  final StreamController<List<int>> chunksStream = StreamController.broadcast();

  WebSocketConnection? _webSocketConnection;
  WebRTCConnection? _webRtcConnection;

  Future<void> startFileShare(
    final String targetUuid,
    final String filePath,
  ) async {
    if (_webSocketConnection != null) {
      return;
    }

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
              },
            );

            break;
          }
        case 'startSignalling':
          {
            await _createWebRTCConnection();

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
  }

  Future<void> connectToFileShare(
    final String sourceUuid,
    final Future<void> Function(String fileName) onFileName,
  ) async {
    if (_webSocketConnection != null) {
      return;
    }

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
        case 'fileName':
          {
            await onFileName(data['message']);

            break;
          }
        case 'offer':
          {
            await _createWebRTCConnection();

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
  }

  void receiveFile() => _webSocketConnection!.send('receiveFile');

  Future<void> cancel() async {
    await _webSocketConnection?.dispose();
    await _webRtcConnection?.dispose();

    _webSocketConnection = null;
    _webRtcConnection = null;
  }

  Future<void> _createWebRTCConnection() async {
    await _webRtcConnection?.dispose();

    _webRtcConnection =
        WebRTCConnection((final chunk) => chunksStream.add(chunk));

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

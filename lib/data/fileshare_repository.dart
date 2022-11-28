import 'dart:async';

import 'networking.dart';
import 'settings.dart';
import 'webrtc.dart';

class FileShareRepository {
  final StreamController<int> sizeStream = StreamController.broadcast();
  final StreamController<List<int>> chunksStream = StreamController.broadcast();

  WebRTCConnection? _connection;

  Future<void> startFileShare(
    final String targetUuid,
    final String fileName,
  ) async {
    await _connection?.dispose();

    _connection = WebRTCConnection((final chunk) => chunksStream.add(chunk));

    await _connection!.connect();

    final String? offer = await _connection!.createOffer();

    if (offer == null) {
      return;
    }

    await post('/startFileShare', body: {
      Settings.uuid.key: Settings.uuid.value,
      'targetUuid': targetUuid,
      'offer': offer,
      'fileName': fileName,
    });
  }

  Future<String?> connectToFileShare(final String sourceUuid) async {
    await _connection?.dispose();

    _connection = WebRTCConnection((final chunk) => chunksStream.add(chunk));

    await _connection!.connect();

    final Map<String, dynamic>? response = (await get<Map<String, dynamic>>(
      '/connectToFileShare',
      queryParameters: {
        Settings.uuid.key: Settings.uuid.value,
        'sourceUuid': sourceUuid,
      },
    ))
        .body;

    if (response?['offer'] == null) {
      return null;
    }

    final String? answer = await _connection!.createAnswer(response!['offer']);

    if (answer == null) {
      return null;
    }

    await post('/receiveFile', body: {
      'answer': answer,
    });

    return response['fileName'];
  }

  Future<void> sendFile(final String path) async {
    if (_connection == null) {
      return;
    }

    final String? answer =
        (await get<Map<String, dynamic>>('/sendFile')).body?['answer'];

    if (answer == null) {
      return;
    }

    await _connection!.startStream(
      answer,
      path,
    );
  }
}

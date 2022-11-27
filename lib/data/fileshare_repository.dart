import 'dart:async';

import 'networking.dart';
import 'settings.dart';
import 'webrtc.dart';

class FileShareRepository {
  final StreamController<int> sizeStream = StreamController.broadcast();
  final StreamController<List<int>> chunksStream = StreamController.broadcast();

  void init() {
    chunks.stream.listen((final event) => chunksStream.add(event));
  }

  Future<void> startFileShare(
    final String targetUuid,
    final String fileName,
  ) async {
    await connect();

    final String? offer = await createOffer();

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
    await connect();

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

    final String? answer = await createAnswer(response!['offer']);

    if (answer == null) {
      return null;
    }

    await post('/receiveFile', body: {
      'answer': answer,
    });

    return response['fileName'];
  }

  Future<void> sendFile(final String path) async {
    final String? answer =
        (await get<Map<String, dynamic>>('/sendFile')).body?['answer'];

    if (answer == null) {
      return;
    }

    await startStream(
      answer,
      path,
    );

    //fileChannel?.onMessage = (final message) => chunksStream.sink.add(message.binary);
  }
}

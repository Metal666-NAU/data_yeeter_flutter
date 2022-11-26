import 'dart:async';

import 'networking.dart';
import 'settings.dart';
import 'webrtc.dart';

class FileShareRepository {
  final StreamController<double> progressStream = StreamController.broadcast();

  FileShareRepository();

  Future<void> startFileShare(final String targetUuid) async {
    await connect();

    final String? offer = await createOffer();

    if (offer == null) {
      return;
    }

    await post('/startFileShare', body: {
      Settings.uuid.key: Settings.uuid.value,
      'targetUuid': targetUuid,
      'offer': offer,
    });
  }

  Future<void> connectToFileShare(final String sourceUuid) async {
    await connect();

    final String? offer = (await get<Map<String, dynamic>>(
      '/connectToFileShare',
      queryParameters: {
        Settings.uuid.key: Settings.uuid.value,
        'sourceUuid': sourceUuid,
      },
    ))
        .body?['offer'];

    if (offer == null) {
      return;
    }

    final String? answer = await createAnswer(offer);

    if (answer == null) {
      return;
    }

    await post('/receiveFile', body: {
      'answer': answer,
    });
  }

  Future<void> sendFile() async {
    final String? answer =
        (await get<Map<String, dynamic>>('/sendFile')).body?['answer'];

    if (answer == null) {
      return;
    }

    await startStream(answer);
  }
}

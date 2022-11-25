import 'networking.dart';
import 'settings.dart';
import 'webrtc.dart';

class FileshareRepository {
  Future<void> startFileShare() async {
    await connect();

    final String? offer = await createOffer();

    if (offer == null) {
      return;
    }

    await post('/startFileShare', body: {
      Settings.uuid.key: Settings.uuid.value,
      'offer': offer,
    });
  }

  Future<void> connectToFileShare() async {
    await connect();

    final String? offer = (await get<Map<String, dynamic>>(
      '/connectToFileShare',
      queryParameters: {
        Settings.uuid.key: Settings.uuid.value,
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
    final Map<String, dynamic>? response =
        (await get<Map<String, dynamic>>('/sendFile')).body;

    if (response == null) {
      return;
    }

    await startStream(
      response['answer'],
      response['candidate'],
    );
  }
}

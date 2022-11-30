import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

const Map<String, dynamic> _configuration = {
  'iceServers': [
    {'url': 'stun:stun.l.google.com:19302'},
  ]
};

const Map<String, dynamic> _constraints = {
  'mandatory': {
    'OfferToReceiveAudio': false,
    'OfferToReceiveVideo': false,
  },
  'optional': [],
};

class WebRTCConnection {
  late final RTCPeerConnection _peerConnection;
  RTCDataChannel? _fileChannel;

  final StreamController<List<int>> fileWriteStream;

  final StreamController<RTCIceCandidate?> candidateStream =
      StreamController<RTCIceCandidate?>();

  WebRTCConnection(this.fileWriteStream);

  Future<void> connect() async {
    _peerConnection = await createPeerConnection(_configuration);

    _peerConnection.onIceCandidate = (final candidate) {
      log('New ICE Candidate available: ${candidate.candidate}');

      candidateStream.add(candidate);
    };

    _peerConnection.onIceConnectionState = (final state) {
      log('ICE Connection State changed to: ${state.toString()}');
    };
    _peerConnection.onConnectionState = (final state) {
      log('Connection State changed to: ${state.toString()}');
    };
    _peerConnection.onSignalingState = (final state) {
      log('Signalling State changed to: ${state.toString()}');
    };
  }

  Future<String?> createOffer() async {
    _fileChannel =
        await _peerConnection.createDataChannel('file', RTCDataChannelInit());

    final RTCSessionDescription description =
        await _peerConnection.createOffer(_constraints);

    log('Offer was created!');
    log(description.sdp ?? '');

    await _peerConnection.setLocalDescription(description);

    return description.sdp;
  }

  Future<String?> createAnswer(final String offer) async {
    _peerConnection.onDataChannel = (final channel) {
      if (channel.label == 'file') {
        channel.onMessage = (final data) {
          fileWriteStream.add(data.binary);
        };
        channel.onDataChannelState = (final state) async {
          if (state == RTCDataChannelState.RTCDataChannelClosed) {
            await fileWriteStream.close();
          }
        };
      }
    };

    final RTCSessionDescription offerDescription =
        RTCSessionDescription(offer, 'offer');

    log('Offer was received!');

    await _peerConnection.setRemoteDescription(offerDescription);

    final RTCSessionDescription answerDescription =
        await _peerConnection.createAnswer(_constraints);

    if (answerDescription.sdp == null) {
      return null;
    }

    log('Answer was created!');

    await _peerConnection.setLocalDescription(answerDescription);

    return answerDescription.sdp;
  }

  Future<void> startStream(
    final String answer,
    final String filePath,
  ) async {
    final RTCSessionDescription description =
        RTCSessionDescription(answer, 'answer');

    log('Answer was received!');
    log(answer);

    await _peerConnection.setRemoteDescription(description);

    final ChunkedStreamReader reader =
        ChunkedStreamReader(File(filePath).openRead());

    Timer.periodic(
      const Duration(milliseconds: 100),
      (final timer) async {
        final List<int> chunk = (await reader.readChunk(64 * 1024)).cast<int>();

        if (chunk.isEmpty) {
          await _fileChannel!.close();
          await fileWriteStream.close();
          timer.cancel();

          return;
        }

        fileWriteStream.add(chunk);

        await _fileChannel!
            .send(RTCDataChannelMessage.fromBinary(Uint8List.fromList(chunk)));
      },
    );
  }

  Future<void> addCandidate(final RTCIceCandidate candidate) async {
    log('Adding new candidate: ${candidate.candidate}');

    await _peerConnection.addCandidate(candidate);
  }

  Future<void> dispose() async {
    await _peerConnection.dispose();
    await _fileChannel?.close();
    await candidateStream.close();
  }
}

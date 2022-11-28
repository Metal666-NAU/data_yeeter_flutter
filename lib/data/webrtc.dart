import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

const Map<String, dynamic> _configuration = {
  'iceServers': [
    {'url': 'stun:stun.l.google.com:19302'},
  ]
};

class WebRTCConnection {
  final void Function(List<int> chunk) onFileChunk;

  late final RTCPeerConnection _peerConnection;

  WebRTCConnection(this.onFileChunk);

  Future<void> connect() async {
    _peerConnection = await createPeerConnection(_configuration);

    _peerConnection.onIceCandidate = (final candidate) {
      log('New ICE Candidate available: ${candidate.candidate}');

      _peerConnection.addCandidate(candidate);
    };

    _peerConnection.onIceConnectionState = (final state) {
      log('ICE Connection State changed to: ${state.toString()}');
    };
  }

  Future<String?> createOffer() async {
    final RTCSessionDescription description =
        await _peerConnection.createOffer();

    if (description.sdp == null) {
      return null;
    }

    log('Offer was created!');

    await _peerConnection.setLocalDescription(description);

    return description.sdp!;
  }

  Future<String?> createAnswer(final String offer) async {
    final RTCSessionDescription offerDescription =
        RTCSessionDescription(offer, 'offer');

    if (offerDescription.sdp == null) {
      return null;
    }

    log('Offer was received!');

    await _peerConnection.setRemoteDescription(offerDescription);

    final RTCSessionDescription answerDescription =
        await _peerConnection.createAnswer();

    if (answerDescription.sdp == null) {
      return null;
    }

    log('Answer was created!');

    await _peerConnection.setLocalDescription(answerDescription);

    _peerConnection.onDataChannel = (final channel) {
      switch (channel.label) {
        case 'control':
          {
            //controlChannel = channel;
            break;
          }
        case 'file':
          {
            //fileChannel = channel;
            channel.onMessage = (final data) => onFileChunk(data.binary);
            break;
          }
      }
    };

    return answerDescription.sdp!;
  }

  Future<void> startStream(
    final String answer,
    final String filePath,
  ) async {
    final RTCSessionDescription description =
        RTCSessionDescription(answer, 'answer');

    if (description.sdp == null) {
      return;
    }

    log('Answer was received!');

    await _peerConnection.setRemoteDescription(description);

    final RTCDataChannel fileChannel =
        (await _peerConnection.createDataChannel('file', RTCDataChannelInit()));

    await File(filePath).openRead().listen((final event) {
      onFileChunk(event);

      fileChannel
          .send(RTCDataChannelMessage.fromBinary(Uint8List.fromList(event)));
    }).asFuture();
  }

  Future<void> dispose() async {
    await _peerConnection.dispose();
  }
}

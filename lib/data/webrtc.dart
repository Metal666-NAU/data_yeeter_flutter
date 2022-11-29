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

const Map<String, dynamic> _constraints = {
  'mandatory': {
    'OfferToReceiveAudio': false,
    'OfferToReceiveVideo': false,
  },
  'optional': [],
};

class WebRTCConnection {
  final void Function(List<int> chunk) onFileChunk;

  late final RTCPeerConnection _peerConnection;
  late final RTCDataChannel _fileChannel;

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
        channel.onMessage = (final data) => onFileChunk(data.binary);
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

    await File(filePath).openRead().listen((final event) {
      onFileChunk(event);

      _fileChannel
          .send(RTCDataChannelMessage.fromBinary(Uint8List.fromList(event)));
    }).asFuture();
  }

  Future<void> dispose() async {
    await _peerConnection.dispose();
    await _fileChannel.close();
  }
}

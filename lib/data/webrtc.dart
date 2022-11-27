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

StreamController<List<int>> chunks = StreamController.broadcast();

RTCPeerConnection? _peerConnection;

Future<void> connect() async {
  await _peerConnection?.dispose();

  _peerConnection = await createPeerConnection(_configuration);

  _peerConnection!.onIceCandidate = (final candidate) {
    _peerConnection!.addCandidate(candidate);
  };

  _peerConnection!.onIceConnectionState = (final state) {
    log(state.toString());
  };
}

Future<String?> createOffer() async {
  if (_peerConnection == null) {
    return null;
  }

  final RTCSessionDescription description =
      await _peerConnection!.createOffer();

  if (description.sdp == null) {
    return null;
  }

  log('Created offer: ${description.sdp}');

  await _peerConnection!.setLocalDescription(description);

  return description.sdp!;
}

Future<String?> createAnswer(final String offer) async {
  if (_peerConnection == null) {
    return null;
  }

  final RTCSessionDescription offerDescription =
      RTCSessionDescription(offer, 'offer');

  if (offerDescription.sdp == null) {
    return null;
  }

  log('Received offer: ${offerDescription.sdp}');

  await _peerConnection!.setRemoteDescription(offerDescription);

  final RTCSessionDescription answerDescription =
      await _peerConnection!.createAnswer();

  if (answerDescription.sdp == null) {
    return null;
  }

  log('Created answer: ${answerDescription.sdp}');

  await _peerConnection!.setLocalDescription(answerDescription);

  _peerConnection!.onDataChannel = (final channel) {
    switch (channel.label) {
      case 'control':
        {
          //controlChannel = channel;
          break;
        }
      case 'file':
        {
          //fileChannel = channel;
          channel.onMessage = (final data) => chunks.add(data.binary);
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
  if (_peerConnection == null) {
    return;
  }

  final RTCSessionDescription description =
      RTCSessionDescription(answer, 'answer');

  if (description.sdp == null) {
    return;
  }

  log('Received answer: ${description.sdp}');

  await _peerConnection!.setRemoteDescription(description);

  //controlChannel = await _peerConnection!.createDataChannel('control', RTCDataChannelInit());
  //fileChannel = await _peerConnection!.createDataChannel('file', RTCDataChannelInit());

  final RTCDataChannel fileChannel =
      (await _peerConnection!.createDataChannel('file', RTCDataChannelInit()));

  await File(filePath).openRead().listen((final event) {
    chunks.add(event);

    fileChannel
        .send(RTCDataChannelMessage.fromBinary(Uint8List.fromList(event)));
  }).asFuture();
}

import 'dart:io';

import 'package:data_yeeter_flutter/data/settings_repository.dart';
import 'package:hive/hive.dart';

import 'networking.dart';

class FriendsRepository {
  late Box _friendsBox;

  Future<void> init() async {
    //await Hive.deleteBoxFromDisk('friends');

    _friendsBox = await Hive.openBox('friends');
  }

  List<Friend> getFriends() => _friendsBox.values
      .map((value) => Friend.fromMap(Map<String, dynamic>.from(value)))
      .toList();

  Future<void> addFriend(Friend friend) async =>
      friend.key = await _friendsBox.add(friend.toMap());

  Future<void> removeFriend(Friend friend) async =>
      await _friendsBox.delete(friend.key);

  Future<String?> goOnline() async => (await post<Map<String, dynamic>>(
        '/goOnline',
        body: {'uuid': Settings.uuid.value},
      ))
          .body?['discoveryCode'];

  Future<bool?> goOffline() async {
    switch ((await post('/goOffline')).statusCode) {
      case HttpStatus.ok:
        {
          return true;
        }
      case HttpStatus.badRequest:
        {
          return false;
        }
      default:
        {
          return null;
        }
    }
  }
}

class Friend {
  int? key;

  final String uuid;
  final String name;

  Friend({
    required this.uuid,
    required this.name,
  });

  Map<String, dynamic> toMap() => {
        'uuid': uuid,
        'name': name,
      };

  factory Friend.fromMap(Map<String, dynamic> map) => Friend(
        uuid: map['uuid'],
        name: map['name'],
      );
}

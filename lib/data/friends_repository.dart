import 'package:hive/hive.dart';

class FriendsRepository {
  late Box _friendsBox;

  Future<void> init() async {
    _friendsBox = await Hive.openBox('friends');
  }

  List<Friend> getFriends() => _friendsBox.keys
      .map(
        (final key) => Friend.fromMap(
          Map<String, dynamic>.from(_friendsBox.get(key)),
        )..key = key,
      )
      .toList();

  Future<void> addFriend(final Friend friend) async =>
      friend.key = await _friendsBox.add(friend.toMap());

  Future<bool> removeFriend(final Friend friend) async {
    if (!_friendsBox.containsKey(friend.key)) {
      return false;
    }

    await _friendsBox.delete(friend.key);

    return true;
  }
}

class Friend {
  int? key;

  final String? uuid;
  final String? name;

  Friend({
    this.uuid,
    this.name,
  });

  Map<String, dynamic> toMap() => {
        'uuid': uuid,
        'name': name,
      };

  factory Friend.fromMap([final Map<String, dynamic> map = const {}]) => Friend(
        uuid: map['uuid'],
        name: map['name'],
      );
}

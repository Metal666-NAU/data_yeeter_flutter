import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/friends_repository.dart';
import '../../../data/settings.dart';
import 'events.dart' as home_events;
import 'state.dart' as home_state;

class HomeBloc extends Bloc<home_events.HomeEvent, home_state.HomeState> {
  final FriendsRepository _friendsRepository;

  HomeBloc(this._friendsRepository) : super(const home_state.HomeState()) {
    on<home_events.PageLoaded>((final event, final emit) async {
      await _friendsRepository.init();

      emit(state.copyWith(
        friends: () => _friendsRepository.getFriends(),
      ));
    });
    on<home_events.RemoveFriend>((final event, final emit) async {
      if (!await _friendsRepository.removeFriend(event.friend)) {
        emit(state.copyWith(
          snackBarMessage: () =>
              home_state.SnackBarMessage.failedToRemoveFriend,
        ));

        return;
      }

      emit(state.copyWith(
        friends: () => List.of(
            state.friends.where((final element) => element != event.friend)),
      ));
    });
    on<home_events.CopyFriendInformation>((final event, final emit) async {
      await Clipboard.setData(ClipboardData(
        text: jsonEncode(event.friend.toMap()),
      ));

      emit(state.copyWith(
        snackBarMessage: () =>
            home_state.SnackBarMessage.friendInformationCopied,
      ));
    });
    on<home_events.SetActionState>(
      (final event, final emit) => emit(state.copyWith(
        actionState: () =>
            state.actionState == event.state ? null : event.state,
      )),
    );
    on<home_events.CopyFriendString>((final event, final emit) async {
      await Clipboard.setData(ClipboardData(
        text: base64Encode(
          utf8.encode(
            jsonEncode({
              Settings.uuid.key: Settings.uuid.value,
              Settings.name.key: Settings.name.value,
            }),
          ),
        ),
      ));

      emit(state.copyWith(
        snackBarMessage: () => home_state.SnackBarMessage.friendStringCopied,
      ));
    });
    on<home_events.AddFriendFromString>((final event, final emit) async {
      Friend friend;

      try {
        friend = Friend.fromMap(
          jsonDecode(
            utf8.decode(
              base64Decode(
                (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? 'e30=',
              ),
              allowMalformed: true,
            ),
          ),
        );
      } on FormatException catch (_) {
        friend = Friend();
      }

      await _friendsRepository.addFriend(friend);

      emit(
        state.copyWith(friends: () => List.from(state.friends)..add(friend)),
      );
    });
  }
}

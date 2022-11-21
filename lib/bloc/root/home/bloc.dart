import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/friends_repository.dart';
import 'events.dart' as home_events;
import 'state.dart' as home_state;

class HomeBloc extends Bloc<home_events.HomeEvent, home_state.HomeState> {
  final FriendsRepository _friendsRepository;

  HomeBloc(this._friendsRepository) : super(const home_state.HomeState()) {
    on<home_events.PageLoaded>((event, emit) async {
      await _friendsRepository.init();

      emit(state.copyWith(
        friends: () => _friendsRepository.getFriends(),
      ));
    });
    on<home_events.RemoveFriend>((event, emit) {
      _friendsRepository.removeFriend(event.friend);

      emit(state.copyWith(
        friends: () =>
            List.of(state.friends.where((element) => element != event.friend)),
      ));
    });
    on<home_events.OpenDiscoveryDialog>((event, emit) => emit(state.copyWith(
          discoveryState: () => home_state.DiscoveryState.selectingMode,
        )));
    on<home_events.SetDiscoveryState>((event, emit) async {
      emit(state.copyWith(
        discoveryState: () => event.discoveryState,
      ));

      if (event.discoveryState == home_state.DiscoveryState.beingDiscovered) {
        String? discoveryCode = await _friendsRepository.goOnline();

        log('Went online, received discovery code: $discoveryCode');

        emit(state.copyWith(discoveryCode: () => discoveryCode));
      }
    });
    on<home_events.CopyDiscoveryCode>((event, emit) {
      Clipboard.setData(ClipboardData(text: state.discoveryCode));

      emit(state.copyWith(discoveryCodeCopiedTrigger: () => true));
      emit(state.copyWith(discoveryCodeCopiedTrigger: () => false));
    });
    on<home_events.ClosedDiscoveryDialog>((event, emit) async {
      if (state.discoveryCode != null) {
        bool? wentOffline = await _friendsRepository.goOffline();

        log(wentOffline == null
            ? 'Unknown status when going offline'
            : wentOffline
                ? 'Went offline'
                : 'Error going offline');
      }

      emit(state.copyWith(
        discoveryState: () => null,
        discoveryCode: () => null,
      ));
    });
    /*on<home_events.AddFriend>((event, emit) {
      Friend newFriend = const Friend(uuid: "123", name: "abs");

      _friendsRepository.addFriend(newFriend);

      emit(
        state.copyWith(friends: () => List.from(state.friends)..add(newFriend)),
      );
    });*/
  }
}

import '../../../data/friends_repository.dart';

class HomeState {
  final List<Friend> friends;
  final DiscoveryState? discoveryState;
  final String? discoveryCode;
  final bool discoveryCodeCopiedTrigger;

  const HomeState({
    this.friends = const [],
    this.discoveryState,
    this.discoveryCode,
    this.discoveryCodeCopiedTrigger = false,
  });

  HomeState copyWith({
    List<Friend> Function()? friends,
    DiscoveryState? Function()? discoveryState,
    String? Function()? discoveryCode,
    bool Function()? discoveryCodeCopiedTrigger,
  }) =>
      HomeState(
        friends: friends == null ? this.friends : friends.call(),
        discoveryState: discoveryState == null
            ? this.discoveryState
            : discoveryState.call(),
        discoveryCode:
            discoveryCode == null ? this.discoveryCode : discoveryCode.call(),
        discoveryCodeCopiedTrigger: discoveryCodeCopiedTrigger == null
            ? this.discoveryCodeCopiedTrigger
            : discoveryCodeCopiedTrigger.call(),
      );
}

enum DiscoveryState {
  selectingMode,
  addingFriend,
  beingDiscovered,
}

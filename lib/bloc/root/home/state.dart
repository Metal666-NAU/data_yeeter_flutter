import '../../../data/friends_repository.dart';

class HomeState {
  final List<Friend> friends;
  final ActionState? actionState;
  final String? discoveryCode;
  final SnackBarMessage? snackBarMessage;

  const HomeState({
    this.friends = const [],
    this.actionState,
    this.discoveryCode,
    this.snackBarMessage,
  });

  HomeState copyWith({
    final List<Friend> Function()? friends,
    final ActionState? Function()? actionState,
    final String? Function()? discoveryCode,
    final SnackBarMessage Function()? snackBarMessage,
  }) =>
      HomeState(
        friends: friends == null ? this.friends : friends.call(),
        actionState:
            actionState == null ? this.actionState : actionState.call(),
        discoveryCode:
            discoveryCode == null ? this.discoveryCode : discoveryCode.call(),
        snackBarMessage: snackBarMessage?.call(),
      );
}

enum SnackBarMessage {
  friendStringCopied,
  failedToRemoveFriend,
  friendInformationCopied,
}

enum ActionState {
  friendsTab,
  settingsTab,
}

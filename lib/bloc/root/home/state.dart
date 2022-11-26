import '../../../data/friends_repository.dart';

class HomeState {
  final List<Friend> friends;
  final ActionState? actionState;
  final String? discoveryCode;
  final SnackBarMessage? snackBarMessage;
  final FileTransferState? fileTransferState;
  final String? serverAddress;
  final String defaultServerAddress;

  const HomeState({
    this.friends = const [],
    this.actionState,
    this.discoveryCode,
    this.snackBarMessage,
    this.fileTransferState,
    this.serverAddress,
    required this.defaultServerAddress,
  });

  HomeState copyWith({
    final List<Friend> Function()? friends,
    final ActionState? Function()? actionState,
    final String? Function()? discoveryCode,
    final SnackBarMessage Function()? snackBarMessage,
    final FileTransferState? Function()? fileTransferState,
    final String? Function()? serverAddress,
    final String Function()? defaultServerAddress,
  }) =>
      HomeState(
        friends: friends == null ? this.friends : friends.call(),
        actionState:
            actionState == null ? this.actionState : actionState.call(),
        discoveryCode:
            discoveryCode == null ? this.discoveryCode : discoveryCode.call(),
        snackBarMessage: snackBarMessage?.call(),
        fileTransferState: fileTransferState == null
            ? this.fileTransferState
            : fileTransferState.call(),
        serverAddress:
            serverAddress == null ? this.serverAddress : serverAddress.call(),
        defaultServerAddress: defaultServerAddress == null
            ? this.defaultServerAddress
            : defaultServerAddress.call(),
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

class FileTransferState {
  final String targetUserUUID;
  final bool sendOrReceive;
  final bool started;
  final double progress;

  const FileTransferState({
    required this.targetUserUUID,
    required this.sendOrReceive,
    this.started = false,
    this.progress = 0,
  });

  FileTransferState copyWith({
    final String Function()? targetUserUUID,
    final bool Function()? sendOrReceive,
    final bool Function()? started,
    final double Function()? progress,
  }) =>
      FileTransferState(
        targetUserUUID: targetUserUUID == null
            ? this.targetUserUUID
            : targetUserUUID.call(),
        sendOrReceive:
            sendOrReceive == null ? this.sendOrReceive : sendOrReceive.call(),
        started: started == null ? this.started : started.call(),
        progress: progress == null ? this.progress : progress.call(),
      );
}

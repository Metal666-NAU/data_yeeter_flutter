import '../../../data/friends_repository.dart';

class HomeState {
  final List<Friend> friends;
  final ActionState? actionState;
  final String? discoveryCode;
  final SnackBarMessage? snackBarMessage;
  final FileTransferState? fileTransferState;
  final String? name;
  final String defaultName;
  final String? serverAddress;
  final String defaultServerAddress;

  const HomeState({
    this.friends = const [],
    this.actionState,
    this.discoveryCode,
    this.snackBarMessage,
    this.fileTransferState,
    this.name,
    required this.defaultName,
    this.serverAddress,
    required this.defaultServerAddress,
  });

  HomeState copyWith({
    final List<Friend> Function()? friends,
    final ActionState? Function()? actionState,
    final String? Function()? discoveryCode,
    final SnackBarMessage Function()? snackBarMessage,
    final FileTransferState? Function()? fileTransferState,
    final String? Function()? name,
    final String Function()? defaultName,
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
        name: name == null ? this.name : name.call(),
        defaultName:
            defaultName == null ? this.defaultName : defaultName.call(),
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
  final String otherUserUuid;
  final bool sendOrReceive;
  final FileInfo? fileInfo;

  const FileTransferState({
    required this.otherUserUuid,
    required this.sendOrReceive,
    this.fileInfo,
  });

  FileTransferState copyWith({
    final String Function()? otherUserUuid,
    final bool Function()? sendOrReceive,
    final FileInfo? Function()? fileInfo,
  }) =>
      FileTransferState(
        otherUserUuid:
            otherUserUuid == null ? this.otherUserUuid : otherUserUuid.call(),
        sendOrReceive:
            sendOrReceive == null ? this.sendOrReceive : sendOrReceive.call(),
        fileInfo: fileInfo == null ? this.fileInfo : fileInfo.call(),
      );
}

class FileInfo {
  final String name;
  final String path;

  final int? size;
  final int? bytesTransferred;

  FileInfo({
    required this.name,
    required this.path,
    this.size,
    this.bytesTransferred,
  });

  FileInfo copyWith({
    final String Function()? name,
    final String Function()? path,
    final int? Function()? size,
    final int? Function()? bytesTransferred,
  }) =>
      FileInfo(
        name: name == null ? this.name : name.call(),
        path: path == null ? this.path : path.call(),
        size: size == null ? this.size : size.call(),
        bytesTransferred: bytesTransferred == null
            ? this.bytesTransferred
            : bytesTransferred.call(),
      );
}

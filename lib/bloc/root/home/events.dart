import '../../../data/friends_repository.dart';
import 'state.dart';

abstract class HomeEvent {
  const HomeEvent();
}

class PageLoaded extends HomeEvent {
  const PageLoaded();
}

class PrepareFileTransfer extends HomeEvent {
  final Friend friend;

  const PrepareFileTransfer(this.friend);
}

class StartFileTransfer extends HomeEvent {
  const StartFileTransfer();
}

class FileTransferProgress extends HomeEvent {
  final double progress;

  const FileTransferProgress(this.progress);
}

class ReceiveFile extends HomeEvent {
  final Friend friend;

  const ReceiveFile(this.friend);
}

class CancelFileTransfer extends HomeEvent {
  const CancelFileTransfer();
}

class RemoveFriend extends HomeEvent {
  final Friend friend;

  const RemoveFriend(this.friend);
}

class CopyFriendInformation extends HomeEvent {
  final Friend friend;

  const CopyFriendInformation(this.friend);
}

class SetActionState extends HomeEvent {
  final ActionState state;

  const SetActionState(this.state);
}

class CopyFriendString extends HomeEvent {
  const CopyFriendString();
}

class AddFriendFromString extends HomeEvent {
  const AddFriendFromString();
}

class SetServerAddress extends HomeEvent {
  final String? address;

  const SetServerAddress(this.address);
}

class SaveServerAddress extends HomeEvent {
  const SaveServerAddress();
}

import '../../../data/friends_repository.dart';
import 'state.dart';

abstract class HomeEvent {
  const HomeEvent();
}

class PageLoaded extends HomeEvent {
  const PageLoaded();
}

class StartFileTransfer extends HomeEvent {
  final Friend friend;

  const StartFileTransfer(this.friend);
}

class ReceiveFileChunk extends HomeEvent {
  final List<int> chunk;

  const ReceiveFileChunk(this.chunk);
}

class ReceiveFile extends HomeEvent {
  final Friend friend;

  const ReceiveFile(this.friend);
}

class SetIncomingFileInfo extends HomeEvent {
  final String fileName;
  final int fileSize;

  const SetIncomingFileInfo(
    this.fileName,
    this.fileSize,
  );
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

class SetName extends HomeEvent {
  final String? name;

  const SetName(this.name);
}

class SaveName extends HomeEvent {
  const SaveName();
}

class SetServerAddress extends HomeEvent {
  final String? address;

  const SetServerAddress(this.address);
}

class SaveServerAddress extends HomeEvent {
  const SaveServerAddress();
}

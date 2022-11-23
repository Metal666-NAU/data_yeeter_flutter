import '../../../data/friends_repository.dart';
import 'state.dart';

abstract class HomeEvent {
  const HomeEvent();
}

class PageLoaded extends HomeEvent {
  const PageLoaded();
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

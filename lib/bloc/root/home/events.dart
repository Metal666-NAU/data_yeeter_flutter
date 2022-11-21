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

class OpenDiscoveryDialog extends HomeEvent {
  const OpenDiscoveryDialog();
}

class SetDiscoveryState extends HomeEvent {
  final DiscoveryState discoveryState;

  const SetDiscoveryState(this.discoveryState);
}

class CopyDiscoveryCode extends HomeEvent {
  const CopyDiscoveryCode();
}

class ClosedDiscoveryDialog extends HomeEvent {
  const ClosedDiscoveryDialog();
}

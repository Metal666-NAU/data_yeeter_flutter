import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/root/home/bloc.dart';
import '../bloc/root/home/events.dart';
import '../bloc/root/home/state.dart';
import '../data/friends_repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => _mainPanel(
        friendItemBuilder: (friend) => _friendItemBuilder(
          friend: friend,
          receiveFileButton: _receiveFileButton,
          extraActionsButton: () => _extraActionsButton(
            context,
            friend,
          ),
        ),
        bottomPanel: _bottomPanel(
          context,
          _actionButton,
        ),
      );

  Widget _mainPanel({
    required Widget Function(Friend) friendItemBuilder,
    Widget? bottomPanel,
  }) =>
      Scaffold(
        body: BlocListener<HomeBloc, HomeState>(
          listenWhen: (previous, current) =>
              previous.snackBarMessage != current.snackBarMessage &&
              current.snackBarMessage != null,
          listener: (context, state) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(() {
            switch (state.snackBarMessage) {
              case SnackBarMessage.friendStringCopied:
                {
                  return 'Code copied to clipboard!';
                }
              case SnackBarMessage.failedToRemoveFriend:
                {
                  return 'Failed to remove friend!';
                }
              case SnackBarMessage.friendInformationCopied:
                {
                  return 'Information copied to clipboard!';
                }
              default:
                {
                  return 'unknown message???';
                }
            }
          }()))),
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<HomeBloc, HomeState>(
                  buildWhen: (previous, current) =>
                      previous.friends != current.friends,
                  builder: (context, state) => ListView.builder(
                    itemBuilder: (context, index) => friendItemBuilder(
                      state.friends[index],
                    ),
                    itemCount: state.friends.length,
                  ),
                ),
              ),
              if (bottomPanel != null) bottomPanel,
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      );

  Widget _friendItemBuilder({
    required Friend friend,
    Widget Function([bool disable])? receiveFileButton,
    Widget Function()? extraActionsButton,
  }) =>
      ListTile(
        title: Text(friend.name ?? ''),
        subtitle: friend.uuid != null
            ? null
            : const Text('Error: user doesn\'t have a UUID.'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            receiveFileButton?.call(friend.uuid == null),
            extraActionsButton?.call(),
          ].where((element) => element != null).cast<Widget>().toList(),
        ),
      );

  Widget _receiveFileButton([bool disable = false]) => ElevatedButton(
        onPressed: disable ? null : () {},
        child: const Text('Receive File'),
      );

  Widget _extraActionsButton(
    BuildContext context,
    Friend friend,
  ) =>
      PopupMenuButton<ExtraFriendActions>(
        itemBuilder: (context) => ExtraFriendActions.values
            .map((action) => PopupMenuItem<ExtraFriendActions>(
                  value: action,
                  child: Text(action.label),
                ))
            .toList(),
        onSelected: (value) {
          switch (value) {
            case ExtraFriendActions.remove:
              {
                context.read<HomeBloc>().add(RemoveFriend(friend));

                break;
              }
            case ExtraFriendActions.copyInformation:
              {
                context.read<HomeBloc>().add(CopyFriendInformation(friend));

                break;
              }
          }
        },
        child: const Icon(Icons.more_vert),
      );

  Widget _bottomPanel(
    BuildContext context,
    Widget Function(
      BuildContext context,
      void Function() onPressed,
      IconData iconData,
      String labelText, [
      bool selected,
    ])
        actionButton,
  ) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: MediaQuery.of(context).size.width <= 500 ? 1 : 0,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width <= 500
                    ? double.infinity
                    : 500,
              ),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: BlocBuilder<HomeBloc, HomeState>(
                    buildWhen: (previous, current) =>
                        previous.actionState != current.actionState,
                    builder: (context, state) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: actionButton(
                                context,
                                () => context.read<HomeBloc>().add(
                                    const SetActionState(
                                        ActionState.friendsTab)),
                                Icons.people,
                                'Friends',
                                state.actionState == ActionState.friendsTab,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: actionButton(
                                context,
                                () => context.read<HomeBloc>().add(
                                    const SetActionState(
                                        ActionState.settingsTab)),
                                Icons.settings,
                                'Settings',
                                state.actionState == ActionState.settingsTab,
                              ),
                            ),
                          ],
                        ),
                        if (state.actionState == ActionState.friendsTab)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              actionButton(
                                context,
                                () => context
                                    .read<HomeBloc>()
                                    .add(const CopyFriendString()),
                                Icons.code,
                                'Copy Friend String',
                              ),
                              actionButton(
                                context,
                                () => context
                                    .read<HomeBloc>()
                                    .add(const AddFriendFromString()),
                                Icons.person_add,
                                'Add friend from copied string',
                              ),
                            ],
                          )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );

  Widget _actionButton(
    BuildContext context,
    void Function() onPressed,
    IconData iconData,
    String labelText, [
    bool selected = false,
  ]) =>
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: selected
              ? Theme.of(context).colorScheme.primary
              : ElevationOverlay.applyOverlay(
                  context,
                  Theme.of(context).cardColor,
                  2,
                ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                iconData,
                color:
                    !selected ? null : Theme.of(context).colorScheme.onPrimary,
              ),
              Text(
                labelText,
                style: !selected
                    ? null
                    : TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
              ),
            ],
          ),
        ),
      );
}

enum ExtraFriendActions {
  remove('Remove'),
  copyInformation('Copy Information');

  final String label;

  const ExtraFriendActions(this.label);
}

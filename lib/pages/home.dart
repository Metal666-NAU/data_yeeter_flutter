import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../bloc/root/home/bloc.dart';
import '../bloc/root/home/events.dart';
import '../bloc/root/home/state.dart';
import '../data/friends_repository.dart';

class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(final BuildContext context) {
    final TextEditingController serverAddressController =
        useTextEditingController();

    return _mainPanel(
      friendItemBuilder: (final friend) => _friendItemBuilder(
        friend: friend,
        sendFileButton: ([final disable = false]) => _sendFileButton(
          context,
          friend,
          disable,
        ),
        receiveFileButton: ([final disable = false]) => _receiveFileButton(
          context,
          friend,
          disable,
        ),
        cancelTransferButton: () => _cancelTransferButton(context),
        extraActionsButton: () => _extraActionsButton(
          context,
          friend,
        ),
      ),
      sendDialogBuilder: _sendDialogBuilder,
      bottomPanel: _bottomPanel(
        context,
        _actionButton,
        () => _friendsTab(context),
        (
          final serverAddress,
          final defaultServerAddress,
        ) =>
            _settingsTab(
          context,
          serverAddressController..text = serverAddress ?? '',
          defaultServerAddress,
        ),
      ),
    );
  }

  Widget _mainPanel({
    required final Widget Function(Friend friend) friendItemBuilder,
    required final AlertDialog Function(BuildContext context) sendDialogBuilder,
    final Widget? bottomPanel,
  }) =>
      Scaffold(
        body: MultiBlocListener(
          listeners: [
            BlocListener<HomeBloc, HomeState>(
              listenWhen: (final previous, final current) =>
                  previous.snackBarMessage != current.snackBarMessage &&
                  current.snackBarMessage != null,
              listener: (final context, final state) =>
                  ScaffoldMessenger.of(context)
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
            ),
            BlocListener<HomeBloc, HomeState>(
              listenWhen: (final previous, final current) =>
                  previous.fileTransferState == null &&
                  current.fileTransferState != null,
              listener: (final context, final state) async =>
                  context.read<HomeBloc>().add(await showDialog<bool>(
                            context: context,
                            builder: sendDialogBuilder,
                          ) ??
                          false
                      ? const StartFileTransfer()
                      : const CancelFileTransfer()),
            ),
          ],
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<HomeBloc, HomeState>(
                  buildWhen: (final previous, final current) =>
                      previous.friends != current.friends,
                  builder: (final context, final state) => ListView.builder(
                    itemBuilder: (final context, final index) =>
                        friendItemBuilder(
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
    required final Friend friend,
    final Widget Function([
      bool disable,
    ])?
        sendFileButton,
    final Widget Function([
      bool disable,
    ])?
        receiveFileButton,
    final Widget Function()? cancelTransferButton,
    final Widget Function()? extraActionsButton,
  }) =>
      ListTile(
        title: Text(friend.name ?? ''),
        subtitle: friend.uuid != null
            ? null
            : const Text('Error: user doesn\'t have a UUID.'),
        trailing: BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (final previous, final current) =>
              previous.fileTransferState != current.fileTransferState,
          builder: (final context, final state) {
            final bool transfering = state.fileTransferState != null;

            final bool disableActions = friend.uuid == null || transfering;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: (!transfering ||
                          !(friend.uuid ==
                              state.fileTransferState!.targetUserUUID)
                      ? [
                          sendFileButton?.call(disableActions),
                          receiveFileButton?.call(disableActions),
                          extraActionsButton?.call(),
                        ]
                      : [
                          cancelTransferButton?.call(),
                        ])
                  .where((final element) => element != null)
                  .cast<Widget>()
                  .toList(),
            );
          },
        ),
      );

  AlertDialog _sendDialogBuilder(final BuildContext context) => AlertDialog(
        title: const Text('Ready to send?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
        ],
      );

  Widget _sendFileButton(
    final BuildContext context,
    final Friend friend,
    final bool disable,
  ) =>
      ElevatedButton(
        onPressed: disable
            ? null
            : () => context.read<HomeBloc>().add(PrepareFileTransfer(friend)),
        child: const Text('Send'),
      );

  Widget _receiveFileButton(
    final BuildContext context,
    final Friend friend, [
    final bool disable = false,
  ]) =>
      ElevatedButton(
        onPressed: disable
            ? null
            : () => context.read<HomeBloc>().add(ReceiveFile(friend)),
        child: const Text('Receive'),
      );

  Widget _cancelTransferButton(final BuildContext context) => ElevatedButton(
        onPressed: () =>
            context.read<HomeBloc>().add(const CancelFileTransfer()),
        child: const Text('Cancel Transfer'),
      );

  Widget _extraActionsButton(
    final BuildContext context,
    final Friend friend,
  ) =>
      PopupMenuButton<ExtraFriendActions>(
        itemBuilder: (final context) => ExtraFriendActions.values
            .map((final action) => PopupMenuItem<ExtraFriendActions>(
                  value: action,
                  child: Text(action.label),
                ))
            .toList(),
        onSelected: (final value) {
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
    final BuildContext context,
    final Widget Function(
      BuildContext context,
      void Function() onPressed,
      IconData iconData,
      String labelText, [
      bool selected,
    ])
        actionButton,
    final Widget Function() friendsTab,
    final Widget Function(
      String? serverAddress,
      String defaultServerAddress,
    )
        settingsTab,
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
                    buildWhen: (final previous, final current) =>
                        previous.actionState != current.actionState,
                    builder: (final context, final state) => Column(
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
                          friendsTab(),
                        if (state.actionState == ActionState.settingsTab)
                          settingsTab(
                            state.serverAddress,
                            state.defaultServerAddress,
                          ),
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
    final BuildContext context,
    final void Function() onPressed,
    final IconData iconData,
    final String labelText, [
    final bool selected = false,
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

  Widget _friendsTab(final BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: () =>
                context.read<HomeBloc>().add(const CopyFriendString()),
            icon: const Icon(Icons.code),
            label: const Text('Copy Friend String'),
          ),
          ElevatedButton.icon(
            onPressed: () =>
                context.read<HomeBloc>().add(const AddFriendFromString()),
            icon: const Icon(Icons.person_add),
            label: const Text('Add friend from copied string'),
          ),
        ],
      );

  Widget _settingsTab(
    final BuildContext context,
    final TextEditingController serverAddressController,
    final String defaultServerAddress,
  ) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: serverAddressController,
                  decoration: InputDecoration(hintText: defaultServerAddress),
                  onChanged: (final value) =>
                      context.read<HomeBloc>().add(SetServerAddress(value)),
                ),
              ),
              ElevatedButton(
                onPressed: () =>
                    context.read<HomeBloc>().add(const SaveServerAddress()),
                child: const Text('Save'),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () =>
                context.read<HomeBloc>().add(const AddFriendFromString()),
            icon: const Icon(Icons.person_add),
            label: const Text('Add friend from copied string'),
          ),
        ],
      );
}

enum ExtraFriendActions {
  remove('Remove'),
  copyInformation('Copy Information');

  final String label;

  const ExtraFriendActions(this.label);
}

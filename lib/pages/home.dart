import 'package:data_yeeter_flutter/bloc/root/home/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/root/home/bloc.dart';
import '../bloc/root/home/state.dart';
import '../data/friends_repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => _mainPanel(
        friendItemBuilder: (friend) => _friendItemBuilder(
          friend: friend,
          receiveFileButton: _receiveFileButton,
          extraActionsButton: () => _extraActionsButton(context, friend),
        ),
        discoveryFab: _discoveryFab(context),
        bottomPanel: _bottomPanel(),
        discoveryBottomSheet: (context) => _discoveryBottomSheet(
          context,
          _discoveryStateButton,
        ),
      );

  Widget _mainPanel({
    required Widget Function(Friend) friendItemBuilder,
    Widget? discoveryFab,
    Widget? bottomPanel,
    Widget Function(BuildContext context)? discoveryBottomSheet,
  }) =>
      BlocListener<HomeBloc, HomeState>(
        listenWhen: (previous, current) =>
            previous.discoveryState == null && current.discoveryState != null,
        listener: (context, state) async {
          if (discoveryBottomSheet == null) {
            return;
          }

          await showModalBottomSheet(
            context: context,
            builder: (_) => BlocProvider.value(
              value: context.read<HomeBloc>(),
              child: discoveryBottomSheet(context),
            ),
          ).whenComplete(() =>
              context.read<HomeBloc>().add(const ClosedDiscoveryDialog()));
        },
        child: Scaffold(
          body: Column(
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
            ],
          ),
          floatingActionButton: discoveryFab,
          bottomNavigationBar: bottomPanel,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        ),
      );

  Widget _friendItemBuilder({
    required Friend friend,
    Widget Function()? receiveFileButton,
    Widget Function()? extraActionsButton,
  }) =>
      ListTile(
        title: Text(friend.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            receiveFileButton?.call(),
            extraActionsButton?.call(),
          ].where((element) => element != null).cast<Widget>().toList(),
        ),
      );

  Widget _receiveFileButton() => ElevatedButton(
        onPressed: () {},
        child: const Text('Receive File'),
      );

  Widget _extraActionsButton(
    BuildContext context,
    Friend friend,
  ) =>
      PopupMenuButton<ExtraFriendActions>(
        itemBuilder: (context) => [
          const PopupMenuItem<ExtraFriendActions>(
            value: ExtraFriendActions.remove,
            child: Text('Remove'),
          )
        ],
        onSelected: (value) {
          switch (value) {
            case ExtraFriendActions.remove:
              {
                context.read<HomeBloc>().add(RemoveFriend(friend));

                break;
              }
          }
        },
        child: const Icon(Icons.more_vert),
      );

  Widget _discoveryFab(BuildContext context) => FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () =>
            context.read<HomeBloc>().add(const OpenDiscoveryDialog()),
        child: const Icon(Icons.person_add),
      );

  Widget _bottomPanel() => const BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: SizedBox(
          height: 40,
        ),
      );

  Widget _discoveryBottomSheet(
    BuildContext context,
    Widget Function(
      BuildContext context,
      DiscoveryState discoveryState,
    )
        discoveryStateButton,
  ) =>
      BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (previous, current) =>
            previous.discoveryState != current.discoveryState,
        builder: (context, state) {
          switch (state.discoveryState) {
            case DiscoveryState.selectingMode:
              {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    discoveryStateButton(
                      context,
                      DiscoveryState.beingDiscovered,
                    ),
                    discoveryStateButton(
                      context,
                      DiscoveryState.addingFriend,
                    ),
                  ],
                );
              }
            case DiscoveryState.beingDiscovered:
              {
                return BlocConsumer<HomeBloc, HomeState>(
                  listenWhen: (previous, current) =>
                      !previous.discoveryCodeCopiedTrigger &&
                      current.discoveryCodeCopiedTrigger,
                  listener: (context, state) => ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(
                          content: Text('Code copied to clipboard!'))),
                  buildWhen: (previous, current) =>
                      previous.discoveryCode != current.discoveryCode,
                  builder: (context, state) => state.discoveryCode == null
                      ? const Center(
                          child: Text('Retrieving your code...'),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Your code is:'),
                            Text(state.discoveryCode!),
                            TextButton.icon(
                              onPressed: () => context
                                  .read<HomeBloc>()
                                  .add(const CopyDiscoveryCode()),
                              icon: const Icon(Icons.content_paste),
                              label: const Text('Copy'),
                            )
                          ],
                        ),
                );
              }
            default:
              {
                return const Text('ERROR');
              }
          }
        },
      );

  Widget _discoveryStateButton(
    BuildContext context,
    DiscoveryState discoveryState,
  ) =>
      Padding(
        padding: const EdgeInsets.all(24),
        child: ElevatedButton.icon(
          onPressed: () =>
              context.read<HomeBloc>().add(SetDiscoveryState(discoveryState)),
          icon: Icon(() {
            switch (discoveryState) {
              case DiscoveryState.addingFriend:
                {
                  return Icons.person_search;
                }
              case DiscoveryState.beingDiscovered:
                {
                  return Icons.code;
                }
              case DiscoveryState.selectingMode:
                break;
            }
          }()),
          label: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(() {
              switch (discoveryState) {
                case DiscoveryState.addingFriend:
                  {
                    return 'Add friend';
                  }
                case DiscoveryState.beingDiscovered:
                  {
                    return 'Generate code';
                  }
                default:
                  {
                    return 'ERROR';
                  }
              }
            }()),
          ),
        ),
      );
}

enum ExtraFriendActions {
  remove;
}

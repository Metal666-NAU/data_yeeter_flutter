import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/root/bloc.dart';
import '../bloc/root/home/bloc.dart';
import '../bloc/root/home/events.dart';
import '../bloc/root/state.dart';
import '../data/friends_repository.dart';
import '../pages/home.dart';
import '../pages/startup.dart';

class Root extends StatelessWidget {
  final FriendsRepository _friendsRepository = FriendsRepository();

  Root({super.key});

  @override
  Widget build(BuildContext context) => _mainPanel(
        friendsPage: _friendsPage,
        defaultPage: _startupPage,
      );

  BlocBuilder<RootBloc, RootState> _mainPanel({
    required Widget Function() friendsPage,
    required Widget Function() defaultPage,
  }) =>
      BlocBuilder<RootBloc, RootState>(
        buildWhen: (previous, current) =>
            previous.runtimeType != current.runtimeType,
        builder: (context, state) => SafeArea(
          child: () {
            switch (state.runtimeType) {
              case Home:
                return friendsPage();
              default:
                return defaultPage();
            }
          }(),
        ),
      );

  Widget _friendsPage() => RepositoryProvider.value(
        value: _friendsRepository,
        child: BlocProvider(
          create: (context) =>
              HomeBloc(_friendsRepository)..add(const PageLoaded()),
          child: const HomePage(),
        ),
      );

  Widget _startupPage() => const StartupPage();
}

import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'bloc/root/bloc.dart' as root_bloc;
import 'bloc/root/events.dart' as root_events;
import 'bloc/root/home/bloc.dart' as home_bloc;
import 'bloc/root/home/events.dart' as home_events;
import 'data/fileshare_repository.dart';
import 'data/friends_repository.dart';
import 'pages/home.dart';
import 'pages/startup.dart';

void main() async {
  final FileShareRepository fileShareRepository = FileShareRepository();
  final FriendsRepository friendsRepository = FriendsRepository();

  final GoRouter goRouter = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (final context, final state) => const StartupPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (final context, final state) => MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(
              value: fileShareRepository,
            ),
            RepositoryProvider.value(
              value: friendsRepository,
            ),
          ],
          child: BlocProvider(
            create: (final context) => home_bloc.HomeBloc(
              fileShareRepository,
              friendsRepository,
            )..add(const home_events.PageLoaded()),
            child: const HomePage(),
          ),
        ),
      ),
    ],
  );

  if (Platform.isWindows) {
    await DesktopWindow.setMinWindowSize(const Size(300, 250));
  }

  runApp(MyApp(router: goRouter));
}

class MyApp extends StatelessWidget {
  final RouterConfig<Object> router;

  const MyApp({
    super.key,
    required this.router,
  });

  @override
  Widget build(final BuildContext context) => BlocProvider(
        create: (final context) =>
            root_bloc.RootBloc()..add(root_events.Startup()),
        child: MaterialApp.router(
          title: 'DataYeeter',
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.deepPurple,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.deepPurple.shade300,
            brightness: Brightness.dark,
          ),
          routerConfig: router,
        ),
      );
}

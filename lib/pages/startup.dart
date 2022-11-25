import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/root/bloc.dart' as root_bloc;
import '../bloc/root/state.dart' as root_state;

class StartupPage extends StatelessWidget {
  const StartupPage({super.key});

  @override
  Widget build(final BuildContext context) =>
      BlocListener<root_bloc.RootBloc, root_state.RootState>(
        listenWhen: (final previous, final current) =>
            current is root_state.Home,
        listener: (final context, final state) => context.go('/home'),
        child: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
}

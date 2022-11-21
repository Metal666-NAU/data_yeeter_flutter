import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/root/bloc.dart' as root_bloc;
import '../bloc/root/state.dart' as root_state;

class StartupPage extends StatelessWidget {
  const StartupPage({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocListener<root_bloc.RootBloc, root_state.RootState>(
        listenWhen: (previous, current) => current is root_state.Home,
        listener: (context, state) => context.go('/home'),
        child: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
}

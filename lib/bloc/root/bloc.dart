import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/settings.dart';
import 'events.dart' as root_events;
import 'state.dart' as root_state;

class RootBloc extends Bloc<root_events.RootEvent, root_state.RootState> {
  RootBloc() : super(const root_state.Startup()) {
    on<root_events.Startup>((final event, final emit) async {
      await Hive.initFlutter();
      await Settings.init();

      emit(const root_state.Home());
    });
  }
}

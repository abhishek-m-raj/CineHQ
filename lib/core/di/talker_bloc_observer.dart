import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker_flutter/talker_flutter.dart';

class TalkerBlocObserver extends BlocObserver {
  final Talker talker;

  TalkerBlocObserver(this.talker);

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    talker.info('BLOC CREATE: ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    talker.info('BLOC EVENT: ${bloc.runtimeType} -> $event');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    talker.info(
      'BLOC TRANSITION: ${bloc.runtimeType}\n'
      '  Current state: ${transition.currentState.runtimeType}\n'
      '  Event: ${transition.event.runtimeType}\n'
      '  Next state: ${transition.nextState.runtimeType}',
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    talker.error('BLOC ERROR: ${bloc.runtimeType}', error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    talker.info('BLOC CLOSE: ${bloc.runtimeType}');
  }
}

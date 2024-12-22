import 'package:fultter_bloc_pattern/blocs/counter/counter_events.dart';
import 'package:fultter_bloc_pattern/blocs/counter/counter_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterBloc extends Bloc<CounterEvents, CounterState> {

  CounterBloc()
      : super(const CounterState(
            counterCurrentValue: 0, message: "Initial State")) {

    on<IncrementCounterEvent>((event, emit) {
      emit(CounterState(
          counterCurrentValue: state.counterCurrentValue + 1,
          message: "Counter value incremented by one"));
    });

    on<DecrementCounterEvent>((event, emit) {
      emit(CounterState(
          counterCurrentValue: state.counterCurrentValue - 1,
          message: "Counter is decremented by one"));
    });

    on<ResetCounterEvent>((event, emit) {
      emit(const CounterState(
          counterCurrentValue: 0, message: 'Reset to Zero!'));
    });
  }
}

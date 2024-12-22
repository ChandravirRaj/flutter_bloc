import 'package:fultter_bloc_pattern/blocs/counter/counter_events.dart';
import 'package:fultter_bloc_pattern/blocs/counter/counter_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterBloc extends Bloc<CounterEvents, CounterState> {
  CounterBloc()
      : super(const CounterState(
            counterCurrentValue: 0, message: "Initial State")) {
    on<IncrementCounterEvent>(_increment);
    on<DecrementCounterEvent>(_decrement);
    on<ResetCounterEvent>(_reset);
  }

  void _increment(IncrementCounterEvent event, Emitter emitter) {
    emitter(CounterState(
        counterCurrentValue: state.counterCurrentValue + 1,
        message: "Counter value incremented by one"));
  }

  void _decrement(DecrementCounterEvent event, Emitter emitter) {
    emitter(CounterState(
        counterCurrentValue: state.counterCurrentValue - 1,
        message: "Counter is decremented by one"));
  }

  void _reset(ResetCounterEvent event, Emitter emitter) {
    emitter(
        const CounterState(counterCurrentValue: 0, message: 'Reset to Zero!'));
  }
}

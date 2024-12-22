import 'package:equatable/equatable.dart';

class CounterState extends Equatable {
  final int counterCurrentValue;
  final String message;

  const CounterState({this.counterCurrentValue = 0, required this.message});

  CounterState copyWith({int? counter}) {
    return CounterState(
        counterCurrentValue: counter ?? counterCurrentValue, message: message);
  }

  @override
  List<Object?> get props => [counterCurrentValue, message];
}

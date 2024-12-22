import 'package:equatable/equatable.dart';

class CounterState extends Equatable {

  final int counterCurrentValue;
  final String message;

  const CounterState({required this.counterCurrentValue, required this.message});

  @override
  List<Object?> get props => [counterCurrentValue, message];
}

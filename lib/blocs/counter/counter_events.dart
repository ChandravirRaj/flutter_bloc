import 'package:equatable/equatable.dart';


// Base class for all events
abstract class CounterEvents extends Equatable {
  const CounterEvents();

  @override
  List<Object> get props => [];
}

// Increment Counter
class IncrementCounterEvent extends CounterEvents{}

// Decrement Counter
class DecrementCounterEvent extends CounterEvents{}

// Reset Counter
class ResetCounterEvent extends CounterEvents{}
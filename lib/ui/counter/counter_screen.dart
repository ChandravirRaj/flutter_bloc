import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fultter_bloc_pattern/blocs/counter/counter_bloc.dart';
import 'package:fultter_bloc_pattern/blocs/counter/counter_events.dart';
import 'package:fultter_bloc_pattern/blocs/counter/counter_states.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  @override
  Widget build(BuildContext context) {
    final counterBloc = context.read<CounterBloc>();

    print("--------------build-----------");
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Counter Example",
          style: TextStyle(
              fontWeight: FontWeight.w500, color: Colors.black, fontSize: 20),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.grey.shade200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BlocBuilder<CounterBloc, CounterState>(builder: (context, state) {
                return Text(
                  state.counterCurrentValue.toString(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.green,
                      fontSize: 80),
                );
              }),
              SizedBox(
                height: 60,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      counterBloc.add(IncrementCounterEvent());
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue, // Normal text color
                      side: const BorderSide(color: Colors.blue),
                    ).copyWith(
                      foregroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.hovered)) {
                            return Colors.red; // Change text color on hover
                          }
                          return Colors.blue;
                        },
                      ),
                    ),
                    child: const Text('Increment Counter'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      counterBloc.add(DecrementCounterEvent());
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue, // Normal text color
                      side: const BorderSide(color: Colors.blue),
                    ).copyWith(
                      foregroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.hovered)) {
                            return Colors.red; // Change text color on hover
                          }
                          return Colors.blue;
                        },
                      ),
                    ),
                    child: const Text('Decrement Counter'),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              OutlinedButton(
                onPressed: () {
                  counterBloc.add(ResetCounterEvent());
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue, // Normal text color
                  side: const BorderSide(color: Colors.blue),
                ).copyWith(
                  foregroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.hovered)) {
                        return Colors.red; // Change text color on hover
                      }
                      return Colors.blue;
                    },
                  ),
                ),
                child: const Text('Reset Counter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

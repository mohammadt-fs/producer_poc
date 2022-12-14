import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:producer_poc/counter_producer/counter_logic_producer.dart';
import 'package:producer_poc/counter_producer/counter_producer.dart';
import 'package:producer_poc/producer/producer_builder_widget.dart';
import 'package:producer_poc/producer_constructors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  // TODO(mohammad): is there another way to construct producers, so the widget ramains const?
  late final CounterLogicProducer _counterLogicProducer =
      ProducerConstructors.buildCounterLogicProducer();

  late final CounterProducer _counterProducer =
      ProducerConstructors.buildCounterSystem(_counterLogicProducer);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CounterProducer>.value(value: _counterProducer),
        BlocProvider<CounterLogicProducer>.value(value: _counterLogicProducer)
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(
          title: 'Flutter Demo Home Page',
        ),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

  const MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            // TODO(mohammad): ProducerBuilder API for handling error + loading + success in spearate builders.
            SizedBox(
              height: 35,
              child: ProducerBuilder<CounterProducer, CounterProducerOutput>(
                producer: context.read<CounterProducer>(),
                loadingBuilder: (
                  BuildContext context,
                  CounterProducerOutput? previousData,
                ) =>
                    const CircularProgressIndicator(),
                successBuilder: (
                  BuildContext context,
                  CounterProducerOutput data,
                ) =>
                    Text(
                  data.result.toString(),
                  style: Theme.of(context).textTheme.headline4,
                ),
                errorBuilder: (
                  BuildContext context,
                  String error,
                  CounterProducerOutput? previousData,
                ) =>
                    Text(error.toString()),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            FloatingActionButton(
              onPressed: () =>
                  context.read<CounterLogicProducer>().produceManually(
                        CounterLogicProducerOutput(logic: _incrementByOneLogic),
                      ),
              tooltip: 'Increment by 1',
              child: const Icon(Icons.add),
            ),
            FloatingActionButton(
              onPressed: () =>
                  context.read<CounterLogicProducer>().produceManually(
                        CounterLogicProducerOutput(logic: _multiplyByTwoLogic),
                      ),
              tooltip: 'Multiply by 2',
              child: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }

  int _incrementByOneLogic(int input) => input + 1;
  int _multiplyByTwoLogic(int input) => input * 2;
}

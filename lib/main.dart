import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './counter.dart';

void main() {
  final counter = Counter();
  runApp(
    MultiProvider(
      providers: [
        StreamProvider<int>(
          create: (_) => counter.countStream,
          initialData: 0,
        ),
        Provider.value(value: counter)
      ],
      child: const MaterialApp(
        title: 'Counter',
        home: HomeScreen(),
      ),
    ),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _periodController = TextEditingController();
  String pauseButtonText = 'pause';

  StreamSubscription<int>? subscription;
  @override
  Widget build(BuildContext context) {
    return Consumer2<Counter, int>(builder: (context, counter, rep, _) {
      return Scaffold(
        appBar: AppBar(title: const Text('Counter App')),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                  obscureText: false,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Count up to',
                  ),
                  controller: _repsController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                  obscureText: false,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'count period (seconds)',
                  ),
                  controller: _periodController,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      subscription?.cancel();
                      try {
                        counter.setParams(
                          reps: int.parse(_repsController.text),
                          period: (double.parse(_periodController.text) * 1000)
                              .round(),
                        );
                      } catch (_) {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: const Text('Incorrect inputs'),
                              actions: [
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('OK'))
                              ],
                            );
                          },
                        );
                        return;
                      }
                      subscription = counter.count().listen((n) {
                        if (n > counter.reps) {
                          counter.push(0);
                          subscription?.cancel();
                        } else {
                          counter.push(n);
                        }
                      });
                    },
                    child: const Text('start'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (subscription == null) return;
                      if (subscription!.isPaused) {
                        subscription!.resume();
                        setState(() {
                          pauseButtonText = 'pause';
                        });
                      } else {
                        subscription!.pause();
                        setState(() {
                          pauseButtonText = 'resume';
                        });
                      }
                    },
                    child: Text(pauseButtonText),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        'Current rep:',
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        rep.toString(),
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

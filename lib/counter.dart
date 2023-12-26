import 'dart:async';

class Counter {
  late int _reps;
  late int _period;

  final StreamController<int> controller = StreamController();
  Stream<int> get countStream => controller.stream;
  int get reps => _reps;

  void setParams({
    required int reps,
    required int period,
  }) {
    _reps = reps;
    _period = period;
  }

  void push(int x) {
    controller.add(x);
  }

  Stream<int> count() {
    return Stream.periodic(Duration(milliseconds: _period), ((n) {
      return n + 1;
    }));
  }
}

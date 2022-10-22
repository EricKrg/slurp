import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:slurp/elements/particles.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<StatefulWidget> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _counter = 0;

  final int aim = 2500;
  final int rate = 25;

  ParticlesInteractiveExample particles = ParticlesInteractiveExample(
      from: Colors.white, to: Colors.blueAccent, zoom: 5.0);

  void _incrementCounter() {
    particles.increasePcount(rate: 10);

    setState(() {
      _counter += rate;
    });
    print(_counter);
  }

  void _decrementCounter() {
    particles.decreasePcount(rate: 10);
    if (_counter - rate < 0) {
      _counter = 0;
      return;
    }
    setState(() {
      _counter -= rate;
    });

    print(_counter);
  }

  void _setCounter(int count) {
    particles.setPcount(count);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          alignment: Alignment.center,
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          children: [
            GameWidget(game: particles),
            Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Text(
                    "$_counter ml",
                    style: TextStyle(color: Colors.blue, fontSize: 40),
                  ),
                )
              ],
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                FloatingActionButton(
                  mini: true,
                  enableFeedback: true,
                  onPressed: () {
                    _decrementCounter();
                  },
                  child: const Icon(Icons.remove),
                ),
                FloatingActionButton(
                  mini: true,
                  enableFeedback: true,
                  onPressed: () {
                    _incrementCounter();
                  },
                  child: const Icon(Icons.add),
                )
              ],
            )));
  }
}

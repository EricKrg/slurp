import 'dart:async' as dartTimer;
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/particles.dart';
import 'package:flame_forge2d/flame_forge2d.dart' as forge2d;
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' hide Image;

class ParticlesInteractiveExample extends forge2d.Forge2DGame with PanDetector {
  static const description = 'An example which shows how '
      'ParticleSystemComponent can be added in runtime '
      'following an event, in this example, the mouse '
      'dragging';

  final random = Random();
  final Tween<double> noise = Tween(begin: -10, end: 10);
  final ColorTween colorTween;
  final double zoom;
  final pCountMax = 1000;
  final double maxLifeSpan = 10;
  final double minLifeSpan = 3;
  var pCount = 1;

  Vector2 globalPos = Vector2(0, 0);

  Random rnd = Random();

  Vector2 randomVector2() => (Vector2.random(rnd) - Vector2.random(rnd)) * 0.8;

  ParticlesInteractiveExample({
    required Color from,
    required Color to,
    required this.zoom,
  }) : colorTween = ColorTween(begin: from, end: to);

  void setPcount(int count) {
    if (count > pCountMax) {
      pCount = pCountMax;
      return;
    }
    pCount = count;
    print("set pcount");
    print(pCount);
  }

  void setGlobalPos(Offset pos) {
    globalPos = screenToWorld(Vector2(pos.dx, pos.dy));
  }

  void increasePcount({double relation = 1}) {
    if (pCountMax * relation <= pCountMax) {
      pCount = (pCountMax * relation).toInt();
    }
    print("pcount new");
    print(pCount);
    add(ParticleSystemComponent(
        particle: chainingBehaviors(
            globalPos, screenToWorld(size * camera.zoom / 2))));
  }

  void decreasePcount({double relation = 1}) {
    final subP = (pCountMax * relation).toInt();
    if (subP < 1) {
      return;
    }
    add(ParticleSystemComponent(
        particle: chainingBehaviors(
            screenToWorld(size * camera.zoom / 2), globalPos)));
    pCount = subP;
  }

  @override
  void onMount() {
    dartTimer.Timer.periodic(const Duration(seconds: 1), (_) {
      spawnParticles((2 + rnd.nextInt(2)) / 10, pCount);
    });

    // dartTimer.Timer.periodic(const Duration(seconds:1), (_) {
    //   spawnParticles();
    // });
    super.onMount();
  }

  @override
  Future<void> onLoad() async {
    // camera.followVector2(Vector2.zero());
    // camera.zoom = zoom;
    ;
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    print(info.eventPosition.game.xy);
    // pCount = pCount + 1;
    // add(
    //   ParticleSystemComponent(
    //     position: info.eventPosition.game,
    //     particle: Particle.generate(
    //       count: 4,
    //       generator: (i) {
    //         return AcceleratedParticle(
    //           //lifespan: 2,
    //           lifespan: 4,
    //           speed: Vector2(
    //                 noise.transform(random.nextDouble()),
    //                 noise.transform(random.nextDouble()),
    //               ) *
    //               i.toDouble(),
    //           child: CircleParticle(
    //               radius: 0.2,
    //               paint: Paint()
    //                 ..color = colorTween.transform(random.nextDouble())!),
    //         );
    //       },
    //     ),
    //   ),
    // );
  }

  void spawnParticles(double particelSize, int particelCount) {
    add(ParticleSystemComponent(
        anchor: Anchor.center,
        position: screenToWorld(size * camera.zoom / 2),
        particle: slurpParticle(particelSize, particelCount)));
  }

  Particle slurpParticle(double particelSize, int particelCount) {
    final factor = (particelCount / pCountMax);
    final lifeSpan = factor * maxLifeSpan;
    return Particle.generate(
      lifespan: lifeSpan < minLifeSpan ? minLifeSpan : lifeSpan,
      count: particelCount > pCountMax ? pCountMax : particelCount,
      generator: (i) {
        final color = colorTween.transform(random.nextDouble())!;
        return AcceleratedParticle(
          acceleration: randomVector2(),
          child: ComputedParticle(
            renderer: (canvas, particle) {
              final paint = Paint()..color = color;
              // Override the color to dynamically update opacity
              paint.color = paint.color.withOpacity(1 - particle.progress);
              canvas.drawCircle(
                Offset.zero,
                particelSize,
                paint,
              );
            },
          ),
        );
      },
    );
  }

  /// Same example as above, but
  /// with easing, utilising [CurvedParticle] extension
  Particle easedMovingParticle() {
    final Random rnd = Random();
    return Particle.generate(
      count: 5,
      generator: (i) => MovingParticle(
        curve: Curves.easeOutQuad,
        to: randomCellVector2()..scale(.5),
        child: CircleParticle(
          radius: 5 + rnd.nextDouble() * 5,
          paint: Paint()..color = Colors.deepPurple,
        ),
      ),
    );
  }

  /// Returns random [Vector2] within a virtual grid cell
  Vector2 randomCellVector2() {
    return (Vector2.random() - Vector2.random())..multiply(Vector2(2, 2));
  }

  Particle chainingBehaviors(Vector2 from, Vector2 to) {
    return Particle.generate(
        count: 20,
        lifespan: 2,
        generator: (i) => MovingParticle(
            curve: Curves.easeOutQuad,
            from: from,
            to: to,
            child: AcceleratedParticle(
                acceleration: randomVector2() * 3,
                //  speed: Vector2(
                //           noise.transform(random.nextDouble()),
                //           noise.transform(random.nextDouble()),
                //         )*-1,
                child: ComputedParticle(
                  renderer: (canvas, particle) {
                    final paint = Paint()..color = Colors.white;
                    // Override the color to dynamically update opacity
                    paint.color =
                        paint.color.withOpacity(1 - particle.progress);
                    canvas.drawCircle(
                      Offset.zero,
                      0.2,
                      paint,
                    );
                  },
                ))));
  }
}

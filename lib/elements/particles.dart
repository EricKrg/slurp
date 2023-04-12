import 'dart:async' as dartTimer;
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/particles.dart';
import 'package:flame_forge2d/flame_forge2d.dart' as forge2d;
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' hide Image;

class ParticlesInteractive extends forge2d.Forge2DGame with PanDetector {
  static const description = 'An example which shows how '
      'ParticleSystemComponent can be added in runtime '
      'following an event, in this example, the mouse '
      'dragging';

  final random = Random();
  final Tween<double> noise = Tween(begin: -3, end: 3);
  final ColorTween colorTween;
  final double zoom;
  final pCountMax = 1000;
  final double maxLifeSpan = 10;
  final double minLifeSpan = 3;
  var pCount = 1;

  Vector2 globalPos = Vector2(0, 0);

  Random rnd = Random();

  Vector2 randomVector2() => (Vector2.random(rnd) - Vector2.random(rnd)) * 0.8;

  ParticlesInteractive({
    required Color from,
    required Color to,
    required this.zoom,
  }) : colorTween = ColorTween(begin: from, end: to);

  @override
  void onMount() {
    dartTimer.Timer.periodic(const Duration(seconds: 1), (_) {
      spawnParticles((2 + rnd.nextInt(2)) / 10, pCount);
    });
    super.onMount();
  }

  @override
  Future<void> onLoad() async {}

  @override
  void onRemove() {
    // TODO: implement onRemove
    super.onRemove();
    print("on remove");
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {}

  void setPcount(int count) {
    if (count > pCountMax) {
      pCount = pCountMax;
      return;
    }
    pCount = count;
  }

  void setGlobalPos(Offset pos) {
    globalPos = screenToWorld(Vector2(pos.dx, pos.dy));
  }

  void increasePcount({double relation = 1}) {
    if (pCountMax * relation <= pCountMax) {
      pCount = (pCountMax * relation).toInt();
    }
    final addParticle = ParticleSystemComponent(
        particle: chainingBehaviors(
            globalPos, screenToWorld(size * camera.zoom / 2)));
    add(addParticle);
  }

  void decreasePcount({double relation = 1}) {
    final subP = (pCountMax * relation).toInt();
    if (subP < 1) {
      return;
    }
    final subParticle = ParticleSystemComponent(
        particle: chainingBehaviors(
            screenToWorld(size * camera.zoom / 2), globalPos));
    add(subParticle);
    pCount = subP;
  }

  void spawnParticles(double particelSize, int particelCount) {
    final particle = slurpParticle(particelSize, particelCount);
    final particleComp =
        ParticleSystemComponent(anchor: Anchor.center, particle: particle);
    add(particleComp);
    camera.followComponent(particleComp);
  }

  Particle slurpParticle(double particelSize, int particelCount) {
    final factor = (particelCount / pCountMax);
    final lifeSpan =
        factor * maxLifeSpan < minLifeSpan ? minLifeSpan : factor * maxLifeSpan;
    return Particle.generate(
      lifespan: lifeSpan,
      count: particelCount > pCountMax ? pCountMax : particelCount,
      generator: (i) {
        final color = colorTween.transform(random.nextDouble())!;
        return AcceleratedParticle(
          lifespan: lifeSpan,
          acceleration: randomVector2(),
          child: ComputedParticle(
            lifespan: lifeSpan,
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
            lifespan: 2,
            curve: Curves.easeOutQuad,
            from: from,
            to: to,
            child: AcceleratedParticle(
                acceleration: randomVector2() * 3,
                lifespan: 2,
                speed: Vector2(
                  noise.transform(random.nextDouble()),
                  noise.transform(random.nextDouble()),
                ),
                child: ComputedParticle(
                  lifespan: 2,
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

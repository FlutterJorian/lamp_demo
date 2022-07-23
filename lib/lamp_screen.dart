import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lamp/background_text.dart';
import 'package:lamp/line_painter.dart';

class LampScreen extends StatefulWidget {
  const LampScreen({Key? key}) : super(key: key);

  @override
  State<LampScreen> createState() => _LampScreenState();
}

class _LampScreenState extends State<LampScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<Offset> lampToStartAnimation;
  late Tween<Offset> lampToStartTween;

  final double lampSize = 100;

  bool isLampOn = false;
  bool isDragging = false;
  double lampX = 0;
  double lampY = 0;

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    lampToStartTween = Tween<Offset>();
    lampToStartAnimation = lampToStartTween.animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.fastOutSlowIn,
    ))
      ..addListener(() {
        setState(() {
          lampX = lampToStartAnimation.value.dx;
          lampY = lampToStartAnimation.value.dy;
        });
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final centerX = MediaQuery.of(context).size.width / 2;
    final isOnStartPosY = lampY == 0 && !isDragging;
    lampX = lampX == 0 && !isDragging ? centerX : lampX;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (isLampOn) ...[
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => const RadialGradient(
                radius: math.pi / 9,
                colors: [
                  Color(0xfffcf72c),
                  Color(0xfffcf72c),
                  Color.fromARGB(255, 61, 60, 11)
                ],
              ).createShader(
                Rect.fromCenter(
                  center: Offset(lampX,
                      isOnStartPosY ? lampY + 110 : lampY + (lampSize / 2)),
                  width: lampSize * 5,
                  height: lampSize * 5,
                ),
              ),
              child: const BackgroundText(),
            ),
          ],
          CustomPaint(
            painter: LinePainter(
              from: Offset(centerX, 0),
              to: Offset(lampX, lampY - (lampSize / 2)),
            ),
          ),
          Positioned(
            top: isOnStartPosY ? lampY : lampY - (lampSize / 2),
            left: lampX - (lampSize / 2),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isLampOn = !isLampOn;
                });
              },
              onPanStart: (details) {
                setState(() {
                  if (!isLampOn) isLampOn = true;
                  isDragging = true;
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  lampY = details.globalPosition.dy;
                  lampX = details.globalPosition.dx;
                });
              },
              onPanEnd: (details) {
                setState(() {
                  isDragging = false;
                });
                animateLamp(
                  begin: Offset(lampX, lampY),
                  end: Offset(centerX, lampSize / 2),
                );
              },
              child: Image.asset(
                isLampOn || isDragging
                    ? 'assets/images/lamp_on.png'
                    : 'assets/images/lamp_off.png',
                width: lampSize,
                height: lampSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void animateLamp({required Offset begin, required Offset end}) {
    lampToStartTween.begin = begin;
    lampToStartTween.end = end;
    animationController.reset();
    animationController.forward();
  }
}

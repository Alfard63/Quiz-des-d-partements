import 'dart:math';

import 'package:flutter/material.dart';
import 'package:interactive_image/answer_button.dart';
import 'package:interactive_image/interactive_image_canvas.dart';
import 'package:interactive_image/models/interactive_image_model.dart';
import 'package:interactive_image/models/svg_part.dart';
import 'package:interactive_image/models/svg_parts.dart';

class Question extends StatefulWidget {
  final SvgPart svgPartToFind;
  final List<SvgPart> svgParts;
  final int difficulty;
  const Question({
    super.key,
    required this.svgPartToFind,
    required this.svgParts,
    required this.difficulty,
  });

  @override
  State<Question> createState() => _QuestionState();
}

class _QuestionState extends State<Question> {
  late List<SvgPart> randomParts;
  final List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
    Colors.cyan,
    Colors.amber,
    Colors.deepOrange,
    Colors.lightBlue,
  ];

  @override
  void initState() {
    super.initState();
    randomParts = widget.svgParts;
    while (randomParts.contains(widget.svgPartToFind)) {
      randomParts = widget.svgParts;
      randomParts.shuffle();
      randomParts = randomParts.sublist(0, widget.difficulty + 2);
    }
    randomParts.add(widget.svgPartToFind);
    randomParts.shuffle();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.width < 800
                      ? MediaQuery.of(context).size.width * 0.6
                      : MediaQuery.of(context).size.width * 0.35,
                  maxWidth: MediaQuery.of(context).size.width < 800
                      ? MediaQuery.of(context).size.width * 0.6
                      : MediaQuery.of(context).size.width * 0.35,
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange.shade300, width: 5),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: InteractiveImageCanvas(
                  model: InteractiveImageModel(
                      svgParts: SvgParts(parts: [widget.svgPartToFind])),
                  parts: [widget.svgPartToFind.name],
                  isOnlyOne: true,
                  screenSize: MediaQuery.of(context).size,
                ),
              ),
              Positioned(
                bottom: 10,
                child: Text(
                  "Préfecture: ${widget.svgPartToFind.city}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Quel est le nom de ce département ?",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 5,
              runSpacing: 5,
              children: randomParts.map((e) {
                final Color color = colors[Random().nextInt(colors.length)];
                return AnswerButton(
                  onPressed: () {
                    if (e.name == widget.svgPartToFind.name) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Bravo, vous avez trouvé le bon département !"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Dommage, ce n'est pas le bon département !"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  text: e.label,
                  value: e.label,
                  color: color,
                  textColor: color,
                );
              }).toList(),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

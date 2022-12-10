import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:interactive_image/interactive_image_canvas.dart';
import 'package:interactive_image/models/interactive_image_model.dart';
import 'package:interactive_image/models/svg_part.dart';
import 'package:interactive_image/models/svg_parts.dart';
import 'package:interactive_image/question.dart';
import 'package:xml/xml.dart';

class InteractiveImage extends StatefulWidget {
  final String svgfile;
  const InteractiveImage({super.key, required this.svgfile});

  @override
  State<InteractiveImage> createState() => _InteractiveImageState();
}

List<String> parts = [];
String partLabel = '';
String partCity = '';
InteractiveImageModel? _model;

class _InteractiveImageState extends State<InteractiveImage> {
  int delayforRandom = 1;
  int difficulty = 6;
  int counter = 0;
  bool isQuiz = false;

  Future<void> loadSvgImage({required String svgImage}) async {
    final String generalString = await rootBundle.loadString(svgImage);
    final XmlDocument xmlDocument = XmlDocument.parse(generalString);
    final paths = xmlDocument.findAllElements('path');
    final List<SvgPart> svgParts = [];
    for (var element in paths) {
      final String partName = element.getAttribute('id').toString();
      final String partPath = element.getAttribute('d').toString();
      final String partLabel = element.getAttribute('label').toString();
      final String partCity = element.getAttribute('city').toString();

      final SvgPart svgPart = SvgPart(
          name: partName, path: partPath, label: partLabel, city: partCity);

      svgParts.add(svgPart);
    }
    setState(() {
      _model = InteractiveImageModel(svgParts: SvgParts(parts: svgParts));
    });
  }

  void _onPartSelected(List ids) {
    setState(() {
      parts = [...ids];
      if (!isQuiz) {
        final SvgPart svgPart = _model!.svgParts.parts
            .firstWhere((element) => element.name == parts.first);
        partLabel = svgPart.label;
        partCity = svgPart.city;
      }
    });
  }

  void _randomSelectedPart() {
    isQuiz = true;
    final randomNumber = Random().nextInt(_model!.svgParts.parts.length);
    delayforRandom > 200
        ? delayforRandom += 200
        : delayforRandom > 100
            ? delayforRandom += 10
            : delayforRandom += 5;
    setState(() {
      parts = [_model!.svgParts.parts[randomNumber].name];
      partLabel = _model!.svgParts.parts[randomNumber].label;
      partCity = _model!.svgParts.parts[randomNumber].city;
    });
    if (delayforRandom < 1000) {
      Future.delayed(Duration(milliseconds: delayforRandom), () {
        _randomSelectedPart();
      });
    } else {
      delayforRandom = 1;
      Future.delayed(const Duration(milliseconds: 1500), () async {
        await showDialog(
          context: context,
          builder: (context) => Dialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Question(
              svgPartToFind: _model!.svgParts.parts[randomNumber],
              svgParts: _model!.svgParts.parts,
              difficulty: difficulty,
            ),
          ),
        );
        isQuiz = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadSvgImage(svgImage: widget.svgfile);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _model != null
              ? SizedBox(
                  height: screenSize.width < 800
                      ? screenSize.width * 0.95
                      : screenSize.width * 0.35,
                  width: screenSize.width < 800
                      ? screenSize.width * 0.863
                      : screenSize.width * 0.318,
                  child: InteractiveImageCanvas(
                      model: _model!,
                      parts: parts,
                      onPartSelected: _onPartSelected,
                      screenSize: screenSize),
                )
              : const CircularProgressIndicator(),
          !isQuiz
              ? SizedBox(
                  height: 70,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Département: $partLabel",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Préfecture: $partCity",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(height: 70),
          ElevatedButton(
              onPressed: () => _randomSelectedPart(), child: const Text('Quiz'))
        ],
      ),
    );
  }
}

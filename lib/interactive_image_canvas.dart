import 'package:flutter/material.dart';
import 'package:interactive_image/models/interactive_image_model.dart';
import 'package:interactive_image/models/svg_part.dart';
import 'package:svg_path_parser/svg_path_parser.dart';
import 'package:touchable/touchable.dart';

class InteractiveImageCanvas extends StatefulWidget {
  final InteractiveImageModel model;
  final List<String> parts;
  final void Function(List)? onPartSelected;
  final bool isClickable;
  final bool isOnlyOne;
  final bool singleSelection;
  final Size screenSize;
  const InteractiveImageCanvas(
      {Key? key,
      required this.model,
      required this.parts,
      this.onPartSelected,
      this.isClickable = true,
      this.isOnlyOne = false,
      this.singleSelection = true,
      required this.screenSize})
      : super(key: key);

  @override
  State<InteractiveImageCanvas> createState() => _InteractiveImageCanvasState();
}

class _InteractiveImageCanvasState extends State<InteractiveImageCanvas> {
  List<String> selectedParts = [];

  @override
  Widget build(BuildContext context) {
    selectedParts = widget.parts;
    return CanvasTouchDetector(
      gesturesToOverride: const [
        GestureType.onTapUp,
      ],
      builder: (context) => CustomPaint(
        painter: BodyPainter(
            context: context,
            model: widget.model,
            isClickable: widget.isClickable,
            isOnlyOne: widget.isOnlyOne,
            singleSelection: widget.singleSelection,
            selectedParts: selectedParts,
            screenSize: widget.screenSize,
            callback: (ids) {
              setState(() {
                selectedParts = ids.map((e) => e.toString()).toList();
                if (widget.onPartSelected != null) {
                  widget.onPartSelected!(selectedParts);
                }
              });
            }),
      ),
    );
  }
}

class BodyPainter extends CustomPainter {
  final BuildContext context;
  final InteractiveImageModel model;
  final void Function(List) callback;
  final bool singleSelection;
  final bool isClickable;
  final bool isOnlyOne;
  final Size screenSize;
  final List<String> selectedParts;
  BodyPainter({
    required this.context,
    required this.model,
    required this.callback,
    required this.selectedParts,
    required this.singleSelection,
    this.isClickable = true,
    this.isOnlyOne = false,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final myCanvas = TouchyCanvas(context, canvas);
    List<String> ids;
    ids = selectedParts;
    Future<void> selecGeneralBodyPart(String name) async {
      if (singleSelection == true) {
        ids = [];
      }
      if (ids.contains(name)) {
        ids.remove(name);
      } else {
        ids.add(name);
      }
      callback(ids);
    }

    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 0.5)
      ..strokeWidth = 8.0;
    final xScale = screenSize.width < 800
        ? screenSize.width * 0.95 / 1000
        : screenSize.width * 0.35 / 1000;
    final yScale = screenSize.width < 800
        ? screenSize.width * 0.95 / 1000
        : screenSize.width * 0.35 / 1000;
    final Matrix4 matrix4 = Matrix4.identity();

    matrix4.scale(xScale, yScale);

    final List<SvgPart> generalParts = model.svgParts.parts;

    for (final element in generalParts) {
      final Path path = parseSvgPath(element.path);
      paint.color = Colors.grey;

      if (selectedParts.contains(element.name)) {
        paint.color = Colors.orange;
      }

      if (isOnlyOne == true) {
        final Matrix4 matrix4Scale = Matrix4.identity();
        final left = path.getBounds().left;
        final top = path.getBounds().top;
        final right = path.getBounds().right;
        final bottom = path.getBounds().bottom;
        matrix4Scale.scale(xScale * 4, yScale * 4);
        matrix4Scale.translate(
            -((right - left) / 2 + left), -((bottom - top) / 2 + top));
        myCanvas.drawPath(
          path.transform(matrix4Scale.storage),
          paint,
        );
      } else {
        myCanvas.drawPath(
          path.transform(matrix4.storage),
          paint,
          onTapUp: (details) =>
              isClickable ? selecGeneralBodyPart(element.name) : null,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

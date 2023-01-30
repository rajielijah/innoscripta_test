
import 'package:flutter/material.dart';
import '../models/project.dart';

class ProjectColour extends StatelessWidget {
  static const double _size = 22;
  final Project? project;
  final bool? mini;
  const ProjectColour({Key? key, this.project, this.mini}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool m = mini ?? false;
    double scale = m ? 0.75 : 1.0;

    return Container(
      key: Key("pc-${project?.id}-m"),
      width: _size * scale,
      height: _size * scale,
      decoration: BoxDecoration(
        color: project?.colour ?? Colors.transparent,
        //borderRadius: BorderRadius.circular(SIZE * 0.5 * scale),
        border: project == null
            ? Border.all(
                color: Theme.of(context).disabledColor,
                width: 3.0,
              )
            : null,
        shape: BoxShape.circle,
      ),
    );
  }
}

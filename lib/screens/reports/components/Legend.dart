
import 'package:flutter/material.dart';
import '../../../components/ProjectColour.dart';
import '../../../l10n.dart';
import '../../../models/project.dart';

class Legend extends StatelessWidget {
  final Iterable<Project?> projects;

  const Legend({Key? key, required this.projects}) : super(key: key);

  List<Widget> _chips(BuildContext context) {
    return projects
        .map((project) => Chip(
              avatar: ProjectColour(project: project, mini: true),
              label: Text(project?.name ?? L10N.of(context).tr.noProject,
                  style: TextStyle(
                    fontSize:
                        Theme.of(context).textTheme.bodyText2!.fontSize! * 0.75,
                  )),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (projects.length <= 5) {
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 4.0,
        children: _chips(context),
      );
    }
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: _chips(context),
      ),
    );
  }
}

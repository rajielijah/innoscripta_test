
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/projects/bloc.dart';
import '../../../components/ProjectColour.dart';
import '../../../l10n.dart';
import '../../../models/project.dart';
import '../../../screens/dashboard/bloc/dashboard_bloc.dart';

class ProjectSelectField extends StatefulWidget {
  const ProjectSelectField({Key? key}) : super(key: key);

  @override
  State<ProjectSelectField> createState() => _ProjectSelectFieldState();
}

class _ProjectSelectFieldState extends State<ProjectSelectField> {
  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<DashboardBloc>(context);
    final projectsBloc = BlocProvider.of<ProjectsBloc>(context);
    return BlocBuilder<ProjectsBloc, ProjectsState>(
        builder: (BuildContext context, ProjectsState projectsState) {
      return BlocBuilder<DashboardBloc, DashboardState>(
        bloc: bloc,
        builder: (BuildContext context, DashboardState state) {
          // detect if the project we had selected was deleted or archived
          if (state.newProject != null &&
              (projectsBloc.getProjectByID(state.newProject!.id) == null ||
                  projectsBloc
                      .getProjectByID(state.newProject!.id)!
                      .archived)) {
            bloc.add(const ProjectChangedEvent(null));
            return const IconButton(
              alignment: Alignment.centerLeft,
              icon: ProjectColour(project: null),
              onPressed: null,
            );
          }

          final projectName = state.newProject?.name;

          return IconButton(
            alignment: Alignment.centerLeft,
            icon: ProjectColour(project: state.newProject),
            tooltip: projectName != null
                ? "${L10N.of(context).tr.project} ($projectName)"
                : L10N.of(context).tr.project,
            onPressed: () async {
              _ProjectChoice? projectChoice = await showDialog<_ProjectChoice>(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return SimpleDialog(
                      title: Text(L10N.of(context).tr.projects),
                      contentPadding:
                          const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 16.0),
                      children: <Project?>[null]
                          .followedBy(
                              projectsState.projects.where((p) => !p.archived))
                          .map((Project? p) => TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(_ProjectChoice(p));
                              },
                              child: Row(
                                children: <Widget>[
                                  ProjectColour(project: p),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                                    child: Text(
                                        p?.name ??
                                            L10N.of(context).tr.noProject,
                                        style: TextStyle(
                                            color: p == null
                                                ? Theme.of(context)
                                                    .disabledColor
                                                : Theme.of(context)
                                                    .textTheme
                                                    .bodyText2!
                                                    .color)),
                                  ),
                                ],
                              )))
                          .toList(),
                    );
                  });

              if (projectChoice != null) {
                bloc.add(ProjectChangedEvent(projectChoice.chosenProject));
              }
            },
          );
        },
      );
    });
  }
}

/// A class that stores the project that has been chosen by the user.
///
/// [chosenProject] may be `null` in case the user has chosen “(no project)”.
class _ProjectChoice {
  final Project? chosenProject;

  _ProjectChoice(this.chosenProject);
}

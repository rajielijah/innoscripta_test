
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../blocs/projects/bloc.dart';
import '../../../blocs/settings/bloc.dart';
import '../../../components/ProjectColour.dart';
import '../../../l10n.dart';
import '../../../screens/projects/ProjectEditor.dart';
import '../../../models/project.dart';

enum _ProjectMenuItems { archive, delete }

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final projectsBloc = BlocProvider.of<ProjectsBloc>(context);
    final settingsBloc = BlocProvider.of<SettingsBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(L10N.of(context).tr.projects),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        bloc: settingsBloc,
        builder: (BuildContext context, SettingsState settingsState) =>
            BlocBuilder<ProjectsBloc, ProjectsState>(
                bloc: projectsBloc,
                builder: (BuildContext context, ProjectsState state) {
                  return ListView(
                    children: state.projects
                        .map((project) => Slidable(
                              startActionPane: ActionPane(
                                  motion: const DrawerMotion(),
                                  extentRatio: 0.15,
                                  children: <Widget>[
                                    SlidableAction(
                                      backgroundColor:
                                          Theme.of(context).errorColor,
                                      foregroundColor: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                      icon: FontAwesomeIcons.trash,
                                      onPressed: (_) async {
                                        await _deleteProject(
                                            context, projectsBloc, project);
                                      },
                                    )
                                  ]),
                              endActionPane: ActionPane(
                                  motion: const DrawerMotion(),
                                  extentRatio: 0.15,
                                  children: <Widget>[
                                    SlidableAction(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        foregroundColor: Theme.of(context)
                                            .colorScheme
                                            .onSecondary,
                                        icon: project.archived
                                            ? FontAwesomeIcons.boxOpen
                                            : FontAwesomeIcons.boxArchive,
                                        onPressed: (_) {
                                          projectsBloc.add(EditProject(
                                              Project.clone(project,
                                                  archived:
                                                      !project.archived)));
                                        })
                                  ]),
                              child: ListTile(
                                leading: ProjectColour(project: project),
                                title: project.archived
                                    ? Row(
                                        children: [
                                          Icon(
                                            FontAwesomeIcons.boxArchive,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text(project.name))
                                        ],
                                      )
                                    : Text(project.name),
                                trailing: PopupMenuButton<_ProjectMenuItems>(
                                    onSelected: (menuItem) async {
                                      switch (menuItem) {
                                        case _ProjectMenuItems.archive:
                                          projectsBloc.add(EditProject(
                                              Project.clone(project,
                                                  archived:
                                                      !project.archived)));
                                          break;
                                        case _ProjectMenuItems.delete:
                                          await _deleteProject(
                                              context, projectsBloc, project);
                                          break;
                                      }
                                    },
                                    itemBuilder: (_) => [
                                          PopupMenuItem(
                                            value: _ProjectMenuItems.archive,
                                            child: Text(project.archived
                                                ? L10N.of(context).tr.unarchive
                                                : L10N.of(context).tr.archive),
                                          ),
                                          PopupMenuItem(
                                            value: _ProjectMenuItems.delete,
                                            child: Text(
                                                L10N.of(context).tr.delete),
                                          )
                                        ]),
                                onTap: () => showDialog<void>(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        ProjectEditor(
                                          project: project,
                                        )),
                              ),
                            ))
                        .toList(),
                  );
                }),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: L10N.of(context).tr.createNewProject,
        key: const Key("addProject"),
        child: Stack(
          // shenanigans to properly centre the icon (font awesome glyphs are variable
          // width but the library currently doesn't deal with that)
          fit: StackFit.expand,
          children: const <Widget>[
            Positioned(
              top: 15,
              left: 16,
              child: Icon(FontAwesomeIcons.plus),
            )
          ],
        ),
        onPressed: () => showDialog<void>(
            context: context,
            builder: (BuildContext context) => const ProjectEditor(
                  project: null,
                )),
      ),
    );
  }

  Future<void> _deleteProject(
      BuildContext context, ProjectsBloc projectsBloc, Project project) async {
    bool delete = await (showDialog<bool>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                  title: Text(L10N.of(context).tr.confirmDelete),
                  content: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText2!.color),
                          children: <TextSpan>[
                            TextSpan(
                                text:
                                    "${L10N.of(context).tr.areYouSureYouWantToDelete}\n\n"),
                            TextSpan(
                                text: "⬤ ",
                                style: TextStyle(color: project.colour)),
                            TextSpan(
                                text: project.name,
                                style: const TextStyle(
                                    fontStyle: FontStyle.italic)),
                          ])),
                  actions: <Widget>[
                    TextButton(
                      child: Text(L10N.of(context).tr.cancel),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    TextButton(
                      child: Text(L10N.of(context).tr.delete),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                ))) ??
        false;
    if (delete) {
      projectsBloc.add(DeleteProject(project));
    }
  }
}

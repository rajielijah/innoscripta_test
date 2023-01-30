
import 'dart:collection';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/projects/bloc.dart';
import '../../../blocs/timers/bloc.dart';
import '../../../components/ProjectColour.dart';
import '../../../l10n.dart';
import '../../../models/project.dart';
import '../../../models/timer_entry.dart';

class TimeTable extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<Project?> selectedProjects;
  const TimeTable(
      {Key? key,
      required this.startDate,
      required this.endDate,
      required this.selectedProjects})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final projects = BlocProvider.of<ProjectsBloc>(context);
    final timers = BlocProvider.of<TimersBloc>(context);

    LinkedHashMap<int?, double> projectHours = LinkedHashMap();
    for (TimerEntry timer in timers.state.timers
        .where((timer) => timer.endTime != null)
        .where((timer) => selectedProjects.any((p) => p?.id == timer.projectID))
        .where((timer) =>
            startDate != null ? timer.startTime.isAfter(startDate!) : true)
        .where((timer) =>
            endDate != null ? timer.startTime.isBefore(endDate!) : true)) {
      projectHours.update(
          timer.projectID,
          (sum) =>
              sum +
              timer.endTime!.difference(timer.startTime).inSeconds.toDouble() /
                  3600,
          ifAbsent: () =>
              timer.endTime!.difference(timer.startTime).inSeconds.toDouble() /
              3600);
    }
    final double totalHours =
        projectHours.values.fold(0.0, (double sum, double v) => sum + v);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: ListView(
        key: const Key("timeTable"),
        shrinkWrap: true,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Text(L10N.of(context).tr.project,
                    style: Theme.of(context).textTheme.headline6),
              ),
              Expanded(
                flex: 1,
                child: Text(L10N.of(context).tr.hours,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.headline6),
              ),
            ],
          ),
          Divider(
              thickness: 2.0,
              color: Theme.of(context).textTheme.bodyText2!.color),
        ].followedBy(projectHours.entries.map((MapEntry<int?, double> entry) {
          Project? project = projects.state.projects
              .firstWhereOrNull((project) => project.id == entry.key);
          return Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        ProjectColour(
                          mini: true,
                          project: project,
                        ),
                        Container(width: 4),
                        Text(project?.name ?? L10N.of(context).tr.noProject,
                            style: Theme.of(context).textTheme.bodyText2)
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(entry.value.toStringAsFixed(1),
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodyText2),
                  ),
                ],
              ));
        })).followedBy(<Widget>[
          projectHours.isEmpty
              ? Container()
              : Divider(
                  thickness: 1.0,
                  color: Theme.of(context).textTheme.bodyText2!.color),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Text(L10N.of(context).tr.total,
                    style: Theme.of(context).textTheme.bodyText2),
              ),
              Expanded(
                flex: 1,
                child: Text(totalHours.toStringAsFixed(1),
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodyText2),
              ),
            ],
          )
        ]).toList(),
      ),
    );
  }
}

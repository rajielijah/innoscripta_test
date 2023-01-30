
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../blocs/projects/bloc.dart';
import '../../../blocs/settings/bloc.dart';
import '../../../blocs/timers/bloc.dart';
import '../../../components/ProjectColour.dart';
import '../../../l10n.dart';
import '../../../models/project.dart';
import '../../../models/timer_entry.dart';
import '../../../screens/timer/TimerEditor.dart';

import '../../../timer_utils.dart';

class StoppedTimerRow extends StatefulWidget {
  final TimerEntry timer;
  const StoppedTimerRow({Key? key, required this.timer}) : super(key: key);

  @override
  State<StoppedTimerRow> createState() => _StoppedTimerRowState();
}

class _StoppedTimerRowState extends State<StoppedTimerRow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    assert(widget.timer.endTime != null);

    return MouseRegion(
        onEnter: (_) => setState(() {
              _hovering = true;
            }),
        onExit: (_) => setState(() {
              _hovering = false;
            }),
        child: Slidable(
          startActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.15,
            children: <Widget>[
              SlidableAction(
                backgroundColor: Theme.of(context).errorColor,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
                icon: FontAwesomeIcons.trash,
                onPressed: (_) async {
                  final timersBloc = BlocProvider.of<TimersBloc>(context);
                  final bool delete = await (showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                title: Text(L10N.of(context).tr.confirmDelete),
                                content: Text(
                                    L10N.of(context).tr.deleteTimerConfirm),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text(L10N.of(context).tr.cancel),
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                  ),
                                  TextButton(
                                    child: Text(L10N.of(context).tr.delete),
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                  ),
                                ],
                              ))) ??
                      false;
                  if (delete) {
                    timersBloc.add(DeleteTimer(widget.timer));
                  }
                },
              )
            ],
          ),
          endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.15,
              children: <Widget>[
                SlidableAction(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    icon: FontAwesomeIcons.play,
                    onPressed: (_) => _resumeTimer(context))
              ]),
          child: ListTile(
              key: Key("stoppedTimer-${widget.timer.id}"),
              leading: ProjectColour(
                  project: BlocProvider.of<ProjectsBloc>(context)
                      .getProjectByID(widget.timer.projectID)),
              title: Text(
                  TimerUtils.formatDescription(
                      context, widget.timer.description),
                  style: TimerUtils.styleDescription(
                      context, widget.timer.description)),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  widget.timer.formatTime(),
                  style: const TextStyle(
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                if (_hovering) const SizedBox(width: 4),
                if (_hovering)
                  IconButton(
                      icon: const Icon(FontAwesomeIcons.circlePlay),
                      onPressed: () => _resumeTimer(context),
                      tooltip: L10N.of(context).tr.resumeTimer,
                      color: Theme.of(context).colorScheme.onBackground),
              ]),
              onTap: () =>
                  Navigator.of(context).push(MaterialPageRoute<TimerEditor>(
                    builder: (BuildContext context) => TimerEditor(
                      timer: widget.timer,
                    ),
                    fullscreenDialog: true,
                  ))),
        ));
  }

  void _resumeTimer(BuildContext context) {
    final timersBloc = BlocProvider.of<TimersBloc>(context);
    final projectsBloc = BlocProvider.of<ProjectsBloc>(context);
    final settingsBloc = BlocProvider.of<SettingsBloc>(context);
    Project? project = projectsBloc.getProjectByID(widget.timer.projectID);
    if (settingsBloc.state.oneTimerAtATime) {
      timersBloc.add(const StopAllTimers());
    }
    timersBloc.add(CreateTimer(description: widget.timer.description, project: project));
  }
}

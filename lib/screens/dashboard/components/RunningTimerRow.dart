
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../blocs/projects/bloc.dart';
import '../../../blocs/timers/bloc.dart';
import '../../../components/ProjectColour.dart';
import '../../../l10n.dart';
import '../../../models/timer_entry.dart';
import '../../../screens/timer/TimerEditor.dart';
import '../../../timer_utils.dart';

class RunningTimerRow extends StatelessWidget {
  final TimerEntry timer;
  final DateTime now;

  const RunningTimerRow({Key? key, required this.timer, required this.now})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
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
                final bool delete = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                              title: Text(L10N.of(context).tr.confirmDelete),
                              content:
                                  Text(L10N.of(context).tr.deleteTimerConfirm),
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
                            )) ??
                    false;
                if (delete == true) {
                  timersBloc.add(DeleteTimer(timer));
                }
              },
            )
          ]),
      child: ListTile(
          leading: ProjectColour(
              project: BlocProvider.of<ProjectsBloc>(context)
                  .getProjectByID(timer.projectID)),
          title: Text(TimerUtils.formatDescription(context, timer.description),
              style: TimerUtils.styleDescription(context, timer.description)),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(timer.formatTime(),
                style: const TextStyle(
                  fontFeatures: [FontFeature.tabularFigures()],
                )),
            const SizedBox(width: 4),
            IconButton(
              tooltip: L10N.of(context).tr.stopTimer,
              icon: const Icon(FontAwesomeIcons.solidCircleStop),
              onPressed: () {
                final timers = BlocProvider.of<TimersBloc>(context);
                timers.add(StopTimer(timer));
              },
            ),
          ]),
          onTap: () =>
              Navigator.of(context).push(MaterialPageRoute<TimerEditor>(
                builder: (BuildContext context) => TimerEditor(
                  timer: timer,
                ),
                fullscreenDialog: true,
              ))),
    );
  }
}

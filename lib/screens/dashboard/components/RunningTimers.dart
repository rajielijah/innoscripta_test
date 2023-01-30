
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/timers/bloc.dart';
import '../../../l10n.dart';
import '../../../models/timer_entry.dart';
import '../../../screens/dashboard/bloc/dashboard_bloc.dart';

import 'RunningTimerRow.dart';

class RunningTimers extends StatelessWidget {
  const RunningTimers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (BuildContext context, DashboardState dashboardState) {
        if (dashboardState.searchString != null) {
          return Container();
        }

        return BlocBuilder<TimersBloc, TimersState>(
          builder: (BuildContext context, TimersState timersState) {
            List<TimerEntry> runningTimers = timersState.timers
                .where((timer) => timer.endTime == null)
                .toList();
            if (runningTimers.isEmpty) {
              return Container();
            }

            DateTime now = DateTime.now();
            Duration runningTotal = Duration(
                seconds: runningTimers.fold(
                    0,
                    (int sum, TimerEntry t) =>
                        sum + now.difference(t.startTime).inSeconds));

            return Material(
              elevation: 4,
              color: Theme.of(context).bottomSheetTheme.backgroundColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Text(L10N.of(context).tr.runningTimers,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.w700)),
                            Text(TimerEntry.formatDuration(runningTotal),
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
                                ))
                          ],
                        ),
                        const Divider(),
                      ],
                    ),
                  ),
                ]
                    .followedBy(runningTimers.map((timer) =>
                        RunningTimerRow(timer: timer, now: timersState.now)))
                    .toList(),
              ),
            );
          },
        );
      },
    );
  }
}

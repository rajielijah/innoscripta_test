
import 'dart:collection';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../blocs/settings/settings_bloc.dart';
import '../../../blocs/timers/bloc.dart';
import '../../../blocs/projects/bloc.dart';
import '../../../models/project_description_pair.dart';
import '../../../models/timer_entry.dart';
import '../../../screens/dashboard/bloc/dashboard_bloc.dart';
import '../../../screens/dashboard/components/CollapsibleDayGrouping.dart';
import '../../../screens/dashboard/components/FilterText.dart';
import '../../../screens/dashboard/components/GroupedStoppedTimersRow.dart';
import 'StoppedTimerRow.dart';

class DayGrouping {
  final DateTime date;
  List<TimerEntry> entries = [];
  static final DateFormat _dateFormat = DateFormat.yMMMMEEEEd();

  DayGrouping(this.date);

  Widget rows(BuildContext context) {
    final settingsBloc = BlocProvider.of<SettingsBloc>(context);
    Duration runningTotal = Duration(
        seconds: entries.fold(
            0,
            (int sum, TimerEntry t) =>
                sum + t.endTime!.difference(t.startTime).inSeconds));

    LinkedHashMap<ProjectDescriptionPair, List<TimerEntry>> pairedEntries =
        LinkedHashMap();
    for (TimerEntry entry in entries) {
      ProjectDescriptionPair pair =
          ProjectDescriptionPair(entry.projectID, entry.description);
      if (pairedEntries.containsKey(pair)) {
        pairedEntries[pair]!.add(entry);
      } else {
        pairedEntries[pair] = <TimerEntry>[entry];
      }
    }

    Iterable<Widget> theDaysTimers = pairedEntries.values.map((timers) {
      if (settingsBloc.state.groupTimers) {
        if (timers.length > 1) {
          return <Widget>[GroupedStoppedTimersRow(timers: timers)];
        } else {
          return <Widget>[StoppedTimerRow(timer: timers[0])];
        }
      } else {
        return timers.map((t) => StoppedTimerRow(timer: t)).toList();
      }
    }).expand((l) => l);

    if (settingsBloc.state.collapseDays) {
      return CollapsibleDayGrouping(
        date: date,
        totalTime: runningTotal,
        children: theDaysTimers,
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Text(_dateFormat.format(date),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w700)),
                    Text(TimerEntry.formatDuration(runningTotal),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ))
                  ],
                ),
                const Divider(),
              ],
            ),
          ),
        ].followedBy(theDaysTimers).toList(),
      );
    }
  }
}

class StoppedTimers extends StatelessWidget {
  const StoppedTimers({Key? key}) : super(key: key);

  static List<DayGrouping> groupDays(List<DayGrouping> days, TimerEntry timer) {
    bool newDay = days.isEmpty ||
        !days.any((DayGrouping day) =>
            day.date.year == timer.startTime.year &&
            day.date.month == timer.startTime.month &&
            day.date.day == timer.startTime.day);
    if (newDay) {
      days.add(DayGrouping(DateTime(
        timer.startTime.year,
        timer.startTime.month,
        timer.startTime.day,
      )));
    }
    days
        .firstWhere((DayGrouping day) =>
            day.date.year == timer.startTime.year &&
            day.date.month == timer.startTime.month &&
            day.date.day == timer.startTime.day)
        .entries
        .add(timer);

    return days;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimersBloc, TimersState>(
      builder: (BuildContext context, TimersState timersState) {
        return BlocBuilder<DashboardBloc, DashboardState>(
          builder: (BuildContext context, DashboardState dashboardState) {
            // start our list of timers
            var timers = timersState.timers.reversed
                .where((timer) => timer.endTime != null);

            // filter based on filters
            if (dashboardState.filterStart != null) {
              timers = timers.where((timer) =>
                  timer.startTime.isAfter(dashboardState.filterStart!));
            }
            if (dashboardState.filterEnd != null) {
              timers = timers.where((timer) =>
                  timer.startTime.isBefore(dashboardState.filterEnd!));
            }

            // filter based on selected projects
            timers = timers.where((t) =>
                !dashboardState.hiddenProjects.any((p) => p == t.projectID));

            // filter based on archived and deleted projects
            final projectsBloc = BlocProvider.of<ProjectsBloc>(context);
            timers = timers.where((t) =>
                projectsBloc.getProjectByID(t.projectID)?.archived != true);

            // filter based on search
            if (dashboardState.searchString != null) {
              timers = timers.where((timer) {
                // allow searching using a regex if surrounded by `/` and `/`
                if (dashboardState.searchString!.length > 2 &&
                    dashboardState.searchString!.startsWith("/") &&
                    dashboardState.searchString!.endsWith("/")) {
                  return timer.description?.contains(RegExp(
                          dashboardState.searchString!.substring(
                              1, dashboardState.searchString!.length - 1))) ??
                      true;
                } else {
                  return dashboardState.searchString == null
                      ? true
                      : timer.description?.toLowerCase().contains(
                              dashboardState.searchString!.toLowerCase()) ??
                          true;
                }
              });
            }

            final days = timers.fold(<DayGrouping>[], groupDays);

            final isFiltered = (dashboardState.filterStart != null ||
                dashboardState.filterEnd != null);

            return ListView.builder(
              itemCount: isFiltered ? days.length + 1 : days.length,
              itemBuilder: isFiltered
                  ? (BuildContext context, int index) => (index < days.length)
                      ? days[index].rows(context)
                      : FilterText(
                          filterStart: dashboardState.filterStart,
                          filterEnd: dashboardState.filterEnd,
                        )
                  : (BuildContext context, int index) =>
                      days[index].rows(context),
            );
          },
        );
      },
    );
  }
}

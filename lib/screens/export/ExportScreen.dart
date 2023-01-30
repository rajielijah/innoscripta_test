
import 'dart:collection';
import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../blocs/projects/projects_bloc.dart';
import '../../../blocs/settings/bloc.dart';
import '../../../blocs/timers/bloc.dart';
import '../../../components/ProjectColour.dart';
import '../../../l10n.dart';
import '../../../models/project.dart';
import '../../../models/project_description_pair.dart';
import '../../../models/timer_entry.dart';
import '../../../screens/export/components/ExportMenu.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({Key? key}) : super(key: key);

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class DayGroup {
  final DateTime date;
  List<TimerEntry> timers = [];

  DayGroup(this.date);
}

class _ExportScreenState extends State<ExportScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<Project?> selectedProjects = [];
  static final DateFormat _dateFormat = DateFormat("EE, MMM d, yyyy");
  static final DateFormat _exportDateFormat = DateFormat.yMd();

  @override
  void initState() {
    super.initState();
    final projects = BlocProvider.of<ProjectsBloc>(context);
    selectedProjects = <Project?>[null]
        .followedBy(projects.state.projects
            .where((p) => !p.archived)
            .map((p) => Project.clone(p)))
        .toList();

    final settingsBloc = BlocProvider.of<SettingsBloc>(context);
    _startDate = settingsBloc.getFilterStartDate();
  }

  @override
  Widget build(BuildContext context) {
    final settingsBloc = BlocProvider.of<SettingsBloc>(context);
    final projectsBloc = BlocProvider.of<ProjectsBloc>(context);

    // TODO: break this into components or something so we don't have such a massively unmanagement build function

    return Scaffold(
      appBar: AppBar(
        title: Text(L10N.of(context).tr.exportImport),
        actions: <Widget>[
          ExportMenu(dateFormat: _dateFormat),
        ],
      ),
      body: ListView(
        children: <Widget>[
          ExpansionTile(
            title: Text(L10N.of(context).tr.filter,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w700)),
            initiallyExpanded: true,
            children: <Widget>[
              ListTile(
                leading: const Icon(FontAwesomeIcons.calendar),
                title: Text(L10N.of(context).tr.from),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  _startDate == null
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18),
                          child: Text("--"),
                        )
                      : Text(_dateFormat.format(_startDate!)),
                  if (_startDate != null)
                    IconButton(
                      tooltip: L10N.of(context).tr.remove,
                      icon: const Icon(FontAwesomeIcons.circleMinus),
                      onPressed: () {
                        setState(() {
                          _startDate = null;
                        });
                      },
                    )
                ]),
                onTap: () async {
                  await DatePicker.showDatePicker(context,
                      currentTime: _startDate,
                      onChanged: (DateTime dt) => setState(() =>
                          _startDate = DateTime(dt.year, dt.month, dt.day)),
                      onConfirm: (DateTime dt) => setState(() =>
                          _startDate = DateTime(dt.year, dt.month, dt.day)),
                      theme: DatePickerTheme(
                        cancelStyle: Theme.of(context).textTheme.button!,
                        doneStyle: Theme.of(context).textTheme.button!,
                        itemStyle: Theme.of(context).textTheme.bodyText2!,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                      ));
                },
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.calendar),
                title: Text(L10N.of(context).tr.to),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  _endDate == null
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18),
                          child: Text("--"),
                        )
                      : Text(_dateFormat.format(_endDate!)),
                  if (_endDate != null)
                    IconButton(
                      tooltip: L10N.of(context).tr.remove,
                      icon: const Icon(FontAwesomeIcons.circleMinus),
                      onPressed: () {
                        setState(() {
                          _endDate = null;
                        });
                      },
                    )
                ]),
                onTap: () async {
                  await DatePicker.showDatePicker(context,
                      currentTime: _endDate,
                      onChanged: (DateTime dt) => setState(() => _endDate =
                          DateTime(dt.year, dt.month, dt.day, 23, 59, 59, 999)),
                      onConfirm: (DateTime dt) => setState(() => _endDate =
                          DateTime(dt.year, dt.month, dt.day, 23, 59, 59, 999)),
                      theme: DatePickerTheme(
                        cancelStyle: Theme.of(context).textTheme.button!,
                        doneStyle: Theme.of(context).textTheme.button!,
                        itemStyle: Theme.of(context).textTheme.bodyText2!,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                      ));
                },
              ),
            ],
          ),
         ].toList(),
      ),
      floatingActionButton: FloatingActionButton(
          key: const Key("exportFAB"),
          tooltip: L10N.of(context).tr.exportCSV,
          child: Stack(
            // shenanigans to properly centre the icon (font awesome glyphs are variable
            // width but the library currently doesn't deal with that)
            fit: StackFit.expand,
            children: const <Widget>[
              Positioned(
                top: 15,
                left: 19,
                child: Icon(FontAwesomeIcons.fileExport),
              )
            ],
          ),
          onPressed: () async {
            final timers = BlocProvider.of<TimersBloc>(context);
            final projects = BlocProvider.of<ProjectsBloc>(context);

            List<String> headers = [];
            if (settingsBloc.state.exportIncludeDate) {
              headers.add(L10N.of(context).tr.date);
            }
            if (settingsBloc.state.exportIncludeProject) {
              headers.add(L10N.of(context).tr.project);
            }
            if (settingsBloc.state.exportIncludeDescription) {
              headers.add(L10N.of(context).tr.description);
            }
            if (settingsBloc.state.exportIncludeProjectDescription) {
              headers.add(L10N.of(context).tr.combinedProjectDescription);
            }
            if (settingsBloc.state.exportIncludeStartTime) {
              headers.add(L10N.of(context).tr.startTime);
            }
            if (settingsBloc.state.exportIncludeEndTime) {
              headers.add(L10N.of(context).tr.endTime);
            }
            if (settingsBloc.state.exportIncludeDurationHours) {
              headers.add(L10N.of(context).tr.timeH);
            }
            if (settingsBloc.state.exportIncludeNotes) {
              headers.add(L10N.of(context).tr.notes);
            }

            List filteredTimers = timers.state.timers
                .where((t) => t.endTime != null)
                .where((t) => selectedProjects.any((p) => p?.id == t.projectID))
                .where((t) => _startDate == null
                    ? true
                    : t.startTime.isAfter(_startDate!))
                .where((t) =>
                    _endDate == null ? true : t.endTime!.isBefore(_endDate!))
                .where((t) =>
                    !(projects.getProjectByID(t.projectID)?.archived == true))
                .toList();
            filteredTimers.sort((a, b) => a.startTime.compareTo(b.startTime));

            // group similar timers if that's what you're in to
            if (settingsBloc.state.exportGroupTimers &&
                !(settingsBloc.state.exportIncludeStartTime ||
                    settingsBloc.state.exportIncludeEndTime)) {
              filteredTimers = timers.state.timers
                  .where((t) => t.endTime != null)
                  .where(
                      (t) => selectedProjects.any((p) => p?.id == t.projectID))
                  .where((t) => _startDate == null
                      ? true
                      : t.startTime.isAfter(_startDate!))
                  .where((t) =>
                      _endDate == null ? true : t.endTime!.isBefore(_endDate!))
                  .where((t) =>
                      !(projects.getProjectByID(t.projectID)?.archived == true))
                  .toList();
              filteredTimers.sort((a, b) => a.startTime.compareTo(b.startTime));

              // now start grouping those suckers
              final LinkedHashMap<String,
                      LinkedHashMap<ProjectDescriptionPair, List<TimerEntry>>>
                  derp = LinkedHashMap();
              for (TimerEntry timer in filteredTimers) {
                String date = _exportDateFormat.format(timer.startTime);
                LinkedHashMap<ProjectDescriptionPair, List<TimerEntry>>
                    pairedEntries =
                    derp.putIfAbsent(date, () => LinkedHashMap());
                List<TimerEntry> pairedList = pairedEntries.putIfAbsent(
                    ProjectDescriptionPair(timer.projectID, timer.description),
                    () => <TimerEntry>[]);
                pairedList.add(timer);
              }

              // ok, now they're grouped based on date, then combined project + description pairs
              // time to get them back into a flat list
              filteredTimers = derp.values.expand(
                  (LinkedHashMap<ProjectDescriptionPair, List<TimerEntry>>
                      pairedEntries) {
                return pairedEntries.values
                    .map((List<TimerEntry> groupedEntries) {
                  assert(groupedEntries.isNotEmpty);

                  // not a grouped entry
                  if (groupedEntries.length == 1) return groupedEntries[0];

                  // yes a group entry, build a dummy timer entry
                  Duration totalTime = groupedEntries.fold(
                      const Duration(),
                      (Duration d, TimerEntry t) =>
                          d + t.endTime!.difference(t.startTime));
                  return TimerEntry.clone(groupedEntries[0],
                      endTime: groupedEntries[0].startTime.add(totalTime));
                });
              }).toList();
            }

            final List<List<String>> data =
                <List<String>>[headers].followedBy(filteredTimers.map((timer) {
              List<String> row = [];
              if (settingsBloc.state.exportIncludeDate) {
                row.add(_exportDateFormat.format(timer.startTime));
              }
              if (settingsBloc.state.exportIncludeProject) {
                row.add(projects.getProjectByID(timer.projectID)?.name ?? "");
              }
              if (settingsBloc.state.exportIncludeDescription) {
                row.add(timer.description ?? "");
              }
              if (settingsBloc.state.exportIncludeProjectDescription) {
                row.add(
                    "${projects.getProjectByID(timer.projectID)?.name ?? ""}: ${timer.description ?? ""}");
              }
              if (settingsBloc.state.exportIncludeStartTime) {
                row.add(timer.startTime.toUtc().toIso8601String());
              }
              if (settingsBloc.state.exportIncludeEndTime) {
                row.add(timer.endTime!.toUtc().toIso8601String());
              }
              if (settingsBloc.state.exportIncludeDurationHours) {
                row.add((timer.endTime!
                            .difference(timer.startTime)
                            .inSeconds
                            .toDouble() /
                        3600.0)
                    .toStringAsFixed(4));
              }
              if (settingsBloc.state.exportIncludeNotes) {
                row.add(timer.notes?.trim() ?? "");
              }
              return row;
            })).toList();
            final csv =
                const ListToCsvConverter(delimitAllFields: true).convert(data);

            if (Platform.isMacOS || Platform.isLinux) {
              final outputFile = await FilePicker.platform.saveFile(
                dialogTitle: "",
                fileName: "innoscripta.csv",
              );

              if (outputFile != null) {
                await File(outputFile).writeAsString(csv, flush: true);
              }
            } else {
              final localizations = L10N.of(context);
              final directory = (Platform.isAndroid)
                  ? await getExternalStorageDirectory()
                  : await getApplicationDocumentsDirectory();
              final localPath = '${directory!.path}/innoscripta.csv';

              final file = File(localPath);
              await file.writeAsString(csv, flush: true);
              await Share.shareXFiles([XFile(localPath, mimeType: "text/csv")],
                  subject: localizations.tr
                      .innoscriptaEntries(_dateFormat.format(DateTime.now())));
            }
          }),
    );
  }
}

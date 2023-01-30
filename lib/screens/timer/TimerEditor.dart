
import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:innoscripta_test/models/clone_time.dart';
import 'package:intl/intl.dart';

import '../../blocs/projects/projects_bloc.dart';
import '../../blocs/projects/projects_state.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../blocs/timers/timers_bloc.dart';
import '../../blocs/timers/timers_event.dart';
import '../../components/ProjectColour.dart';
import '../../l10n.dart';
import '../../models/project.dart';
import '../../models/timer_entry.dart';


enum _DateTimeMenuItems { now }

class TimerEditor extends StatefulWidget {
  final TimerEntry timer;
  const TimerEditor({Key? key, required this.timer}) : super(key: key);

  @override
  State<TimerEditor> createState() => _TimerEditorState();
}

class _TimerEditorState extends State<TimerEditor> {
  TextEditingController? _descriptionController;
  TextEditingController? _notesController;
  String? _notes;

  late DateTime _startTime;
  DateTime? _endTime;

  DateTime? _oldStartTime;
  DateTime? _oldEndTime;

  Project? _project;
  late FocusNode _descriptionFocus;
  final _formKey = GlobalKey<FormState>();
  late Timer _updateTimer;
  late StreamController<DateTime> _updateTimerStreamController;

  static final DateFormat _dateFormat = DateFormat("EE, MMM d, yyyy h:mma");

  late ProjectsBloc _projectsBloc;

  @override
  void initState() {
    super.initState();
    _projectsBloc = BlocProvider.of<ProjectsBloc>(context);
    _notes = widget.timer.notes ?? "";
    _descriptionController =
        TextEditingController(text: widget.timer.description);
    _notesController = TextEditingController(text: _notes);
    _startTime = widget.timer.startTime;
    _endTime = widget.timer.endTime;
    _project = BlocProvider.of<ProjectsBloc>(context)
        .getProjectByID(widget.timer.projectID);
    _descriptionFocus = FocusNode();
    _updateTimerStreamController = StreamController();
    _updateTimer = Timer.periodic(const Duration(seconds: 1),
        (_) => _updateTimerStreamController.add(DateTime.now()));
  }

  @override
  void dispose() {
    _descriptionController!.dispose();
    _descriptionFocus.dispose();
    _updateTimer.cancel();
    _updateTimerStreamController.close();
    super.dispose();
  }

  void setStartTime(DateTime dt) {
    setState(() {
      // adjust the end time to keep a constant duration if we would somehow make the time negative
      if (_oldEndTime != null && dt.isAfter(_oldStartTime!)) {
        Duration d = _oldEndTime!.difference(_oldStartTime!);
        _endTime = dt.add(d);
      }
      _startTime = dt;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsBloc = BlocProvider.of<SettingsBloc>(context);
    final timers = BlocProvider.of<TimersBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(L10N.of(context).tr.editTimer),
        actions: [
          IconButton(
              tooltip: L10N.of(context).tr.delete,
              onPressed: () async {
                final timersBloc = BlocProvider.of<TimersBloc>(context);
                final bool delete = await (showDialog<bool>(
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
                            ))) ??
                    false;
                if (delete) {
                  timersBloc.add(DeleteTimer(widget.timer));
                  if (!mounted) return;
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(FontAwesomeIcons.trash))
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          //todo this should include a scrollable area
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            BlocBuilder<ProjectsBloc, ProjectsState>(
              builder: (BuildContext context, ProjectsState projectsState) =>
                  Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: DropdownButton(
                        value: (_project?.archived ?? true) ? null : _project,
                        underline: Container(),
                        elevation: 0,
                        onChanged: (Project? newProject) {
                          setState(() {
                            _project = newProject;
                          });
                        },
                        items: <DropdownMenuItem<Project>>[
                          DropdownMenuItem<Project>(
                            value: null,
                            child: Row(
                              children: <Widget>[
                                const ProjectColour(project: null),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                                  child: Text(L10N.of(context).tr.noProject,
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).disabledColor)),
                                ),
                              ],
                            ),
                          )
                        ]
                            .followedBy(projectsState.projects
                                .where((p) => !p.archived)
                                .map((Project project) =>
                                    DropdownMenuItem<Project>(
                                      value: project,
                                      child: Row(
                                        children: <Widget>[
                                          ProjectColour(
                                            project: project,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                8.0, 0, 0, 0),
                                            child: Text(project.name),
                                          ),
                                        ],
                                      ),
                                    )))
                            .toList(),
                      )),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: settingsBloc.state.autocompleteDescription
                  ? TypeAheadField<String?>(
                      direction: AxisDirection.down,
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _descriptionController,
                        autocorrect: true,
                        decoration: InputDecoration(
                          labelText: L10N.of(context).tr.description,
                          hintText: L10N.of(context).tr.whatWereYouDoing,
                        ),
                      ),
                      noItemsFoundBuilder: (context) => ListTile(
                          title: Text(L10N.of(context).tr.noItemsFound),
                          enabled: false),
                      itemBuilder: (BuildContext context, String? desc) =>
                          ListTile(title: Text(desc!)),
                      onSuggestionSelected: (String? description) =>
                          _descriptionController!.text = description!,
                      suggestionsCallback: (pattern) async {
                        if (pattern.length < 2) return [];

                        List<String?> descriptions = timers.state.timers
                            .where((timer) => timer.description != null)
                            .where((timer) => !(_projectsBloc
                                    .getProjectByID(timer.projectID)
                                    ?.archived ==
                                true))
                            .where((timer) =>
                                timer.description
                                    ?.toLowerCase()
                                    .contains(pattern.toLowerCase()) ??
                                false)
                            .map((timer) => timer.description)
                            .toSet()
                            .toList();
                        return descriptions;
                      },
                    )
                  : TextFormField(
                      controller: _descriptionController,
                      autocorrect: true,
                      decoration: InputDecoration(
                        labelText: L10N.of(context).tr.description,
                        hintText: L10N.of(context).tr.whatWereYouDoing,
                      ),
                    ),
            ),
            ListTile(
              title: Row(mainAxisSize: MainAxisSize.min, children: [
                Expanded(
                  child: Text(L10N.of(context).tr.startTime),
                ),
                Expanded(
                    flex: 3,
                    child: Text(
                      _dateFormat.format(_startTime),
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.bodyMedium,
                    )),
                PopupMenuButton<_DateTimeMenuItems>(
                    onSelected: (menuItem) {
                      switch (menuItem) {
                        case _DateTimeMenuItems.now:
                          _oldStartTime = _startTime;
                          _oldEndTime = _endTime;
                          setStartTime(DateTime.now());
                          break;
                      }
                    },
                    itemBuilder: (_) => [
                          PopupMenuItem(
                            value: _DateTimeMenuItems.now,
                            child: Text(L10N.of(context).tr.setToCurrentTime),
                          )
                        ]),
              ]),
              onTap: () async {
                _oldStartTime = _startTime.clone();
                _oldEndTime = _endTime?.clone();
                DateTime? newStartTime =
                    await DatePicker.showDateTimePicker(context,
                        currentTime: _startTime,
                        maxTime: _endTime == null ? DateTime.now() : null,
                        onChanged: (DateTime dt) => setStartTime(dt),
                        onConfirm: (DateTime dt) => setStartTime(dt),
                        theme: DatePickerTheme(
                          cancelStyle: Theme.of(context).textTheme.button!,
                          doneStyle: Theme.of(context).textTheme.button!,
                          itemStyle: Theme.of(context).textTheme.bodyText2!,
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                        ));

                // if the user cancelled, this should be null
                if (newStartTime == null) {
                  setState(() {
                    _startTime = _oldStartTime!;
                    _endTime = _oldEndTime;
                  });
                }
              },
            ),
            ListTile(
              title: Row(children: [
                Expanded(child: Text(L10N.of(context).tr.endTime)),
                Expanded(
                    flex: 3,
                    child: Text(
                      _endTime == null ? "--" : _dateFormat.format(_endTime!),
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.bodyMedium,
                    )),
                if (_endTime != null)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsetsDirectional.only(start: 16),
                    tooltip: L10N.of(context).tr.remove,
                    icon: const Icon(FontAwesomeIcons.circleMinus),
                    onPressed: () {
                      setState(() {
                        _endTime = null;
                      });
                    },
                  ),
                PopupMenuButton<_DateTimeMenuItems>(
                    onSelected: (menuItem) {
                      switch (menuItem) {
                        case _DateTimeMenuItems.now:
                          setState(() => _endTime = DateTime.now());
                      }
                    },
                    itemBuilder: (_) => [
                          PopupMenuItem(
                            value: _DateTimeMenuItems.now,
                            child: Text(L10N.of(context).tr.setToCurrentTime),
                          )
                        ])
              ]),
              onTap: () async {
                _oldEndTime = _endTime?.clone();
                DateTime? newEndTime = await DatePicker.showDateTimePicker(
                    context,
                    currentTime: _endTime,
                    minTime: _startTime,
                    onChanged: (DateTime dt) => setState(() => _endTime = dt),
                    onConfirm: (DateTime dt) => setState(() => _endTime = dt),
                    theme: DatePickerTheme(
                      cancelStyle: Theme.of(context).textTheme.button!,
                      doneStyle: Theme.of(context).textTheme.button!,
                      itemStyle: Theme.of(context).textTheme.bodyText2!,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                    ));

                // if the user cancelled, this should be null
                if (newEndTime == null) {
                  setState(() {
                    _endTime = _oldEndTime;
                  });
                }
              },
            ),
            StreamBuilder(
              initialData: DateTime.now(),
              stream: _updateTimerStreamController.stream,
              builder:
                  (BuildContext context, AsyncSnapshot<DateTime> snapshot) =>
                      ListTile(
                title: Text(L10N.of(context).tr.duration),
                trailing: Text(
                  TimerEntry.formatDuration(_endTime == null
                      ? snapshot.data!.difference(_startTime)
                      : _endTime!.difference(_startTime)),
                  style: const TextStyle(
                      fontFeatures: [FontFeature.tabularFigures()]),
                ),
              ),
            ),
            ListTile(
              title: Text(L10N.of(context).tr.notes),
              onTap: () async => await _editNotes(context),
            ),
            Expanded(
                child: InkWell(
                    onTap: () async => await _editNotes(context),
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Markdown(data: _notes!)))),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key("saveDetails"),
        tooltip: L10N.of(context).tr.save,
        child: Stack(
          // shenanigans to properly centre the icon (font awesome glyphs are variable
          // width but the library currently doesn't deal with that)
          fit: StackFit.expand,
          children: const <Widget>[
            Positioned(
              top: 14,
              left: 16,
              child: Icon(FontAwesomeIcons.check),
            )
          ],
        ),
        onPressed: () async {
          bool valid = _formKey.currentState!.validate();
          if (!valid) return;

          TimerEntry timer = TimerEntry(
            id: widget.timer.id,
            startTime: _startTime,
            endTime: _endTime,
            projectID: _project?.id,
            description: _descriptionController!.text.trim(),
            notes: _notes!.isEmpty ? null : _notes,
          );

          timers.add(EditTimer(timer));
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _editNotes(BuildContext context) async {
    _notesController!.text = _notes!;
    String? n = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(L10N.of(context).tr.notes),
            content: TextFormField(
              controller: _notesController,
              autofocus: true,
              autocorrect: true,
              maxLines: null,
              expands: true,
              smartDashesType: SmartDashesType.enabled,
              smartQuotesType: SmartQuotesType.enabled,
              onSaved: (String? n) => Navigator.of(context).pop(n),
            ),
            actions: <Widget>[
              TextButton(
                  child: Text(L10N.of(context).tr.cancel),
                  onPressed: () => Navigator.of(context).pop()),
              TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary),
                  onPressed: () =>
                      Navigator.of(context).pop(_notesController!.text),
                  child: Text(
                    L10N.of(context).tr.save,
                  ))
            ],
          );
        });
    if (n != null) {
      setState(() {
        _notes = n.trim();
      });
    }
  }
}

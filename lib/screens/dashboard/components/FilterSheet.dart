
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../blocs/projects/projects_bloc.dart';
import '../../../components/ProjectColour.dart';
import '../../../l10n.dart';
import '../../../models/project.dart';
import '../../../screens/dashboard/bloc/dashboard_bloc.dart';

class FilterSheet extends StatelessWidget {
  final DashboardBloc dashboardBloc;
  static final DateFormat _dateFormat = DateFormat("EE, MMM d, yyyy");
  const FilterSheet({Key? key, required this.dashboardBloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final projectsBloc = BlocProvider.of<ProjectsBloc>(context);

    return BlocBuilder<DashboardBloc, DashboardState>(
      bloc: dashboardBloc,
      builder: (BuildContext context, DashboardState state) {
        return ListView(
          shrinkWrap: true,
          children: <Widget>[
            ExpansionTile(
              title: Text(
                L10N.of(context).tr.filter,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w700),
              ),
              initiallyExpanded: true,
              children: <Widget>[
                ListTile(
                  leading: const Icon(FontAwesomeIcons.calendar),
                  title: Text(L10N.of(context).tr.from),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    state.filterStart == null
                        ? const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18),
                            child: Text("--"))
                        : Text(
                            _dateFormat.format(state.filterStart!),
                          ),
                    if (state.filterStart != null)
                      IconButton(
                        tooltip: L10N.of(context).tr.remove,
                        icon: const Icon(FontAwesomeIcons.circleMinus),
                        onPressed: () => dashboardBloc
                            .add(const FilterStartChangedEvent(null)),
                      ),
                  ]),
                  onTap: () async {
                    await DatePicker.showDatePicker(context,
                        currentTime: state.filterStart,
                        onChanged: (DateTime dt) => dashboardBloc.add(
                            FilterStartChangedEvent(
                                DateTime(dt.year, dt.month, dt.day))),
                        onConfirm: (DateTime dt) => dashboardBloc.add(
                            FilterStartChangedEvent(
                                DateTime(dt.year, dt.month, dt.day))),
                        theme: DatePickerTheme(
                          cancelStyle: Theme.of(context).textTheme.button!,
                          doneStyle: Theme.of(context).textTheme.button!,
                          itemStyle: Theme.of(context).textTheme.bodyText2!,
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                        ));
                  },
                ),
                ListTile(
                  leading: const Icon(FontAwesomeIcons.calendar),
                  title: Text(L10N.of(context).tr.to),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    state.filterEnd == null
                        ? const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18),
                            child: Text("--"))
                        : Text(_dateFormat.format(state.filterEnd!)),
                    if (state.filterEnd != null)
                      IconButton(
                        tooltip: L10N.of(context).tr.remove,
                        icon: const Icon(FontAwesomeIcons.circleMinus),
                        onPressed: () => dashboardBloc
                            .add(const FilterEndChangedEvent(null)),
                      ),
                  ]),
                  onTap: () async {
                    await DatePicker.showDatePicker(context,
                        currentTime: state.filterEnd,
                        onChanged: (DateTime dt) => dashboardBloc.add(
                            FilterEndChangedEvent(DateTime(
                                dt.year, dt.month, dt.day, 23, 59, 59, 999))),
                        onConfirm: (DateTime dt) => dashboardBloc.add(
                            FilterEndChangedEvent(DateTime(
                                dt.year, dt.month, dt.day, 23, 59, 59, 999))),
                        theme: DatePickerTheme(
                          cancelStyle: Theme.of(context).textTheme.button!,
                          doneStyle: Theme.of(context).textTheme.button!,
                          itemStyle: Theme.of(context).textTheme.bodyText2!,
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                        ));
                  },
                ),
              ],
            ),
            ExpansionTile(
              title: Text(L10N.of(context).tr.projects,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w700)),
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ElevatedButton(
                      child: Text(L10N.of(context).tr.selectNone),
                      onPressed: () => dashboardBloc.add(
                          FilterProjectsChangedEvent(<int?>[null]
                              .followedBy(
                                  projectsBloc.state.projects.map((p) => p.id))
                              .toList())),
                    ),
                    ElevatedButton(
                      child: Text(L10N.of(context).tr.selectAll),
                      onPressed: () => dashboardBloc
                          .add(const FilterProjectsChangedEvent(<int>[])),
                    ),
                  ],
                ),
              ]
                  .followedBy(<Project?>[null]
                      .followedBy(
                          projectsBloc.state.projects.where((p) => !p.archived))
                      .map((project) => CheckboxListTile(
                            secondary: ProjectColour(
                              project: project,
                            ),
                            title: Text(
                                project?.name ?? L10N.of(context).tr.noProject),
                            value: !state.hiddenProjects
                                .any((p) => p == project?.id),
                            activeColor:
                                Theme.of(context).colorScheme.secondary,
                            onChanged: (_) {
                              List<int?> hiddenProjects =
                                  state.hiddenProjects.map((p) => p).toList();
                              if (state.hiddenProjects
                                  .any((p) => p == project?.id)) {
                                hiddenProjects
                                    .removeWhere((p) => p == project?.id);
                              } else {
                                hiddenProjects.add(project!.id);
                              }
                              dashboardBloc.add(
                                  FilterProjectsChangedEvent(hiddenProjects));
                            },
                          )))
                  .toList(),
            ),
          ],
        );
      },
    );
  }
}

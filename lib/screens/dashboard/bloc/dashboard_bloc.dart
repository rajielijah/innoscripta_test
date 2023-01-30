
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/projects/projects_bloc.dart';
import '../../../blocs/settings/settings_bloc.dart';
import '../../../models/project.dart';


part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final ProjectsBloc projectsBloc;
  final SettingsBloc settingsBloc;

  DashboardBloc(this.projectsBloc, this.settingsBloc)
      : super(DashboardState("", projectsBloc.getProjectByID(-1), false,
            settingsBloc.getFilterStartDate(), null, const <int>[], null)) {
    on<DescriptionChangedEvent>((event, emit) {
      emit(DashboardState(
          event.description!,
          state.newProject,
          false,
          state.filterStart,
          state.filterEnd,
          state.hiddenProjects,
          state.searchString));
    });

    on<ProjectChangedEvent>((event, emit) {
      emit(DashboardState(
          state.newDescription,
          event.project,
          false,
          state.filterStart,
          state.filterEnd,
          state.hiddenProjects,
          state.searchString));
    });

    on<TimerWasStartedEvent>((event, emit) {
      Project? newProject = projectsBloc.getProjectByID(-1);
      emit(DashboardState("", newProject, true, state.filterStart,
          state.filterEnd, state.hiddenProjects, state.searchString));
    });

    on<ResetEvent>((event, emit) {
      Project? newProject = projectsBloc.getProjectByID(-1);
      emit(DashboardState("", newProject, false, state.filterStart,
          state.filterEnd, state.hiddenProjects, state.searchString));
    });

    on<FilterStartChangedEvent>((event, emit) {
      final filterStart = event.filterStart;
      DateTime? end = state.filterEnd;
      if (end != null && filterStart != null && filterStart.isAfter(end)) {
        end = filterStart.add(const Duration(
            hours: 23, minutes: 59, seconds: 59, milliseconds: 999));
      }

      emit(DashboardState(state.newDescription, state.newProject, false,
          event.filterStart, end, state.hiddenProjects, state.searchString));
    });

    on<FilterEndChangedEvent>((event, emit) {
      emit(DashboardState(
          state.newDescription,
          state.newProject,
          false,
          state.filterStart,
          event.filterEnd,
          state.hiddenProjects,
          state.searchString));
    });

    on<FilterProjectsChangedEvent>((event, emit) {
      emit(DashboardState(
          state.newDescription,
          state.newProject,
          false,
          state.filterStart,
          state.filterEnd,
          event.projects,
          state.searchString));
    });

    on<SearchChangedEvent>((event, emit) {
      emit(DashboardState(
          state.newDescription,
          state.newProject,
          false,
          state.filterStart,
          state.filterEnd,
          state.hiddenProjects,
          event.search));
    });
  }
}

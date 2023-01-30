
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/projects/bloc.dart';
import '../../../blocs/settings/settings_bloc.dart';
import '../../../screens/dashboard/bloc/dashboard_bloc.dart';
import '../../../screens/dashboard/components/DescriptionField.dart';
import '../../../screens/dashboard/components/ProjectSelectField.dart';
import '../../../screens/dashboard/components/RunningTimers.dart';
import '../../../screens/dashboard/components/StartTimerButton.dart';
import '../../../screens/dashboard/components/StoppedTimers.dart';
import '../../../screens/dashboard/components/TopBar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final projectsBloc = BlocProvider.of<ProjectsBloc>(context);
    final settingsBloc = BlocProvider.of<SettingsBloc>(context);

    return BlocProvider<DashboardBloc>(
        create: (_) => DashboardBloc(projectsBloc, settingsBloc),
        child: Scaffold(
          appBar: const TopBar(),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              const Expanded(
                flex: 1,
                child: StoppedTimers(),
              ),
              const RunningTimers(),
              Material(
                elevation: 8.0,
                color: Theme.of(context).bottomSheetTheme.backgroundColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    //crossAxisAlignment: CrossAxisAlignment.end,
                    children: const <Widget>[
                      ProjectSelectField(),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(4.0, 0, 4.0, 0),
                          child: DescriptionField(),
                        ),
                      ),
                      SizedBox(
                        width: 72,
                        height: 72,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          floatingActionButton: const StartTimerButton(),
        ));
  }
}

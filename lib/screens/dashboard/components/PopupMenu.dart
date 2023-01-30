
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../l10n.dart';
import '../../../screens/export/ExportScreen.dart';
import '../../../screens/projects/ProjectsScreen.dart';
import '../../../screens/reports/ReportsScreen.dart';
import '../../../screens/settings/SettingsScreen.dart';

enum MenuItem {
  projects,
  reports,
  export,
  settings,
}

class PopupMenu extends StatelessWidget {
  const PopupMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MenuItem>(
      key: const Key("menuButton"),
      icon: const Icon(Icons.menu),
      color: Theme.of(context).colorScheme.surface,
      onSelected: (MenuItem item) {
        switch (item) {
          case MenuItem.projects:
            Navigator.of(context).push(MaterialPageRoute<ProjectsScreen>(
              builder: (_) => const ProjectsScreen(),
            ));
            break;
          case MenuItem.reports:
            Navigator.of(context).push(MaterialPageRoute<ReportsScreen>(
              builder: (_) => const ReportsScreen(),
            ));
            break;
          case MenuItem.export:
            Navigator.of(context).push(MaterialPageRoute<ExportScreen>(
              builder: (_) => const ExportScreen(),
            ));
            break;
          case MenuItem.settings:
            Navigator.of(context).push(MaterialPageRoute<SettingsScreen>(
              builder: (_) => const SettingsScreen(),
            ));
            break;
          
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem(
            key: const Key("menuProjects"),
            value: MenuItem.projects,
            child: ListTile(
              leading: const Icon(FontAwesomeIcons.layerGroup),
              title: Text(L10N.of(context).tr.projects),
            ),
          ),
          PopupMenuItem(
            key: const Key("menuReports"),
            value: MenuItem.reports,
            child: ListTile(
              leading: const Icon(FontAwesomeIcons.chartPie),
              title: Text(L10N.of(context).tr.reports),
            ),
          ),
          PopupMenuItem(
            key: const Key("menuExport"),
            value: MenuItem.export,
            child: ListTile(
              leading: const Icon(FontAwesomeIcons.fileExport),
              title: Text(L10N.of(context).tr.exportImport),
            ),
          ),
          PopupMenuItem(
            key: const Key("menuSettings"),
            value: MenuItem.settings,
            child: ListTile(
              leading: const Icon(FontAwesomeIcons.screwdriverWrench),
              title: Text(L10N.of(context).tr.settings),
            ),
          ),
        ];
      },
    );
  }
}

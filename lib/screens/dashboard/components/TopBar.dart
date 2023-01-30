
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../l10n.dart';
import '../../../screens/dashboard/bloc/dashboard_bloc.dart';
import '../../../screens/dashboard/components/FilterButton.dart';
import '../../../screens/dashboard/components/PopupMenu.dart';

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  const TopBar({Key? key}) : super(key: key);

  @override
  State<TopBar> createState() => _TopBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _TopBarState extends State<TopBar> {
  final _searchFormKey = GlobalKey<FormState>();
  TextEditingController? _searchController;
  late bool _searching;

  FocusNode? _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searching = false;
    _searchFocusNode = FocusNode(debugLabel: "search-focus");
    _searchController = TextEditingController(text: "");
  }

  @override
  void dispose() {
    _searchFocusNode!.dispose();
    _searchController!.dispose();
    super.dispose();
  }

  void cancelSearch() {
    setState(() => _searching = false);
    final bloc = BlocProvider.of<DashboardBloc>(context);
    bloc.add(const SearchChangedEvent(null));
  }

  Widget searchBar(BuildContext context) {
    final bloc = BlocProvider.of<DashboardBloc>(context);

    return Form(
        key: _searchFormKey,
        child: TextFormField(
          focusNode: _searchFocusNode,
          controller: _searchController,
          style: Theme.of(context).primaryTextTheme.bodyText1,
          onChanged: (search) {
            bloc.add(SearchChangedEvent(search));
          },
          decoration: InputDecoration(
              prefixIcon: Icon(FontAwesomeIcons.magnifyingGlass,
                  color: Theme.of(context).colorScheme.onPrimary),
              suffixIcon: IconButton(
                color: Theme.of(context).colorScheme.onPrimary,
                icon: const Icon(FontAwesomeIcons.circleXmark),
                onPressed: cancelSearch,
                tooltip: L10N.of(context).tr.cancel,
              )),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<DashboardBloc>(context);

    return AppBar(
        leading: _searching
            ? IconButton(
                icon: const Icon(FontAwesomeIcons.chevronLeft),
                onPressed: cancelSearch,
                tooltip: L10N.of(context).tr.cancel,
              )
            : const PopupMenu(),
        title:
            _searching ? searchBar(context) : Text(L10N.of(context).tr.appName),
        actions: !_searching
            ? <Widget>[
                IconButton(
                  tooltip: L10N.of(context).tr.search,
                  icon: const Icon(FontAwesomeIcons.magnifyingGlass),
                  onPressed: () {
                    _searchController!.text = "";
                    bloc.add(const SearchChangedEvent(""));
                    setState(() => _searching = true);
                    _searchFocusNode!.requestFocus();
                  },
                ),
                const FilterButton(),
              ]
            : <Widget>[]);
  }
}

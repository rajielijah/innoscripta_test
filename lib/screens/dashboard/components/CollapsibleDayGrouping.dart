
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/timer_entry.dart';

class CollapsibleDayGrouping extends StatefulWidget {
  final DateTime date;
  final Iterable<Widget> children;
  final Duration totalTime;
  const CollapsibleDayGrouping(
      {Key? key,
      required this.date,
      required this.children,
      required this.totalTime})
      : super(key: key);

  @override
  State<CollapsibleDayGrouping> createState() => _CollapsibleDayGroupingState();
}

class _CollapsibleDayGroupingState extends State<CollapsibleDayGrouping>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeInTween =
      CurveTween(curve: Curves.easeIn);
  static final Animatable<double> _halfTween =
      Tween<double>(begin: 0.0, end: -0.5);
  static final DateFormat _dateFormat = DateFormat.yMMMMEEEEd();

  late bool _expanded;
  late AnimationController _controller;
  late Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _expanded = DateTime.now().difference(widget.date).inDays.abs() <= 1;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value:
          DateTime.now().difference(widget.date).inDays.abs() <= 1 ? 1.0 : 0.0,
    );
    _iconTurns = _controller.drive(_halfTween.chain(_easeInTween));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded:
          DateTime.now().difference(widget.date).inDays.abs() <= 1,
      onExpansionChanged: (expanded) {
        setState(() {
          _expanded = expanded;
          if (_expanded) {
            _controller.forward();
          } else {
            _controller.reverse();
          }
        });
      },
      title: Text(_dateFormat.format(widget.date),
          style: TextStyle(
            //color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w700,
            fontSize: Theme.of(context).textTheme.bodyText2!.fontSize,
          )),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          RotationTransition(
            turns: _iconTurns,
            child: const Icon(Icons.expand_more),
          ),
          Container(width: 8),
          Text(TimerEntry.formatDuration(widget.totalTime),
              style: TextStyle(
                color:
                    _expanded ? Theme.of(context).colorScheme.secondary : null,
                fontFeatures: const [FontFeature.tabularFigures()],
              )),
        ],
      ),
      children: widget.children.toList(),
    );
  }
}

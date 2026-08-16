import 'package:flutter/widgets.dart';

import '../controller/calendar_event_coordinator.dart';
import '../models/calendar_event.dart';
import '../models/calendar_visible_interval.dart';

/// Builds UI from an asynchronous event snapshot.
typedef CalendarEventConsumerBuilder<T> = Widget Function(
  BuildContext context,
  CalendarEventSnapshot<T> snapshot,
);

/// Lifecycle-safe bridge from [CalendarEventSource] to calendar widgets.
class CalendarEventConsumer<T> extends StatefulWidget {
  /// Creates an event consumer for one visible interval.
  const CalendarEventConsumer({
    super.key,
    required this.source,
    required this.interval,
    required this.builder,
  });

  /// Asynchronous event source.
  final CalendarEventSource<T> source;

  /// Interval requested from [source].
  final CalendarVisibleInterval interval;

  /// Builds from the latest immutable loading snapshot.
  final CalendarEventConsumerBuilder<T> builder;

  @override
  State<CalendarEventConsumer<T>> createState() =>
      _CalendarEventConsumerState<T>();
}

class _CalendarEventConsumerState<T> extends State<CalendarEventConsumer<T>> {
  late CalendarEventCoordinator<T> _coordinator;

  @override
  void initState() {
    super.initState();
    _attach();
  }

  @override
  void didUpdateWidget(covariant CalendarEventConsumer<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      _detach();
      _attach();
    } else if (oldWidget.interval != widget.interval) {
      _coordinator.load(widget.interval);
    }
  }

  void _attach() {
    _coordinator = CalendarEventCoordinator<T>(source: widget.source)
      ..addListener(_changed)
      ..load(widget.interval);
  }

  void _detach() {
    _coordinator
      ..removeListener(_changed)
      ..dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _coordinator.snapshot);
}

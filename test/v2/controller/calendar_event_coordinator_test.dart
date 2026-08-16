import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';

void main() {
  final first = CalendarVisibleInterval(
    DateTime(2026, 8, 3),
    DateTime(2026, 8, 10),
  );
  final second = CalendarVisibleInterval(
    DateTime(2026, 8, 10),
    DateTime(2026, 8, 17),
  );

  test('deduplicates unchanged ready and in-flight requests', () async {
    final source = _ControlledSource<Object?>();
    final coordinator = CalendarEventCoordinator<Object?>(source: source);
    addTearDown(coordinator.dispose);

    final firstLoad = coordinator.load(first);
    coordinator.load(first);
    expect(source.requests, [first]);

    source.completeNext(const []);
    await firstLoad;
    await coordinator.load(first);
    expect(source.requests, [first]);
  });

  test('ignores stale results and keeps only intersecting unique IDs',
      () async {
    final source = _ControlledSource<String>();
    final coordinator = CalendarEventCoordinator<String>(source: source);
    addTearDown(coordinator.dispose);

    final oldLoad = coordinator.load(first);
    final latestLoad = coordinator.load(second);
    source.completeAt(1, [
      CalendarEvent(
        id: 'kept',
        start: DateTime(2026, 8, 11, 9),
        end: DateTime(2026, 8, 11, 10),
      ),
      CalendarEvent(
        id: 'kept',
        start: DateTime(2026, 8, 11, 9),
        end: DateTime(2026, 8, 11, 10),
      ),
      CalendarEvent(
        id: 'outside',
        start: DateTime(2026, 9, 1),
        end: DateTime(2026, 9, 2),
      ),
    ]);
    await latestLoad;
    source.completeAt(0, [
      CalendarEvent(
        id: 'stale',
        start: DateTime(2026, 8, 4),
        end: DateTime(2026, 8, 5),
      ),
    ]);
    await oldLoad;

    expect(coordinator.snapshot.interval, second);
    expect(coordinator.snapshot.events.map((event) => event.id), ['kept']);
  });

  test('exposes errors, refreshes, and tolerates disposal in flight', () async {
    final source = _ControlledSource<Object?>();
    final coordinator = CalendarEventCoordinator<Object?>(source: source);

    final failed = coordinator.load(first);
    source.failNext(StateError('offline'));
    await failed;
    expect(coordinator.snapshot.status, CalendarEventLoadStatus.error);

    final refreshed = coordinator.refresh();
    expect(source.requests, [first, first]);
    coordinator.dispose();
    source.completeNext(const []);
    await refreshed;
  });
}

class _ControlledSource<T> implements CalendarEventSource<T> {
  final requests = <CalendarVisibleInterval>[];
  final _completers = <Completer<List<CalendarEvent<T>>>>[];

  @override
  Future<List<CalendarEvent<T>>> load(CalendarVisibleInterval interval) {
    requests.add(interval);
    final completer = Completer<List<CalendarEvent<T>>>();
    _completers.add(completer);
    return completer.future;
  }

  void completeNext(List<CalendarEvent<T>> events) {
    _completers
        .firstWhere((completer) => !completer.isCompleted)
        .complete(events);
  }

  void completeAt(int index, List<CalendarEvent<T>> events) {
    _completers[index].complete(events);
  }

  void failNext(Object error) {
    _completers
        .firstWhere((completer) => !completer.isCompleted)
        .completeError(error);
  }
}

## Example Usage

### Before AsyncVar:

```dart
class EventListViewModel extends ChangeNotifier {
  final NetworkServiceProtocol service;

  EventListViewModel(this.service)
      : _hostedEventsLoading = false,
        _hostedEvents = [],
        _hostedEventsError = null {
    getHostedEvents();
  }

  bool _hostedEventsLoading;
  bool get hostedEventsLoading => _hostedEventsLoading;
  List<EventGet> _hostedEvents;
  List<EventGet> get hostedEvents => _hostedEvents;
  String? _hostedEventsError;
  String? get hostedEventsError => _hostedEventsError;

  Future<void> getHostedEvents() async {
    _hostedEventsLoading = true;
    _hostedEventsError = null;
    notifyListeners();

    try {
      _hostedEvents = await service.getHostedEvents();
    } catch (e) {
      _hostedEventsError = e.toString();
    }

    _hostedEventsLoading = false;
    notifyListeners();
  }
}
```

### After Refactoring with AsyncVar:

```dart
class EventListViewModel extends ChangeNotifier {
  final NetworkServiceProtocol service;

  late final AsyncVar<List<EventGet>> _hostedEvents;
  List<EventGet> get hostedEvents => _hostedEvents.data ?? [];

  EventListViewModel(this.service) {
    _hostedEvents = AsyncVar<List<EventGet>>(
      operation: () async => service.getHostedEvents(),
      parentNotifier: this,
    );
    _hostedEvents.doIt();
  }
}
```

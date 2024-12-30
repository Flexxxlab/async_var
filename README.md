# AsyncVar

AsyncVar is a simple and efficient solution for managing asynchronous operations in Flutter. It handles loading state, error state, and data state within a single variable, reducing boilerplate code and making your code more concise.

## How to Use
1. Add the AsyncVar class to your project.
2. Refactor your ViewModel to use AsyncVar:
   - Instead of manually managing loading, error, and data variables, use AsyncVar to handle these states automatically.

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
  Future<void> getEvents() => _hostedEvents.executeTask(() => service.getHostedEvents());
  
  EventListViewModel(this.service) {
    _hostedEvents = AsyncVar<List<EventGet>>(parentNotifier: this);
    getEvents();
  }
}
```

## Key Features of AsyncVar:
- **Automatically Manages State**: Handles loading, error, and data states with a single variable.
- **Reduces Boilerplate**: No need to manually manage loading and error flags in your ViewModel.
- **Reactive**: Automatically notifies listeners of state changes.

## Setup:
1. Add AsyncVar to your project by copying the class definition.
2. Initialize AsyncVar in your ViewModel and call `executeTask()` to perform the asynchronous operation.
3. Access the loading, error, and data properties directly from the AsyncVar instance in your ViewModel.

## Methods:
- **executeTask()**: Starts the asynchronous operation and updates the state (loading, data, error).
- **data**: The result of the asynchronous operation.
- **loading**: Indicates whether the operation is still in progress.
- **error**: Holds the error message if the operation fails.

## Conclusion

AsyncVar simplifies asynchronous state management by consolidating loading, error, and data handling into a single variable, making your code cleaner and easier to maintain.

## Additional information

- Contributions: Contributions are welcome! Open an issue or submit a pull request.
- issues: If you encounter any issues, please feel free to reach out to **Email:** irshad365@flexxxlab.com
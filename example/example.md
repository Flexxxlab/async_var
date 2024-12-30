## Example Usage

```dart
class EventListViewModel extends ChangeNotifier {
  final NetworkServiceProtocol service;

  late final AsyncVar<List<EventGet>> _hostedEvents;
  List<EventGet> get hostedEvents => _hostedEvents;
  Future<void> getEvents() => _hostedEvents.executeTask(() => service.getHostedEvents());

  late final AsyncVar _createEvents;
  AsyncVar get createEvents => _createEvents;
  Future<void> createEvents(String name) => _createEvents.executeTask(() => service.postCreateEvent(name));
  
  EventListViewModel(this.service) {
    _hostedEvents = AsyncVar<List<EventGet>>(parentNotifier: this);
    getEvents();
  }
}

/// If you want to display error on screen, you can use .error on a if else like in `(viewModel.hostedEvents.error != null)`
/// If you want to display error on a Snackbar, you can use the string returned back from executeTask() like in `final error = await viewModel.createEvents("New Event");`

class EventListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EventListViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text('Hosted Events')),
      body: Column(
        children: [
          Expanded(
            child: viewModel.hostedEvents.loading
                ? Center(child: CircularProgressIndicator())
                : (viewModel.hostedEvents.error != null)
                ? const Text(viewModel.hostedEvents.error)
                : ListView.builder(
                    itemCount: viewModel.hostedEvents.data.length,
                    itemBuilder: (context, index) {
                      final event = viewModel.hostedEvents.data[index];
                      return ListTile(title: Text(event.name));
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: viewModel.createEvents.loading
                ? Center(child: CircularProgressIndicator())
                :  ElevatedButton(
                    onPressed: () async {
                      final error = await viewModel.createEvents("New Event");
                      if (error != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error)),
                        );
                      } else {
                        viewModel.getEvents();
                      }
                    },
                    child: Text('Create Event'),
                  ),
          ),
        ],
      ),
    );
  }
}
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => EventListViewModel(NetworkService()),
      child: MaterialApp(home: EventListView()),
    ),
  );
}
```

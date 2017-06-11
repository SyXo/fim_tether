class EventEmitter {
  // TODO: weak maps?
  Map<String, List<Function>> _eventListeners = new Map();
  Map<String, List<Function>> _onceEventListeners = new Map();

  void _ensureEventNameIn(Map listeners, String name) {
    if (!listeners.containsKey(name)) {
      listeners[name] = new List();
    }
  }

  void on (String event, void handler(dynamic data)) {
    _ensureEventNameIn(_eventListeners, event);
    _eventListeners[event].add(handler);
  }
  void once (String event, void handler(dynamic data)) {
    _ensureEventNameIn(_onceEventListeners, event);
    _onceEventListeners[event].add(handler);
  }


  void emit (String event, dynamic data) {
    emitAll(_eventListeners, event, data);
    emitAll(_onceEventListeners, event, data);
    _onceEventListeners.remove(event);
  }

  void emitAll (Map listeners, String event, dynamic data) {
    _ensureEventNameIn(_eventListeners, event);
    for (Function handler in _eventListeners[event]) {
      try {
        handler(data);
      } catch (err) {
        // do something?
      }
    }
  }
}

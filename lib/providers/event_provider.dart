import 'package:flutter/foundation.dart';

class EventProvider with ChangeNotifier {
  int? _eventId;

  int? get eventId => _eventId;

  void setEventId(int eventId) {
    _eventId = eventId;
    notifyListeners();
  }
}

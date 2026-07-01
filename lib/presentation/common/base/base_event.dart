abstract class BaseEvent {
  const BaseEvent();
}

class ErrorEvent extends BaseEvent {
  final Object error;

  const ErrorEvent(this.error);
}

//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Tue, Feb 26, 2013 11:05:45 AM
// Author: tomyeh
part of rikulo_async;

///A Stream wrapper
class StreamWrapper<T> implements Stream<T> {
  ///The origin stream
  final Stream<T> origin;
  StreamWrapper(this.origin);

  @override
  bool get isBroadcast => origin.isBroadcast;
  @override
  Stream<T> asBroadcastStream({
    void onListen(StreamSubscription<T> subscription),
    void onCancel(StreamSubscription<T> subscription)})
    => origin.asBroadcastStream(onListen: onListen, onCancel: onCancel);
  @override
  StreamSubscription<T> listen(void onData(T event),
  { void onError(error), void onDone(), bool cancelOnError})
  => origin.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  @override
  Stream<T> where(bool test(T event)) => origin.where(test); 
  @override
  Stream map(convert(T event)) => origin.map(convert);
  @override
  Stream<T> handleError(void handle(error), { bool test(error) })
  => origin.handleError(handle, test: test);
  @override
  Stream expand(Iterable convert(T value)) => origin.expand(convert);
  @override
  Future pipe(StreamConsumer<T> streamConsumer) => origin.pipe(streamConsumer);
  @override
  Stream transform(StreamTransformer<T, dynamic> streamTransformer)
  => origin.transform(streamTransformer);
  @override
  Future reduce(T combine(T previous, T element)) => origin.reduce(combine);
  @override
  Future fold(var initialValue, combine(var previous, T element))
  => origin.fold(initialValue, combine);
  @override
  Future<bool> contains(T match) => origin.contains(match);
  @override
  Future forEach(void action(T element)) => origin.forEach(action);
  @override
  Future<bool> every(bool test(T element)) => origin.every(test);
  @override
  Future<bool> any(bool test(T element)) => origin.any(test);
  @override
  Future<int> get length => origin.length;
  @override
  Future<bool> get isEmpty => origin.isEmpty;
  @override
  Future<List<T>> toList() => origin.toList();
  @override
  Future<Set<T>> toSet() => origin.toSet();
  @override
  Future drain([var futureValue]) => origin.drain(futureValue);
  @override
  Stream<T> take(int count) => origin.take(count);
  @override
  Stream<T> takeWhile(bool test(T value)) => origin.takeWhile(test);
  @override
  Stream<T> skip(int count) => origin.skip(count);
  @override
  Stream<T> skipWhile(bool test(T value)) => origin.skipWhile(test);
  @override
  Stream<T> distinct([bool equals(T previous, T next)]) => origin.distinct(equals);
  @override
  Future<T> get first => origin.first;
  @override
  Future<T> get last => origin.last;
  @override
  Future<T> get single => origin.single;
  @override
  Future<T> firstWhere(bool test(T value), {T defaultValue()})
  => origin.firstWhere(test, defaultValue: defaultValue);
  @override
  Future<T> lastWhere(bool test(T value), {T defaultValue()})
  => origin.lastWhere(test, defaultValue: defaultValue);
  @override
  Future<T> singleWhere(bool test(T value))
  => origin.singleWhere(test);
  @override
  Future<T> elementAt(int index) => origin.elementAt(index);
  @override
  Future<String> join([String separator = ""]) => origin.join(separator);
}

///The StreamConsumer wrapper
class StreamConsumerWrapper<S> implements StreamConsumer<S> {
  ///The original stream consumer
  final StreamConsumer<S> origin;

  StreamConsumerWrapper(this.origin);

  @override
  Future addStream(Stream<S> stream) => origin.addStream(stream);
  @override
  Future close() => origin.close();
}

//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Aug 02, 2013  5:37:48 PM
// Author: tomyeh
part of rikulo_async;

/** Defers the execution of a task.
 * If the key is the same, the task in the second invocation will override
 * the previous. In other words, the previous task is canceled.
 *
 * It is useful if you have a task that happens frequently but you prefer
 * not to execute them all but only the once for a while (because of costly).
 * For example,
 *
 *     defer("cur.task", () {
 *       currentUser.save(["task"]); //a costly operation
 *     }, min: const Duration(seconds: 1), max: const Duration(seconds: 10));
 *     //then, it executes not faster than once per 10s,
 *     //and no later than 100s
 *
 * * [key] - used to identify [task]. If [key] is the same, we consider
 * the task is the same. If different, they are handled separately.
 * * [min] - specifies the minimal duration that the
 * given task will be executed. In short, the task will be invoked
 * [min] milliseconds later if no following invocation with the same key.
 * * [max] - specifies the maximal duration that
 * the given task will be executed. If given (i.e., not null), [task]
 * will be execute at least [max] milliseconds later even if there are
 * following invocations with the same key.
 */
void defer(key, void task(), {Duration min: const Duration(seconds: 1), Duration max}) {
  _deferrer.run(key, task, min, max);
}
class _DeferInfo {
  Timer timer;
  Duration max;
  final DateTime _startedAt;

  _DeferInfo(this.timer, this.max): _startedAt = new DateTime.now();

  bool get isAfterMax
  => max != null && _startedAt.add(max).isBefore(new DateTime.now());
}
class _Deferrer {
  Map<dynamic, _DeferInfo> _defers = new HashMap();

  void run(key, void task(), Duration min, Duration max) {
    final _DeferInfo di = _defers[key];
    if (di == null) {
      _defers[key] = new _DeferInfo(_startTimer(key, task, min), max);
      return;
    }

    di.timer.cancel();
    di.max = max;

    if (di.isAfterMax) {
      _defers.remove(key);
      scheduleMicrotask(task);
    } else {
      di.timer = _startTimer(key, task, min);
    }
  }

  Timer _startTimer(key, void task(), Duration min)
  =>  new Timer(min, () {
    _defers.remove(key);
    task();
  });
}
final _Deferrer _deferrer = new _Deferrer();

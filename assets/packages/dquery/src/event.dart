part of dquery;

// things to fix:
// 1. perform default action
// 2. namespace, multiple types
// 4. replace guid with Expando
// 5. off()

// static helper class
class _EventUtil {
  
  //static Set<String> _global = new HashSet<String>();
  
  // guid management
  // TODO: use expando
  static Map _handleGuid = new HashMap();
  static int _getGuid(handler) =>
      _handleGuid.putIfAbsent(handler, () => _guid++);
  /*
  static bool _hasGuid(handler) =>
      _handleGuid.containsKey(handler);
  static void _copyGuid(handler1, handler2) {
    if (!_hasGuid(handler1) && _hasGuid(handler2))
      _handleGuid[handler1] = _handleGuid[handler2];
  }
  */
  
  static final Expando<String> guids = new Expando<String>();
  
  static void add(EventTarget elem, String types, DQueryEventListener handler, String selector) {
    
    final bool hasSelector = selector != null && !selector.isEmpty;
    
    // jQuery: Don't attach events to noData or text/comment nodes (but allow plain objects)
    if (elem is CharacterData)
      return;
    
    final Map space = _dataPriv.getSpace(elem);
    // if (elemData == null) return;
    
    // jQuery: Make sure that the handler has a unique ID, used to find/remove it later
    final int g = _getGuid(handler); // TODO: need better management
    
    // jQuery: Init the element's event structure and main handler, if this is the first
    final Map<String, _HandleObjectContext> events = 
        space.putIfAbsent('events', () => new HashMap<String, _HandleObjectContext>());
    
    // the joint proxy handler
    final EventListener eventHandle = space.putIfAbsent('handle', () => (Event e) {
      // jQuery: Discard the second event of a jQuery.event.trigger() and
      //         when an event is called after a page has unloaded
      if (e == null || _EventUtil._triggered != e.type)
        dispatch(elem, _EventUtil.fix(e));
    });
    
    // jQuery: Handle multiple events separated by a space
    for (String type in _splitTypes(types)) {
      
      // calculate namespaces
      List<String> namespaces = [];
      if (type.indexOf('.') >= 0) {
        namespaces = type.split('.');
        type = namespaces.removeAt(0);
        namespaces.sort();
      }
      final String origType = type;
      
      // jQuery: There *must* be a type, no attaching namespace-only handlers
      if (type.isEmpty)
        continue;
      
      // jQuery: If event changes its type, use the special event handlers for the changed type
      _SpecialEventHandling special = _getSpecial(type);
      // jQuery: If selector defined, determine special event api type, otherwise given type
      type = _fallback(hasSelector ? special.delegateType : special.bindType, () => type);
      // jQuery: Update special based on newly reset type
      special = _getSpecial(type);
      
      // jQuery: handleObj is passed to all event handlers
      final bool needsContext = hasSelector && _EventUtil._NEEDS_CONTEXT.hasMatch(selector);
      _HandleObject handleObj = new _HandleObject(g, selector, type, origType, 
          namespaces.join('.'), needsContext, handler);
      
      // jQuery: Init the event handler queue if we're the first
      _HandleObjectContext handleObjCtx = events.putIfAbsent(type, () {
        
        // special setup: skipped for now
        elem.addEventListener(type, eventHandle, false);
        return new _HandleObjectContext();
      });
      
      // special add: skipped for now
      (hasSelector ? handleObjCtx.delegates : handleObjCtx.handlers).add(handleObj);
      
      // jQuery: Keep track of which events have ever been used, for event optimization
      //_global.add(type); // TODO: check use
      
    }
    
  }
  
  // jQuery: Detach an event or set of events from an element
  static void remove(EventTarget elem, String types, DQueryEventListener handler, 
                     String selector, [bool mappedTypes = false]) {
    
    final Map<String, _HandleObjectContext> events = _dataPriv.get(elem, 'events');
    if (events == null)
      return;
    
    // jQuery: Once for each type.namespace in types; type may be omitted
    for (String type in _splitTypes(types)) {
      
      // caculate namespaces
      List<String> namespaces = [];
      if (type.indexOf('.') >= 0) {
        namespaces = type.split('.');
        type = namespaces.removeAt(0);
        namespaces.sort();
      }
      final String origType = type;
      
      // jQuery: Unbind all events (on this namespace, if provided) for the element
      if (type.isEmpty) {
        final String ns = namespaces.join('.');
        for (String t in events.keys.toList())
          remove(elem, "$t.$ns", handler, selector, true);
        continue;
      }
      
      _SpecialEventHandling special = _getSpecial(type);
      type = _fallback(selector != null ? special.delegateType : special.bindType, () => type);
      
      _HandleObjectContext handleObjCtx = _fallback(events[type], () => _HandleObjectContext.EMPTY);
      List<_HandleObject> delegates = handleObjCtx.delegates;
      List<_HandleObject> handlers = handleObjCtx.handlers;
      
      // jQuery: Remove matching events
      Function filter = (_HandleObject handleObj) {
        final bool res = 
            (mappedTypes || origType == handleObj.origType) &&
            (handler == null || _getGuid(handler) == handleObj.guid) &&
            _subsetOf(namespaces, handleObj.namespace.split('.')) &&
            (selector == null || selector == handleObj.selector || (selector == '**' && handleObj.selector != null));
        
        // special remove: skipped for now
        
        return res;
      };
      
      delegates.removeWhere(filter);
      handlers.removeWhere(filter);
      
      // jQuery: Remove generic event handler if we removed something and no more handlers exist
      //         (avoids potential for endless recursion during removal of special event handlers)
      if (delegates.isEmpty && handlers.isEmpty) {
        
        // special teardown: skipped for now
        
        events.remove(type);
      }
      
    }
    
  }
  
  static final RegExp _NEEDS_CONTEXT = new RegExp(r'^[\x20\t\r\n\f]*[>+~]');
  
  static bool _subsetOf(List<String> a, List<String> b) {
    // assume a and b are sorted
    Iterator<String> ia = a.iterator;
    for (String sb in b) {
      String sa = ia.current;
      if (sa == null)
        return true;
      int c = sa.compareTo(sb);
      if (c < 0)
        return false;
      if (c == 0)
        ia.moveNext();
    }
    return true;
  }
  
  static final RegExp _SPACES = new RegExp(r'\s+');
  
  static List<String> _splitTypes(String types) {
    return types == null ? [] : types.split(_SPACES);
  }
  
  static bool _focusMorphMatch(String type1, String type2) =>
      (type1 == 'focusin' && type2 == 'focus') || (type1 == 'focusout' && type2 == 'blur');
  
  static String _triggered;
  
  static void trigger(String type, data, EventTarget elem, [bool onlyHandlers = false]) {
    _EventUtil.triggerEvent(new DQueryEvent(type, target: elem, data: data), onlyHandlers);
  }
  
  static void triggerEvent(DQueryEvent event, [bool onlyHandlers = false]) {
    
    EventTarget elem = _fallback(event.target, () => document);
    
    String type = event.type;
    List<String> namespaces = [];
    if (type.indexOf('.') >= 0) {
      namespaces = type.split('.');
      type = namespaces.removeAt(0);
      namespaces.sort();
    }
    
    final String ontype = type.indexOf(':') < 0 ? "on$type" : null; // TODO: check use
    
    final List<Node> eventPath = [elem];
    Window eventPathWindow = null;
    
    // jQuery: Don't do events on text and comment nodes
    if (elem is CharacterData)
      return;
    
    // jQuery: focus/blur morphs to focusin/out; ensure we're not firing them right now
    if (_focusMorphMatch(type, _EventUtil._triggered))
      return;
    
    // jQuery: Trigger bitmask: & 1 for native handlers; & 2 for jQuery (always true)
    //event._isTrigger = onlyHandlers ? 2 : 3;
    if (!namespaces.isEmpty)
      event._namespace = namespaces.join('.');
    event._namespace_re = event.namespace != null ?
        new RegExp( '(^|\\.)${namespaces.join("\\.(?:.*\\.|)")}(\\.|\$)') : null;
    
    // jQuery: Determine event propagation path in advance, per W3C events spec (#9951)
    //         Bubble up to document, then to window; watch for a global ownerDocument var (#9724)
    String bubbleType = null;
    _SpecialEventHandling special = _getSpecial(type);
    if (!onlyHandlers && !special.noBubble && elem is Node) {
      Node n = elem;
      bubbleType = _fallback(special.delegateType, () => type);
      final bool focusMorph = _focusMorphMatch(bubbleType, type);
      
      Node tmp = elem;
      for (Node cur = focusMorph ? n : n.parentNode; cur != null; cur = cur.parentNode) {
        eventPath.add(cur);
        tmp = cur;
      }
      
      // jQuery: Only add window if we got to document (e.g., not plain obj or detached DOM)
      // TODO
      /*
      if (tmp == _fallback(elem.ownerDocument, () => document))
        eventPathWindow = _fallback((tmp as Document).window, () => window);
      */
      
    }
    
    // jQuery: Fire handlers on the event path
    bool first = true;
    for (Node n in eventPath) {
      if (event.isPropagationStopped)
        break;
      event._type = !first ? bubbleType : _fallback(special.bindType, () => type);
      
      // jQuery: jQuery handler
      if (_getEvents(n).containsKey(event.type)) {
        // here we've refactored the implementation apart from jQuery
        _EventUtil.dispatch(n, event);
      }
      
      // native handler is skipped, no way to do it in Dart
      
      first = false;
    }
    /*
    if (eventPathWindow != null) {
      // TODO
    }
    */
    event._type = type;
    
    // jQuery: If nobody prevented the default action, do it now
    if (!onlyHandlers && !event.isDefaultPrevented) {
      if (!(type == "click" && _nodeName(elem, "a"))) {
        // jQuery: Call a native DOM method on the target with the same name name as the event.
        // jQuery: Don't do default actions on window, that's where global variables be (#6170)
        
        if (ontype != null && _hasAction(elem, type)) {
          // jQuery: Prevent re-triggering of the same event, since we already bubbled it above
          _EventUtil._triggered = type;
          _performAction(elem, type);
          _EventUtil._triggered = null;
        }
      }
    }
  }
  
  static void dispatch(EventTarget elem, DQueryEvent dqevent) {
    
    final Map<String, _HandleObjectContext> events = _getEvents(elem);
    final _HandleObjectContext handleObjCtx = _getHandleObjCtx(elem, dqevent.type);
    
    dqevent._delegateTarget = elem;
    
    // jQuery: Determine handlers
    final List<_HandlerQueueEntry> handlerQueue = _EventUtil.handlers(elem, dqevent, handleObjCtx);
    
    for (_HandlerQueueEntry matched in handlerQueue) {
      if (dqevent.isPropagationStopped) break;
      dqevent._currentTarget = matched.elem;
      // copy to avoid concurrent modification
      for (_HandleObject handleObj in new List<_HandleObject>.from(matched.handlers)) {
        if (dqevent.isImmediatePropagationStopped) break;
        // jQuery: Triggered event must either 1) have no namespace, or
        //         2) have namespace(s) a subset or equal to those in the bound event (both can have no namespace).
        if (dqevent.namespace_re == null || dqevent.namespace_re.hasMatch(handleObj.namespace)) {
          final List<String> eventns = dqevent.namespace == null ? [] : dqevent.namespace.split('.');
          final List<String> hobjns = handleObj.namespace == null ? [] : handleObj.namespace.split('.');
          if (_subsetOf(eventns, hobjns)) {
            dqevent._handleObj = handleObj;
            handleObj.handler(dqevent);
          }
        }
      }
    }
    
  }
  
  static List<_HandlerQueueEntry> handlers(EventTarget elem, DQueryEvent dqevent, 
      _HandleObjectContext handleObjCtx) {
    
    final List<_HandlerQueueEntry> handlerQueue = new List<_HandlerQueueEntry>();
    final List<_HandleObject> delegates = handleObjCtx.delegates;
    final List<_HandleObject> handlers = handleObjCtx.handlers;
    EventTarget cur = dqevent.target;
    
    // jQuery: Find delegate handlers
    //         Black-hole SVG <use> instance trees (#13180)
    //         Avoid non-left-click bubbling in Firefox (#3861)
    // src: if ( delegateCount && cur.nodeType && (!event.button || event.type !== "click") ) {
    if (!delegates.isEmpty && cur is Node) { // TODO: fix
      
      for (; cur != elem; cur = _fallback(parentNode(cur), () => elem)) {
        
        // jQuery: Don't process clicks on disabled elements (#6911, #8165, #11382, #11764)
        // TODO: uncomment later
        /*
        if (dqevent.type == "click" && h.isDisabled(cur))
          continue;
        */
        
        final Map<String, bool> matches = new HashMap<String, bool>();
        final List<_HandleObject> matched = new List<_HandleObject>();
        for (_HandleObject handleObj in delegates) {
          final String sel = "${trim(handleObj.selector)} ";
          if (matches.putIfAbsent(sel, () => (cur is Element) &&
              (handleObj.needsContext ? $(sel, elem).contains(cur) : 
              (cur as Element).matches(sel)))) {
            matched.add(handleObj);
          }
        }
        
        if (!matched.isEmpty) {
          handlerQueue.add(new _HandlerQueueEntry(cur, matched));
        }
        
      }
    }
    
    // jQuery: Add the remaining (directly-bound) handlers
    if (!handlers.isEmpty) {
      handlerQueue.add(new _HandlerQueueEntry(elem, handlers));
    }
    
    return handlerQueue;
  }
  
  static EventTarget parentNode(EventTarget target) =>
      target is Node ? target.parentNode : null;
  
  static DQueryEvent fix(Event event) {
    // TODO: find properties to copy from fix hook
    final DQueryEvent dqevent = new DQueryEvent.from(event);
    
    // jQuery: Support: Chrome 23+, Safari?
    //         Target should not be a text node (#504, #13143)
    if (dqevent._target is Text)
      dqevent._target = (dqevent._target as Text).parentNode;
    
    // TODO: filter by fixHook
    return dqevent;
  }
  
  static Map<String, _HandleObjectContext> _getEvents(EventTarget elem) =>
      _fallback(_dataPriv.get(elem, 'events'), () => {});
  
  static _HandleObjectContext _getHandleObjCtx(EventTarget elem, String type) =>
      _fallback(_getEvents(elem)[type], () => _HandleObjectContext.EMPTY);
  
  // TODO: later
  /*
  static void simulate(String type, EventTarget elem, event, bool bubble) {
    // jQuery: Piggyback on a donor event to simulate a different one.
    //         Fake originalEvent to avoid donor's stopPropagation, but if the
    //         simulated event prevents default then we do the same on the donor.
    
    DQueryEvent e;
    // TODO
    /*
    var e = jQuery.extend(
        new jQuery.Event(),
        event,
        {
          type: type,
          isSimulated: true,
          originalEvent: {}
        }
    );
    */
    if (bubble)
      _EventUtil.trigger(e, null, elem);
    else
      _EventUtil.dispatch(elem, e);
    
    if (e.isDefaultPrevented)
      event.preventDefault();
    
  }
  */
  
}

/*
// Create "bubbling" focus and blur events
// Support: Firefox, Chrome, Safari
if ( !jQuery.support.focusinBubbles ) {
  jQuery.each({ focus: "focusin", blur: "focusout" }, function( orig, fix ) {

    // Attach a single capturing handler while someone wants focusin/focusout
    var attaches = 0,
      handler = function( event ) {
        jQuery.event.simulate( fix, event.target, jQuery.event.fix( event ), true );
      };
  
    jQuery.event.special[ fix ] = {
      setup: function() {
        if ( attaches++ === 0 ) {
          document.addEventListener( orig, handler, true );
        }
      },
      teardown: function() {
        if ( --attaches === 0 ) {
          document.removeEventListener( orig, handler, true );
        }
      }
    };
  });
}
*/

class _HandleObjectContext {
  
  final List<_HandleObject> delegates = new List<_HandleObject>();
  final List<_HandleObject> handlers = new List<_HandleObject>();
  
  static final _HandleObjectContext EMPTY = new _HandleObjectContext();
  
}

class _HandlerQueueEntry {
  
  final EventTarget elem;
  final List<_HandleObject> handlers;
  
  _HandlerQueueEntry(this.elem, this.handlers);
  
}

class _HandleObject {
  
  _HandleObject(this.guid, this.selector, this.type, this.origType, this.namespace,
      this.needsContext, this.handler);
  
  final int guid;
  final String selector, type, origType, namespace;
  final bool needsContext;
  final DQueryEventListener handler;
  
}

class _SpecialEventHandling {
  
  _SpecialEventHandling({bool noBubble: false, String delegateType, 
    String bindType, bool trigger(EventTarget t, data)}) :
  this.noBubble = noBubble,
  this.delegateType = delegateType,
  this.bindType = bindType,
  this.trigger = trigger;
  
  final bool noBubble;
  //Function setup, add, remove, teardown; // void f(Element elem, _HandleObject handleObj) 
  final Function trigger; // bool f(Element elem, data)
  //Function _default; // bool f(Document document, data)
  final String delegateType, bindType;
  //DQueryEventListener postDispatch, handle;
  
  static final _SpecialEventHandling EMPTY = new _SpecialEventHandling();
  
}

Element _activeElement() {
  try {
    return document.activeElement;
  } catch (err) {}
}

_SpecialEventHandling _getSpecial(String type) =>
  _fallback(_SPECIAL_HANDLINGS[type], () => _SpecialEventHandling.EMPTY);

final Map<String, _SpecialEventHandling> _SPECIAL_HANDLINGS = new HashMap<String, _SpecialEventHandling>.from({
  // jQuery: Prevent triggered image.load events from bubbling to window.load
  'load': new _SpecialEventHandling(noBubble: true),
  
  'click': new _SpecialEventHandling(trigger: (EventTarget elem, data) {
    // jQuery: For checkbox, fire native event so checked state will be right
    if (elem is CheckboxInputElement) {
      elem.click();
      return false;
    }
    return true;
  }),
  
  'focus': new _SpecialEventHandling(trigger: (EventTarget elem, data) {
    // jQuery: Fire native event if possible so blur/focus sequence is correct
    if (elem != _activeElement() && elem is Element) {
      elem.focus();
      return false;
    }
    return true;
  }, delegateType: 'focusin'),
  
  'blur': new _SpecialEventHandling(trigger: (EventTarget elem, data) {
    if (elem == _activeElement()) {
      (elem as Element).blur();
      return false;
    }
    return true;
  }, delegateType: 'focusout')
});

/** The handler type for [DQueryEvent], which is the DQuery analogy of 
 * [EventListener].
 */
typedef void DQueryEventListener(DQueryEvent event); 

/** A wrapping of browser [Event], to attach more information such as custom
 * event data and name space, etc. 
 */
class DQueryEvent {
  
  /** The time stamp at which the event occurs. If the event is constructed 
   * from a native DOM [Event], it uses the time stamp of that event;
   * otherwise it uses the current time where this event is constructed. 
   */
  final int timeStamp;
  
  /** The original event, if any. If this [DQueryEvent] was triggered by browser,
   * it will contain an original event; if triggered by API, this property will
   * be null.
   */
  final Event originalEvent;
  
  /** The type of event. If the event is constructed from a native DOM [Event], 
   * it uses the type of that event.
   */
  String get type => _type;
  String _type;
  
  /** Custom event data. If user calls trigger method with data, it will show 
   * up here.
   */
  var data;
  
  /** The delegate target of this event. i.e. The event target on which the 
   * handler is registered.
   */
  EventTarget get delegateTarget => _delegateTarget;
  EventTarget _delegateTarget;
  
  /** The current target of this event when bubbling up.
   */
  EventTarget get currentTarget => _currentTarget;
  EventTarget _currentTarget;
  
  /** The original target of this event. i.e. The real event target where the
   * event occurs.
   */
  EventTarget get target => _target;
  EventTarget _target;
  
  /** The namespace of this event. For example, if the event is triggered by 
   * API with name `click.a.b.c`, it will have type `click` with namespace `a.b.c`
   */
  String get namespace => _namespace;
  String _namespace; // TODO: maybe should be List<String> ?
  
  RegExp get namespace_re => _namespace_re;
  RegExp _namespace_re;
  
  _HandleObject _handleObj;
  final Event _simulatedEvent; // TODO: check usage
  
  //int _isTrigger; // TODO: check usage
  
  //final Map attributes = new HashMap();
  
  /** Construct a DQueryEvent from a native browser event.
   */
  DQueryEvent.from(Event event, {data}) : 
  this._(event, null, event.type, event.target, event.timeStamp, data);
  
  /** Construct a DQueryEvent with given [type].
   */
  DQueryEvent(String type, {EventTarget target, data}) : 
  this._(null, new Event(type), type, target, _now(), data); // TODO: move target away
  
  DQueryEvent._(this.originalEvent, this._simulatedEvent, this._type, 
      this._target, this.timeStamp, this.data);
  
  /// Return true if [preventDefault] was ever called in this event.
  bool get isDefaultPrevented => _isDefaultPrevented;
  bool _isDefaultPrevented = false;
  
  /// Return true if [stopPropagation] was ever called in this event.
  bool get isPropagationStopped => _isPropagationStopped;
  bool _isPropagationStopped = false;
  
  /// Return true if [stopImmediatePropagation] was ever called in this event.
  bool get isImmediatePropagationStopped => _isImmediatePropagationStopped;
  bool _isImmediatePropagationStopped = false;
  
  /** Prevent the default action of the event being triggered.
   */
  void preventDefault() {
    _isDefaultPrevented = true;
    if (originalEvent != null)
      originalEvent.preventDefault();
  }
  
  /** Prevent the event from bubbling up, and prevent any handlers on parent
   * elements from being called. 
   */
  void stopPropagation() {
    _isPropagationStopped = true;
    if (originalEvent != null)
      originalEvent.stopPropagation();
  }
  
  /** Prevent the event from bubbling up, and prevent any succeeding handlers
   * from being called. 
   */
  void stopImmediatePropagation() {
    _isImmediatePropagationStopped = true;
    stopPropagation();
  }
  
}

// TODO: check 661-711 browser hack

part of dquery;

Point _getOffset(Element elem) {
  
  if (elem == null)
    return null;
  
  final Document doc = elem.ownerDocument;
  if (doc == null)
    return null;
  
  Point box = new Point(0, 0);
  final Element docElem = doc.documentElement;
  // jQuery: Make sure it's not a disconnected DOM node
  /*
  if ( !jQuery.contains( docElem, elem ) ) {
    return box;
  }
  */
  
  // skipped
  // jQuery: If we don't have gBCR, just use 0,0 rather than error
  //         BlackBerry 5, iOS 3 (original iPhone)
  //if ( typeof elem.getBoundingClientRect !== core_strundefined )
  final Rectangle r = elem.getBoundingClientRect();
  box = new Point(r.left, r.top);
  
  return box + new Point(window.pageXOffset, window.pageYOffset) - docElem.client.topLeft;
}

//setOffset: function( elem, options, i ) {
void _setOffset(Element elem, {num left, num top}) {
  if (left == null && top == null)
    return;
  
  final String position = _getCss(elem, 'position');
  
  // jQuery: Set position first, in-case top/left are set even on static elem
  if (position == 'static')
    elem.style.position = 'relative';
  
  final Point curOffset = _getOffset(elem);
  final String curCSSTop = _getCss(elem, 'top');
  final String curCSSLeft = _getCss(elem, 'left');
  
  // jQuery: Need to be able to calculate position if either top or left is auto 
  //         and position is either absolute or fixed
  final bool calculatePosition = 
      (position == 'absolute' || position == 'fixed') && 
      ("$curCSSTop $curCSSLeft").indexOf("auto") > -1;
  final Point curPosition = calculatePosition ? _getPosition(elem) : null;
  
  // skipped for now
  /*
  if ( jQuery.isFunction( options ) ) {
    options = options.call( elem, i, curOffset );
  }
  */
  
  // skipped
  /*
  if ( "using" in options ) {
    options.using.call( elem, props );
  }
  */
  
  if (left != null) {
    final num curLeft = calculatePosition ? curPosition.x : _parseDouble(curCSSLeft);
    elem.style.left = "${left - curOffset.x + curLeft}px";
  }
  
  if (top != null) {
    final num curTop = calculatePosition ? curPosition.y : _parseDouble(curCSSTop);
    elem.style.top = "${top - curOffset.y + curTop}px";
  }
  
}

Point _getPosition(Element elem) {
  if (elem == null)
    return null;
  
  final ElementQuery $elem = $(elem);
  Point offset;
  Point parentOffset = new Point(0, 0);
  
  // jQuery: Fixed elements are offset from window (parentOffset = {top:0, left: 0}, because it is it's only offset parent
  if (_getCss(elem, 'position') == 'fixed') {
    // jQuery: We assume that getBoundingClientRect is available when computed position is fixed
    offset = elem.getBoundingClientRect().topLeft;
    
  } else {
    // jQuery: Get *real* offsetParent
    final Element offsetParent = _getOffsetParent(elem);
    
    // jQuery: Get correct offsets
    offset = elem.offset.topLeft;
    if (offsetParent.tagName != 'html')
      parentOffset = offsetParent.offset.topLeft;
    
    // jQuery: Add offsetParent borders
    parentOffset += _parseCssPoint(offsetParent, 'borderLeftWidth', 'borderTopWidth', 0, 0);
  }
  
  // jQuery: Subtract parent offsets and element margins
  return offset + parentOffset - _parseCssPoint(elem, 'marginLeft', 'marginTop', 0, 0);
}

Point _parseCssPoint(Element elem, String nameX, String nameY, [num defaultX, num defaultY]) =>
    new Point(_parseCss(elem, nameX, defaultX), _parseCss(elem, nameY, defaultY));

num _parseCss(Element elem, String name, num defaultValue) =>
    _parseDouble(_getCss(elem, name), defaultValue); // TODO: double.parse() is different from parseFloat()

num _parseDouble(String src, [num defaultValue = 0.0]) =>
    double.parse(_trimSuffix(src, 'px'), (String source) => defaultValue);

String _trimSuffix(String src, String suffix) =>
    src == null ? null :
    src.endsWith(suffix) ? src.substring(0, src.length - suffix.length) : src;

Element _getOffsetParent(Element elem) {
  Element offsetParent = elem.offsetParent;
  if (offsetParent == null)
    offsetParent = document.documentElement;
  
  while (offsetParent != null && (offsetParent.tagName != 'html') && 
      _getCss(offsetParent, "position") == 'static') {
    offsetParent = offsetParent.offsetParent;
  }
  
  if (offsetParent == null)
    offsetParent = document.documentElement;
  return offsetParent;
}

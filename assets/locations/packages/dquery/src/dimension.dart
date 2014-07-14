part of dquery;
/*
// Create innerHeight, innerWidth, height, width, outerHeight and outerWidth methods
jQuery.each( { Height: "height", Width: "width" }, function( name, type ) {
  jQuery.each( { padding: "inner" + name, content: type, "": "outer" + name }, function( defaultExtra, funcName ) {
    // margin is only for outerHeight, outerWidth
    jQuery.fn[ funcName ] = function( margin, value ) {
      var chainable = arguments.length && ( defaultExtra || typeof margin !== "boolean" ),
        extra = defaultExtra || ( margin === true || value === true ? "margin" : "border" );
      
      return jQuery.access( this, function( elem, type, value ) {
        var doc;
        
        return value === undefined ?
        // Get width or height on the element, requesting but not forcing parseFloat
          jQuery.css( elem, type, extra ) :
          
          // Set width or height on the element
          jQuery.style( elem, type, value, extra );
      }, type, chainable ? margin : undefined, chainable, null );
    };
  });
});
*/

/*
function getWidthOrHeight( elem, name, extra ) {
  
  // Start with offset property, which is equivalent to the border-box value
  var valueIsBorderBox = true,
    val = name === "width" ? elem.offsetWidth : elem.offsetHeight,
    styles = getStyles( elem ),
    isBorderBox = jQuery.support.boxSizing && jQuery.css( elem, "boxSizing", false, styles ) === "border-box";

    // some non-html elements return undefined for offsetWidth, so check for null/undefined
    // svg - https://bugzilla.mozilla.org/show_bug.cgi?id=649285
    // MathML - https://bugzilla.mozilla.org/show_bug.cgi?id=491668
    if ( val <= 0 || val == null ) {
      // Fall back to computed then uncomputed css if necessary
      val = curCSS( elem, name, styles );
      if ( val < 0 || val == null ) {
        val = elem.style[ name ];
      }
      
      // Computed unit is not pixels. Stop here and return.
      if ( rnumnonpx.test(val) ) {
        return val;
      }
      
      // we need the check for style in case a browser which returns unreliable values
      // for getComputedStyle silently falls back to the reliable elem.style
      valueIsBorderBox = isBorderBox && ( jQuery.support.boxSizingReliable || val === elem.style[ name ] );
      
      // Normalize "", auto, and prepare for extra
      val = parseFloat( val ) || 0;
    }
    
    // use the active box-sizing model to add/subtract irrelevant styles
    return ( val +
      augmentWidthOrHeight(
        elem,
        name,
        extra || ( isBorderBox ? "border" : "content" ),
        valueIsBorderBox,
        styles
      )
    ) + "px";
}
*/

/*
function augmentWidthOrHeight( elem, name, extra, isBorderBox, styles ) {
  var i = extra === ( isBorderBox ? "border" : "content" ) ?
    // If we already have the right measurement, avoid augmentation
    4 :
    // Otherwise initialize for horizontal or vertical properties
    name === "width" ? 1 : 0,
    
    val = 0;

  for ( ; i < 4; i += 2 ) {
    // both box models exclude margin, so add it if we want it
    if ( extra === "margin" ) {
      val += jQuery.css( elem, extra + cssExpand[ i ], true, styles );
    }
    
    if ( isBorderBox ) {
      // border-box includes padding, so remove it if we want content
      if ( extra === "content" ) {
        val -= jQuery.css( elem, "padding" + cssExpand[ i ], true, styles );
      }
      
      // at this point, extra isn't border nor margin, so remove border
      if ( extra !== "margin" ) {
        val -= jQuery.css( elem, "border" + cssExpand[ i ] + "Width", true, styles );
      }
    } else {
      // at this point, extra isn't content, so add padding
      val += jQuery.css( elem, "padding" + cssExpand[ i ], true, styles );
      
      // at this point, extra isn't content nor padding, so add border
      if ( extra !== "padding" ) {
        val += jQuery.css( elem, "border" + cssExpand[ i ] + "Width", true, styles );
      }
    }
  }
  
  return val;
}
*/

int _getElementWidth(Element elem, [extra]) {
  // TODO: box-sizing
  // TODO: extra: content, padding, border, margin
  return elem.offsetWidth;
}

int _getElementHeight(Element elem, [extra]) {
  // TODO: box-sizing
  // TODO: extra: content, padding, border, margin
  return elem.offsetHeight;
}

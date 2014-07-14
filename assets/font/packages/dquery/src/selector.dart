part of dquery;

// TODO: unique requires sorting
/* src:
selector_sortOrder = function( a, b ) {
  // Flag for duplicate removal
  if ( a === b ) {
    selector_hasDuplicate = true;
    return 0;
  }

  var compare = b.compareDocumentPosition && a.compareDocumentPosition && a.compareDocumentPosition( b );

  if ( compare ) {
    // Disconnected nodes
    if ( compare & 1 ) {

      // Choose the first element that is related to our document
      if ( a === document || jQuery.contains(document, a) ) {
        return -1;
      }
      if ( b === document || jQuery.contains(document, b) ) {
        return 1;
      }
  
      // Maintain original order
      return 0;
    }
  
    return compare & 4 ? -1 : 1;
  }

  // Not directly comparable, sort on existence of method
  return a.compareDocumentPosition ? -1 : 1;
};
*/

List<Element> _unique(List<Element> elements) {
  // USE our own implementation
  // TODO: need to sort/preserve order
  return elements.toSet().toList(growable: true);
}

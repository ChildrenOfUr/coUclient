//Copyright (C) 2012 Potix Corporation. All Rights Reserved.
//History: Tue, Jun 05, 2012  9:16:58 AM
// Author: tomyeh
part of rikulo_util;

/** A readonly and empty list.
 */
const List EMPTY_LIST = const [];
/** A readonly and empty iterator.
 */
const Iterator EMPTY_ITERATOR = const _EmptyIter();
/** A readonly and empty set.
 */
final Set EMPTY_SET = EMPTY_LIST.toSet();

class _EmptyIter<T> implements Iterator<T> {
  const _EmptyIter();

  @override
  T get current => null;
  @override
  bool moveNext() => false;
}

/** List utilities.
 */
class ListUtil {
  ///Copy a list ([src]) to another ([dst])
  static List copy(List src, int srcStart,
                   List dst, int dstStart, int count) {
    if (srcStart < dstStart) {
      for (int i = srcStart + count - 1, j = dstStart + count - 1;
           i >= srcStart; i--, j--) {
        dst[j] = src[i];
      }
    } else {
      for (int i = srcStart, j = dstStart; i < srcStart + count; i++, j++) {
        dst[j] = src[i];
      }
    }
    return dst;
  }

  /** Compares if a list equals another
   *
	 * * [equal] - the closure to compare elements in the given lists.
   * If omitted, it compares each item in the list with `identical()`.
   */
  static bool areEqual(List al, bl, [bool equal(a, b)]) {
    if (identical(al, bl))
      return true;
    if (!(bl is List))
      return false;

    final bl2 = bl as List,
    	length = al.length;
    if (length != bl2.length)
      return false;

    if (equal == null)
      equal = identical;
    for (int i = 0; i < length; i++) {
      if (!equal(al[i], bl2[i]))
        return false;
    }
    return true;
  }

  /** Returns the hash code of the given list
   */
  static int getHashCode(Iterable iterable) {
    final int prime = 31;
    int code = 0;
    if (iterable != null) {
      code = 1 + iterable.length;
      for (final v in iterable)
        code = code * prime + (v != null ? v.hashCode: 0);
    }
    return code;
  }
}

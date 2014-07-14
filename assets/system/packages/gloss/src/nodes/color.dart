part of nodes;

class Color extends Node {
  factory Color(String hash) {
    bool single = hash.length == 3;
    num r = int.parse('0x${single ? '${hash[0]}${hash[0]}' : hash.substring(0, 2)}'),
        g = int.parse('0x${single ? '${hash[1]}${hash[1]}' : hash.substring(2, 4)}'),
        b = int.parse('0x${single ? '${hash[2]}${hash[2]}' : hash.substring(4, 6)}');

    return new RGBA(r, g, b, 1);
  }
}

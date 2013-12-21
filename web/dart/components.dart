part of coUclient;

class Position extends ComponentPoolable {
  num x, y, z;
  Position._();
  factory Position(num x, num y, num z) {
    Position position = new Poolable.of(Position, _constructor);
    position.x = x;
    position.y = y;
    position.z = z;
    return position;
  }
  static Position _constructor() => new Position._();
}
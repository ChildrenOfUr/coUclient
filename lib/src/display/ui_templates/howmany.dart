part of couclient;

class HowManyMenu {
  static Element create(MouseEvent Click, String action, {String itemName: ''}) {
    destroy();

    action = action.substring(0, 1).toUpperCase() + action.substring(1);

    int num = 0;

    DivElement menu = new DivElement()
      ..id = 'HowManyMenu';
    SpanElement title = new SpanElement()
      ..id = 'hm-title'
      ..text = action + ' how many ' + itemName + 's?';
    DivElement controls = new DivElement()
      ..id = 'hm-controls';
    ButtonElement minus = new ButtonElement()
      ..id = 'hm-minus'
      ..classes.add('hm-btn')
      ..text = '-';
    ButtonElement plus = new ButtonElement()
      ..id = 'hm-plus'
      ..classes.add('hm-btn')
      ..text = '+';
    InputElement number = new InputElement()
      ..id = 'hm-num'
      ..text = num.toString();
    ButtonElement enter = new ButtonElement()
      ..id = 'hm-enter'
      ..classes.add('hm-btn')
      ..text = action + ' ' + num.toString();

    // do stuff

    controls
      ..append(minus)
      ..append(number)
      ..append(plus);
    menu
      ..append(title)
      ..append(controls)
      ..append(enter);

    document.body.append(menu);

    int x, y;

    if(Click != null) {
      if (Click.page.y > window.innerHeight / 2) {
        y = Click.page.y - menu.clientHeight;
      } else {
        y = Click.page.y - 10;
      }
      if (Click.page.x > window.innerWidth / 2) {
        x = Click.page.x - 120;
      } else {
        x = Click.page.x - 10;
      }
    } else {
      num posX = CurrentPlayer.posX, posY = CurrentPlayer.posY;
      int width = CurrentPlayer.width, height = CurrentPlayer.height;
      num translateX = posX, translateY = view.worldElement.clientHeight - height;
      if(posX > currentStreet.bounds.width - width / 2 - view.worldElement.clientWidth / 2) {
        translateX = posX - currentStreet.bounds.width + view.worldElement.clientWidth;
      } else if(posX + width / 2 > view.worldElement.clientWidth / 2) {
        translateX = view.worldElement.clientWidth / 2 - width / 2;
      }
      if(posY + height / 2 < view.worldElement.clientHeight / 2) {
        translateY = posY;
      } else if(posY < currentStreet.bounds.height - height / 2 - view.worldElement.clientHeight / 2) {
        translateY = view.worldElement.clientHeight / 2 - height / 2;
      } else {
        translateY = view.worldElement.clientHeight - (currentStreet.bounds.height - posY);
      }
      x = (translateX + menu.clientWidth + 10) ~/ 1;
      y = (translateY + height / 2) ~/ 1;

      menu.style
        ..opacity = '1.0'
        ..position = 'absolute'
        ..top = y.toString() + ' px'
        ..left = x.toString() + ' px';
    }

    return menu;
  }

  static void destroy() {
    Element menu = querySelector('#HowManyMenu');
    if(menu != null) menu.remove();
  }
}
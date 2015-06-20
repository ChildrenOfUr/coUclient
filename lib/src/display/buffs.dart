part of couclient;

buff(String type) {
  Element buffContainer = querySelector('#buffHolder');
  String message, messageInfo, iconUrl;
  int length;
  int numBuffs = 0;
  bool fullOfPie, doubleQuoins;

  switch (type) {
    case 'pie':
      message = "Full of Pie";
      messageInfo = "Jump height decreased";
      fullOfPie = true; // checked when jumping to cut down height
      length = 30;
      break;
    case 'quoin':
      message = "Double Quoin";
      messageInfo = "Quoin values are doubled";
      doubleQuoins = true;
      length = 600;
      break;
    default:
      message = "";
      messageInfo = "";
      length = 0;
      break;
  }

  print(doubleQuoins.toString());

  DivElement buff = new DivElement()
    ..classes.add('toast')
    ..classes.add('buff')
    ..style.opacity = '0.5'
    ..text = '';
  ImageElement icon = new ImageElement()
    ..src = "";
  SpanElement text = new SpanElement()
    ..text = '<span>' + message + '</span><br><span>' + messageInfo + '</span>';
  buff.append(icon);
  buff.append(text);
  numBuffs++;

  removeBuff(Element buff) {
    buff.remove;
    switch (type) {
      case 'pie':
        fullOfPie = false;
        break;
      case 'quoin':
        doubleQuoins = false;
        break;
    }
    numBuffs--;
  }

  if (numBuffs > 0) {
    querySelector("#toastDivider").style.visibility = "visible";
  } else {
    querySelector("#toastDivider").style.visibility = "hidden";
  }

  Duration timeOpacity = new Duration(milliseconds: length);
  Duration timeHide = new Duration(milliseconds: timeOpacity.inMilliseconds + 500);
  new Timer(timeOpacity, () { buff.style.opacity = '0'; });
  new Timer(timeHide, removeBuff(buff));

  buffContainer.append(buff);
}

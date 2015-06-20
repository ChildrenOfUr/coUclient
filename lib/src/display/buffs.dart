part of couclient;

bool fullOfPie, doubleQuoins;

buff(String type) {
  Element buffContainer = querySelector('#buffHolder');
  String message, messageInfo, iconUrl;
  int length;

  switch (type) {
    case 'pie':
      message = "Full of Pie";
      messageInfo = "Jump height decreased";
      fullOfPie = true; // checked when jumping to cut down height
      length = 30;
      break;
    case 'quoin':
      message = "Double Quoins";
      messageInfo = "Quoin values are doubled";
      doubleQuoins = true;
      length = 600;
      break;
    default:
      return;
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
    ..innerHtml = message
    ..title = messageInfo;
  buff.append(icon);
  buff.append(text);

  updateNotifs(DivElement buff) {
    buff.remove();

    switch (type) {
      case 'pie':
        fullOfPie = false;
        break;
      case 'quoin':
        doubleQuoins = false;
        break;
    }

    if (querySelector("#buffHolder").children.length > 0 && querySelector("#toastHolder").children.length > 0) {
      querySelector("#toastDivider").style.display = "block";
    } else {
      querySelector("#toastDivider").style.display = "none";
    }
  }

  Duration timeOpacity = new Duration(seconds: length);
  Duration timeHide = new Duration(milliseconds: timeOpacity.inMilliseconds + 500);
  new Timer(timeOpacity, () { buff.style.opacity = '0'; });
  new Timer(timeHide, updateNotifs(buff));

  buffContainer.append(buff);

  if (querySelector("#buffHolder").children.length > 0 && querySelector("#toastHolder").children.length > 0) {
    querySelector("#toastDivider").style.display = "block";
  } else {
    querySelector("#toastDivider").style.display = "none";
  }
}

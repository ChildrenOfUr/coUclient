part of couclient;

toast(String message) {
  Element toastContainer = querySelector('#toastHolder');

  DivElement toast = new DivElement()
      ..classes.add('toast')
      ..style.opacity = '0.5'
      ..text = message;

  int textTime = 1000 + (toast.text.length * 100);
  if (textTime > 30000) {
    textTime = 30000;
  }

  updateNotifs(DivElement toast) {
    toast.remove();

    if (querySelector("#buffHolder").children.length > 0 && querySelector("#toastHolder").children.length > 0) {
      querySelector("#toastDivider").style.display = "block";
    } else {
      querySelector("#toastDivider").style.display = "none";
    }
  }

  Duration timeOpacity = new Duration(milliseconds: textTime);
  Duration timeHide = new Duration(milliseconds: timeOpacity.inMilliseconds + 500);

  new Timer(timeOpacity, () {
    toast.style.opacity = '0';
  });
  new Timer(timeHide, updateNotifs(toast));

  toastContainer.append(toast);
}

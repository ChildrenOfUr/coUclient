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

  Duration timeOpacity = new Duration(milliseconds: textTime);
  Duration timeHide = new Duration(milliseconds: timeOpacity.inMilliseconds + 500);

  new Timer(timeOpacity, () {
    toast.style.opacity = '0';
  });
  new Timer(timeHide, toast.remove);

  toastContainer.append(toast);
}

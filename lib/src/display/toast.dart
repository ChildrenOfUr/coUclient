part of couclient;

toast(String message) {
  Element toastContainer = querySelector('#toastHolder');

  DivElement toast = new DivElement()
      ..classes.add('toast')
      ..style.opacity = '0.35'
      ..text = message;

  new Timer(new Duration(milliseconds: 5000), () {
    toast.style.opacity = '0';
  });
  new Timer(new Duration(milliseconds: 5500), toast.remove);

  toastContainer.append(toast);
}

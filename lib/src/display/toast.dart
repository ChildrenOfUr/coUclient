part of couclient;

Service toastService = new Service(spawnToast);

spawnToast(Moment event) {
  if (event.isType(#toast)) {

    Element toastContainer = querySelector('#toastHolder');

    DivElement toast = new DivElement()
        ..classes.add('toast')
        ..style.opacity = '0.35'
        ..text = event.content;

    new Timer(new Duration(milliseconds: 5000), () {
      toast.style.opacity = '0';
    });
    new Timer(new Duration(milliseconds: 5500), toast.remove);

    toastContainer.append(toast);
  }
}

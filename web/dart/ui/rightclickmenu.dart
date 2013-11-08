part of coUclient;


class RightClickMenu {
  String title = 'None';
  String description;
  List <List> options;
  RightClickMenu(this.title,this.description,this.options){}
showClickMenu(MouseEvent Click){
  hideClickMenu();
  query('#RightClickMenu').hidden = false;
    int x,y;
    if (Click.page.y > window.innerHeight/2)
      y = Click.page.y - 55 - (options.length * 30);
    else
      y = Click.page.y - 10;
    if (Click.page.x > window.innerWidth/2)
      x = Click.page.x - 120;
    else
      x = Click.page.x - 10;
  query('#ClickTitle').text = title;
  query('#ClickDesc').text = description;
  List <Element> newOptions = new List();
  for (List option in options)
    {
      DivElement baby = new DivElement()
            ..classes.add('RCItem')
            ..text = option[0]
            ..onClick.listen((_){doThisForMe(option[2]);});
    newOptions.add(baby);
    }
  query('#RCActionList').children.addAll(newOptions);
  query('#RightClickMenu').style
  ..opacity = '1.0'
  ..position = 'absolute'
  ..top  = '$y' 'px'
  ..left = '$x' 'px';
  document.onClick.listen((_){
    hideClickMenu();});
}
hideClickMenu() {
  query('#RightClickMenu').style
      ..opacity = '1.0'
      ..position = 'absolute'
      ..top  = '-100%'
      ..left = '-100%';
  query('#ClickTitle').text = '';
  query('#ClickDesc').text = '';
  query('#RCActionList').children.clear();
}
}
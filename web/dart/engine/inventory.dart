part of couclient;



class Inventory {
  List box;  
  Inventory(Element parent) {
    for (Element holder in parent.querySelectorAll('.box'))
      box.add(holder);
  } 
  
  
}
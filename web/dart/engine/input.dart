part of couclient;


Input input = new Input();
class Input {
  Keyboard game_input = new Keyboard();
  
  init() {
   registerDefault();
   document.body.onKeyDown.listen(game_input.press);
  }
  
  registerDefault() {
   // Function Keys
   game_input.register('p', (_) => sound.play('piano')); 
   
   
   // Inventory HotKeys
   game_input.register('1', (_) => display.print('Use 1')); 
   game_input.register('2', (_) => display.print('Use 2')); 
   game_input.register('3', (_) => display.print('Use 3')); 
   game_input.register('4', (_) => display.print('Use 4'));
   game_input.register('5', (_) => display.print('Use 5'));
   game_input.register('6', (_) => display.print('Use 6'));
   game_input.register('7', (_) => display.print('Use 7'));
   game_input.register('8', (_) => display.print('Use 8'));
   game_input.register('9', (_) => display.print('Use 9'));
   game_input.register('0', (_) => display.print('Use 0'));
   
   
   // Movement Keys
   game_input.register('w', (_) => currStreet.camera.y-=10); 
   game_input.register('a', (_) => currStreet.camera.x-=10); 
   game_input.register('s', (_) => currStreet.camera.y+=10); 
   game_input.register('d', (_) => currStreet.camera.x+=10); 
   
   game_input.register('up', (_) => display.print('MoveUp')); 
   game_input.register('left', (_) => display.print('MoveLeft')); 
   game_input.register('down', (_) => display.print('MoveDown')); 
   game_input.register('right', (_) => display.print('MoveRight')); 
  }
  
  registerCustom(Map keys) {
    game_input.reset();
    //Key.valueOf(keyCode)
    for (String key in keys)
      game_input.register(key, (_) => print(keys[key]));    
  }
  
}







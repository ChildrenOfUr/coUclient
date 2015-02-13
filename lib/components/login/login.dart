library login;

import 'dart:html';
import 'package:polymer/polymer.dart';

@CustomTag('ur-login')
class UrLogin extends PolymerElement {
  Element greeter;
  Element panel;
  Element loginButton;
  InputElement emailField;
  
  Element newUserButton;
  
  UrLogin.created() : super.created() {
    greeter = shadowRoot.querySelector('#greeting');
    panel = shadowRoot.querySelector('#user-login');
    loginButton = shadowRoot.querySelector('#login-button');
    emailField = shadowRoot.querySelector('#new-user-name');
    
    
    
    shadowRoot.addEventListener('attemptLogin', (MouseEvent) {});
    loginButton.onClick.listen((event) => 
        shadowRoot.dispatchEvent(new CustomEvent('attemptLogin')));

  }

}

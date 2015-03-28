library login;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:firebase/firebase.dart';
import 'dart:async';
import 'dart:convert';

import 'package:couclient/configs.dart';

@CustomTag('ur-login')
class UrLogin extends PolymerElement
{
	String _authUrl = 'https://${Configs.authAddress}/auth';
	@published bool newUser;
	@observable bool timedout, newSignup = false, waiting = false, existingUser = false;
	@observable String email, password, newEmail = '', newUsername = '', newPassword = '';
	Firebase firebase;
	Map serverdata;

	UrLogin.created() : super.created()
	{
		firebase = new Firebase("https://blinding-fire-920.firebaseio.com");
	}

	loginAttempt(event, detail, target) async
	{
		waiting = true;
		Map<String,String> credentials = {'email':email,'password':password};

    	try
    	{
    		Map response = await firebase.authWithPassword(credentials);
    		HttpRequest request = await HttpRequest.request(_authUrl + "/getSession", method: "POST",
            				requestHeaders: {"content-type": "application/json"},
            				sendData: JSON.encode({'email':email}));
    		dispatchEvent(new CustomEvent('loginSuccess', detail: JSON.decode(request.response)));
    	}
    	catch(err)
    	{
    		print(err);
    	}
    	finally
    	{
    		waiting = false;
    	}
	}

	usernameSubmit(event, detail, target) async
	{
		if(newUsername == '' || newPassword == '')
			return;

		try
    	{
			await firebase.createUser({'email':newEmail,'password':newPassword});
			if(existingUser)
			{
				dispatchEvent(new CustomEvent('loginSuccess', detail: serverdata));
			}
			else
			{
				dispatchEvent(new CustomEvent('setUsername', detail: newUsername));
			}
    	}
    	catch(err)
    	{
    		print("couldn't create user on firebase: $err");
    	}
	}

	void signup(event, detail, target)
	{
		newSignup = true;
	}

	verifyEmail(event, detail, target) async
	{
		waiting = true;

		Timer tooLongTimer = new Timer(new Duration(seconds: 5),() => timedout = true);

		HttpRequest request = await HttpRequest.request(_authUrl + "/verifyEmail", method: "POST",
				requestHeaders: {"content-type": "application/json"},
				sendData: JSON.encode({'email':newEmail}));

		tooLongTimer.cancel();

		Map result = JSON.decode(request.response);
		if(result['result'] != 'OK')
		{
			waiting = false;
			print(result);
			return;
		}

		WebSocket ws = new WebSocket("ws://${Configs.authWebsocket}/awaitVerify");
		ws.onOpen.first.then((_)
		{
			Map map = {'email':newEmail};
			ws.send(JSON.encode(map));
		});
		ws.onMessage.first.then((MessageEvent event) async
		{
			Map map = JSON.decode(event.data);
			if(map['result'] == 'success')
			{
				if(map['serverdata']['playerName'].trim() != '')
				{
					//email already exists, make them choose a password
					existingUser = true;
					newUser = true;
					newUsername = map['serverdata']['playerName'].trim();
					serverdata = map['serverdata'];
				}
				else
				{
					dispatchEvent(new CustomEvent('loginSuccess', detail: map['serverdata']));
				}
			}
			else
			{
				print('problem verifying email address: ${map['result']}');
			}
			waiting = false;
		});
	}
}
library mail;

import 'package:redstone_mapper/mapper.dart';

class Mail {
	@Field()
	int id;
	@Field()
	String to_user;
	@Field()
	String from_user;
	@Field()
	String subject;
	@Field()
	String body;
	@Field()
	bool read;
}
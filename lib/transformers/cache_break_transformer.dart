import 'dart:async';
import 'package:intl/intl.dart';
import 'package:barback/barback.dart';

class CacheBreakTransformer extends Transformer
{
	CacheBreakTransformer.asPlugin(BarbackSettings);

	@override
	String get allowedExtensions => ".appcache";

	@override
	Future apply(Transform transform)
	{
		Completer c = new Completer();

		c.complete(transform.primaryInput.readAsString().then((String content)
		{
			DateTime now = new DateTime.now();
			DateFormat formatter = new DateFormat.yMd().add_Hms();
			String date = formatter.format(now);

			AssetId id = transform.primaryInput.id;
			String newContent = content.replaceFirst("#", "# $date");
			transform.addOutput(new Asset.fromString(id, newContent));
		}));

		return c.future;
	}
}
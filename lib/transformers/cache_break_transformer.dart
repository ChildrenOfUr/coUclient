import 'dart:async';
import 'package:barback/barback.dart';
import 'dart:math';

class CacheBreakTransformer extends Transformer
{
	Random random = new Random();

	CacheBreakTransformer.asPlugin(BarbackSettings);

	@override
	Future<bool> isPrimary(AssetId id)
	{
		return new Future.value(id.path.endsWith('index.html'));
	}

	@override
	Future apply(Transform transform)
	{
		Completer c = new Completer();

		c.complete(transform.primaryInput.readAsString().then((String content)
		{
			String randomParam = "index.html_bootstrap.dart.js?random=${random.nextInt(10000000)}";
			AssetId id = transform.primaryInput.id;
			String newContent = content.replaceFirst("index.html_bootstrap.dart.js", randomParam);
			transform.addOutput(new Asset.fromString(id, newContent));
		}));

		return c.future;
	}
}
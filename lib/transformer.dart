import 'dart:async';
import 'package:barback/barback.dart';

class AudienceTransformer extends Transformer
{
	final BarbackSettings _settings;

	AudienceTransformer.asPlugin(this._settings);

	Future apply(Transform transform)
	{
		Completer c = new Completer();

		String audience = "personaAudience = 'http://play.childrenofur.com:80'";
		if(_settings.configuration['audience'] != null)
			audience = "personaAudience = '${_settings.configuration['audience']}'";

		//Skip the transform in debug mode.
		if(_settings.mode.name == 'release')
		{
			c.complete(transform.primaryInput.readAsString().then((String content)
			{
				AssetId id = transform.primaryInput.id;
				String newContent = content.replaceFirst("personaAudience = 'http://localhost:8080'", audience);
				transform.addOutput(new Asset.fromString(id, newContent));
			}));
		}

		return c.future;
	}
}
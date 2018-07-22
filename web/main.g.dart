// GENERATED CODE - DO NOT MODIFY BY HAND

part of couclient;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Metabolics _$MetabolicsFromJson(Map<String, dynamic> json) {
  return new Metabolics()
    ..id = json['id'] as int
    ..userId = json['userId'] as int
    ..currants = json['currants'] as int
    ..energy = json['energy'] as int
    ..maxEnergy = json['maxEnergy'] as int
    ..mood = json['mood'] as int
    ..maxMood = json['maxMood'] as int
    ..img = json['img'] as int
    ..quoinsCollected = json['quoinsCollected'] as int
    ..alphFavor = json['alphFavor'] as int
    ..alphFavorMax = json['alphFavorMax'] as int
    ..cosmaFavor = json['cosmaFavor'] as int
    ..cosmaFavorMax = json['cosmaFavorMax'] as int
    ..friendlyFavor = json['friendlyFavor'] as int
    ..friendlyFavorMax = json['friendlyFavorMax'] as int
    ..grendalineFavor = json['grendalineFavor'] as int
    ..grendalineFavorMax = json['grendalineFavorMax'] as int
    ..humbabaFavor = json['humbabaFavor'] as int
    ..humbabaFavorMax = json['humbabaFavorMax'] as int
    ..lemFavor = json['lemFavor'] as int
    ..lemFavorMax = json['lemFavorMax'] as int
    ..lifetimeImg = json['lifetimeImg'] as int
    ..mabFavor = json['mabFavor'] as int
    ..mabFavorMax = json['mabFavorMax'] as int
    ..potFavor = json['potFavor'] as int
    ..potFavorMax = json['potFavorMax'] as int
    ..sprigganFavor = json['sprigganFavor'] as int
    ..sprigganFavorMax = json['sprigganFavorMax'] as int
    ..tiiFavor = json['tiiFavor'] as int
    ..tiiFavorMax = json['tiiFavorMax'] as int
    ..zilleFavor = json['zilleFavor'] as int
    ..zilleFavorMax = json['zilleFavorMax'] as int
    ..currentStreetX = json['currentStreetX'] as num
    ..currentStreetY = json['currentStreetY'] as num
    ..quoinMultiplier = json['quoinMultiplier'] as num
    ..currentStreet = json['currentStreet'] as String
    ..lastStreet = json['lastStreet'] as String
    ..locationHistory = json['locationHistory'] as String;
}

Map<String, dynamic> _$MetabolicsToJson(Metabolics instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'currants': instance.currants,
      'energy': instance.energy,
      'maxEnergy': instance.maxEnergy,
      'mood': instance.mood,
      'maxMood': instance.maxMood,
      'img': instance.img,
      'quoinsCollected': instance.quoinsCollected,
      'alphFavor': instance.alphFavor,
      'alphFavorMax': instance.alphFavorMax,
      'cosmaFavor': instance.cosmaFavor,
      'cosmaFavorMax': instance.cosmaFavorMax,
      'friendlyFavor': instance.friendlyFavor,
      'friendlyFavorMax': instance.friendlyFavorMax,
      'grendalineFavor': instance.grendalineFavor,
      'grendalineFavorMax': instance.grendalineFavorMax,
      'humbabaFavor': instance.humbabaFavor,
      'humbabaFavorMax': instance.humbabaFavorMax,
      'lemFavor': instance.lemFavor,
      'lemFavorMax': instance.lemFavorMax,
      'lifetimeImg': instance.lifetimeImg,
      'mabFavor': instance.mabFavor,
      'mabFavorMax': instance.mabFavorMax,
      'potFavor': instance.potFavor,
      'potFavorMax': instance.potFavorMax,
      'sprigganFavor': instance.sprigganFavor,
      'sprigganFavorMax': instance.sprigganFavorMax,
      'tiiFavor': instance.tiiFavor,
      'tiiFavorMax': instance.tiiFavorMax,
      'zilleFavor': instance.zilleFavor,
      'zilleFavorMax': instance.zilleFavorMax,
      'currentStreetX': instance.currentStreetX,
      'currentStreetY': instance.currentStreetY,
      'quoinMultiplier': instance.quoinMultiplier,
      'currentStreet': instance.currentStreet,
      'lastStreet': instance.lastStreet,
      'locationHistory': instance.locationHistory
    };

Edge _$EdgeFromJson(Map<String, dynamic> json) {
  return new Edge()
    ..start = json['start'] as String
    ..end = json['end'] as String
    ..weight = json['weight'] as int;
}

Map<String, dynamic> _$EdgeToJson(Edge instance) => <String, dynamic>{
      'start': instance.start,
      'end': instance.end,
      'weight': instance.weight
    };

Graph _$GraphFromJson(Map<String, dynamic> json) {
  return new Graph()
    ..edges = (json['edges'] as List)
        ?.map((e) =>
            e == null ? null : new Edge.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$GraphToJson(Graph instance) =>
    <String, dynamic>{'edges': instance.edges};

QuestRewards _$QuestRewardsFromJson(Map<String, dynamic> json) {
  return new QuestRewards()
    ..energy = json['energy'] as int
    ..mood = json['mood'] as int
    ..img = json['img'] as int
    ..currants = json['currants'] as int
    ..favor = (json['favor'] as List)
        ?.map((e) => e == null
            ? null
            : new QuestFavor.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$QuestRewardsToJson(QuestRewards instance) =>
    <String, dynamic>{
      'energy': instance.energy,
      'mood': instance.mood,
      'img': instance.img,
      'currants': instance.currants,
      'favor': instance.favor
    };

QuestFavor _$QuestFavorFromJson(Map<String, dynamic> json) {
  return new QuestFavor()
    ..giantName = json['giantName'] as String
    ..favAmt = json['favAmt'] as int;
}

Map<String, dynamic> _$QuestFavorToJson(QuestFavor instance) =>
    <String, dynamic>{
      'giantName': instance.giantName,
      'favAmt': instance.favAmt
    };

Quest _$QuestFromJson(Map<String, dynamic> json) {
  return new Quest()
    ..id = json['id'] as String
    ..title = json['title'] as String
    ..description = json['description'] as String
    ..complete = json['complete'] as bool
    ..prerequisites =
        (json['prerequisites'] as List)?.map((e) => e as String)?.toList()
    ..requirements = (json['requirements'] as List)
        ?.map((e) => e == null
            ? null
            : new Requirement.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..conversation_start = json['conversation_start'] == null
        ? null
        : new Conversation.fromJson(
            json['conversation_start'] as Map<String, dynamic>)
    ..conversation_end = json['conversation_end'] == null
        ? null
        : new Conversation.fromJson(
            json['conversation_end'] as Map<String, dynamic>)
    ..conversation_fail = json['conversation_fail'] == null
        ? null
        : new Conversation.fromJson(
            json['conversation_fail'] as Map<String, dynamic>)
    ..rewards = json['rewards'] == null
        ? null
        : new QuestRewards.fromJson(json['rewards'] as Map<String, dynamic>);
}

Map<String, dynamic> _$QuestToJson(Quest instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'complete': instance.complete,
      'prerequisites': instance.prerequisites,
      'requirements': instance.requirements,
      'conversation_start': instance.conversation_start,
      'conversation_end': instance.conversation_end,
      'conversation_fail': instance.conversation_fail,
      'rewards': instance.rewards
    };

Requirement _$RequirementFromJson(Map<String, dynamic> json) {
  return new Requirement()
    ..fulfilled = json['fulfilled'] as bool
    ..numRequired = json['numRequired'] as int
    ..timeLimit = json['timeLimit'] as int
    ..numFulfilled = json['numFulfilled'] as int
    ..id = json['id'] as String
    ..text = json['text'] as String
    ..type = json['type'] as String
    ..eventType = json['eventType'] as String
    ..iconUrl = json['iconUrl'] as String
    ..typeDone = (json['typeDone'] as List)?.map((e) => e as String)?.toList();
}

Map<String, dynamic> _$RequirementToJson(Requirement instance) =>
    <String, dynamic>{
      'fulfilled': instance.fulfilled,
      'numRequired': instance.numRequired,
      'timeLimit': instance.timeLimit,
      'numFulfilled': instance.numFulfilled,
      'id': instance.id,
      'text': instance.text,
      'type': instance.type,
      'eventType': instance.eventType,
      'iconUrl': instance.iconUrl,
      'typeDone': instance.typeDone
    };

Slot _$SlotFromJson(Map<String, dynamic> json) {
  return new Slot()
    ..itemType = json['itemType'] as String
    ..item = json['item'] == null
        ? null
        : new ItemDef.fromJson(json['item'] as Map<String, dynamic>)
    ..count = json['count'] as int;
}

Map<String, dynamic> _$SlotToJson(Slot instance) => <String, dynamic>{
      'itemType': instance.itemType,
      'item': instance.item,
      'count': instance.count
    };

Achievement _$AchievementFromJson(Map<String, dynamic> json) {
  return new Achievement()
    ..id = json['id'] as String
    ..name = json['name'] as String
    ..description = json['description'] as String
    ..category = json['category'] as String
    ..imageUrl = json['imageUrl'] as String
    ..awarded = json['awarded'] as String;
}

Map<String, dynamic> _$AchievementToJson(Achievement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'imageUrl': instance.imageUrl,
      'awarded': instance.awarded
    };

Mail _$MailFromJson(Map<String, dynamic> json) {
  return new Mail()
    ..id = json['id'] as int
    ..currants = json['currants'] as int
    ..to_user = json['to_user'] as String
    ..from_user = json['from_user'] as String
    ..subject = json['subject'] as String
    ..body = json['body'] as String
    ..read = json['read'] as bool
    ..currants_taken = json['currants_taken'] as bool
    ..item1_taken = json['item1_taken'] as bool
    ..item2_taken = json['item2_taken'] as bool
    ..item3_taken = json['item3_taken'] as bool
    ..item4_taken = json['item4_taken'] as bool
    ..item5_taken = json['item5_taken'] as bool
    ..item1 = json['item1'] as String
    ..item2 = json['item2'] as String
    ..item3 = json['item3'] as String
    ..item4 = json['item4'] as String
    ..item5 = json['item5'] as String
    ..item1_slot = json['item1_slot'] as String
    ..item2_slot = json['item2_slot'] as String
    ..item3_slot = json['item3_slot'] as String
    ..item4_slot = json['item4_slot'] as String
    ..item5_slot = json['item5_slot'] as String;
}

Map<String, dynamic> _$MailToJson(Mail instance) => <String, dynamic>{
      'id': instance.id,
      'currants': instance.currants,
      'to_user': instance.to_user,
      'from_user': instance.from_user,
      'subject': instance.subject,
      'body': instance.body,
      'read': instance.read,
      'currants_taken': instance.currants_taken,
      'item1_taken': instance.item1_taken,
      'item2_taken': instance.item2_taken,
      'item3_taken': instance.item3_taken,
      'item4_taken': instance.item4_taken,
      'item5_taken': instance.item5_taken,
      'item1': instance.item1,
      'item2': instance.item2,
      'item3': instance.item3,
      'item4': instance.item4,
      'item5': instance.item5,
      'item1_slot': instance.item1_slot,
      'item2_slot': instance.item2_slot,
      'item3_slot': instance.item3_slot,
      'item4_slot': instance.item4_slot,
      'item5_slot': instance.item5_slot
    };

Conversation _$ConversationFromJson(Map<String, dynamic> json) {
  return new Conversation()
    ..id = json['id'] as String
    ..screens = (json['screens'] as List)
        ?.map((e) => e == null
            ? null
            : new ConvoScreen.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$ConversationToJson(Conversation instance) =>
    <String, dynamic>{'id': instance.id, 'screens': instance.screens};

ConvoScreen _$ConvoScreenFromJson(Map<String, dynamic> json) {
  return new ConvoScreen()
    ..paragraphs =
        (json['paragraphs'] as List)?.map((e) => e as String)?.toList()
    ..choices = (json['choices'] as List)
        ?.map((e) => e == null
            ? null
            : new ConvoChoice.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$ConvoScreenToJson(ConvoScreen instance) =>
    <String, dynamic>{
      'paragraphs': instance.paragraphs,
      'choices': instance.choices
    };

ConvoChoice _$ConvoChoiceFromJson(Map<String, dynamic> json) {
  return new ConvoChoice()
    ..text = json['text'] as String
    ..gotoScreen = json['gotoScreen'] as int
    ..isQuestAccept = json['isQuestAccept'] as bool
    ..isQuestReject = json['isQuestReject'] as bool;
}

Map<String, dynamic> _$ConvoChoiceToJson(ConvoChoice instance) =>
    <String, dynamic>{
      'text': instance.text,
      'gotoScreen': instance.gotoScreen,
      'isQuestAccept': instance.isQuestAccept,
      'isQuestReject': instance.isQuestReject
    };

MapData _$MapDataFromJson(Map<String, dynamic> json) {
  return new MapData()
    ..hubData = (json['hubs'] as Map<String, dynamic>)
        ?.map((k, e) => new MapEntry(k, e as Map<String, dynamic>))
    ..streetData = (json['streets'] as Map<String, dynamic>)
        ?.map((k, e) => new MapEntry(k, e as Map<String, dynamic>))
    ..renderData = (json['render'] as Map<String, dynamic>)?.map((k, e) =>
        new MapEntry(
            k,
            (e as Map<String, dynamic>)
                ?.map((k, e) => new MapEntry(k, e as Map<String, dynamic>))));
}

Map<String, dynamic> _$MapDataToJson(MapData instance) => <String, dynamic>{
      'hubs': instance.hubData,
      'streets': instance.streetData,
      'render': instance.renderData
    };

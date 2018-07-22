// GENERATED CODE - DO NOT MODIFY BY HAND

part of itemdef;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemDef _$ItemDefFromJson(Map<String, dynamic> json) {
  return new ItemDef()
    ..category = json['category'] as String
    ..iconUrl = json['iconUrl'] as String
    ..spriteUrl = json['spriteUrl'] as String
    ..brokenUrl = json['brokenUrl'] as String
    ..toolAnimation = json['toolAnimation'] as String
    ..name = json['name'] as String
    ..description = json['description'] as String
    ..itemType = json['itemType'] as String
    ..item_id = json['item_id'] as String
    ..price = json['price'] as int
    ..stacksTo = json['stacksTo'] as int
    ..iconNum = json['iconNum'] as int
    ..durability = json['durability'] as int
    ..subSlots = json['subSlots'] as int
    ..x = json['x'] as num
    ..y = json['y'] as num
    ..onGround = json['onGround'] as bool
    ..isContainer = json['isContainer'] as bool
    ..subSlotFilter =
        (json['subSlotFilter'] as List)?.map((e) => e as String)?.toList()
    ..actions = (json['actions'] as List)
        ?.map((e) =>
            e == null ? null : new Action.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..consumeValues = (json['consumeValues'] as Map<String, dynamic>)
        ?.map((k, e) => new MapEntry(k, e as int))
    ..metadata = json['metadata'] as Map<String, dynamic>;
}

Map<String, dynamic> _$ItemDefToJson(ItemDef instance) => <String, dynamic>{
      'category': instance.category,
      'iconUrl': instance.iconUrl,
      'spriteUrl': instance.spriteUrl,
      'brokenUrl': instance.brokenUrl,
      'toolAnimation': instance.toolAnimation,
      'name': instance.name,
      'description': instance.description,
      'itemType': instance.itemType,
      'item_id': instance.item_id,
      'price': instance.price,
      'stacksTo': instance.stacksTo,
      'iconNum': instance.iconNum,
      'durability': instance.durability,
      'subSlots': instance.subSlots,
      'x': instance.x,
      'y': instance.y,
      'onGround': instance.onGround,
      'isContainer': instance.isContainer,
      'subSlotFilter': instance.subSlotFilter,
      'actions': instance.actions,
      'consumeValues': instance.consumeValues,
      'metadata': instance.metadata
    };

Action _$ActionFromJson(Map<String, dynamic> json) {
  return new Action()
    ..actionName = json['actionName'] as String
    ..error = json['error'] as String
    ..enabled = json['enabled'] as bool
    ..multiEnabled = json['multiEnabled'] as bool
    ..description = json['description'] as String
    ..timeRequired = json['timeRequired'] as int
    ..itemRequirements = json['itemRequirements'] == null
        ? null
        : new ItemRequirements.fromJson(
            json['itemRequirements'] as Map<String, dynamic>)
    ..skillRequirements = json['skillRequirements'] == null
        ? null
        : new SkillRequirements.fromJson(
            json['skillRequirements'] as Map<String, dynamic>)
    ..energyRequirements = json['energyRequirements'] == null
        ? null
        : new EnergyRequirements.fromJson(
            json['energyRequirements'] as Map<String, dynamic>)
    ..associatedSkill = json['associatedSkill'] as String
    ..dropMap = json['dropMap'] as Map<String, dynamic>
    ..actionWord = json['actionWord'] as String;
}

Map<String, dynamic> _$ActionToJson(Action instance) => <String, dynamic>{
      'actionName': instance.actionName,
      'error': instance.error,
      'enabled': instance.enabled,
      'multiEnabled': instance.multiEnabled,
      'description': instance.description,
      'timeRequired': instance.timeRequired,
      'itemRequirements': instance.itemRequirements,
      'skillRequirements': instance.skillRequirements,
      'energyRequirements': instance.energyRequirements,
      'associatedSkill': instance.associatedSkill,
      'dropMap': instance.dropMap,
      'actionWord': instance.actionWord
    };

SkillRequirements _$SkillRequirementsFromJson(Map<String, dynamic> json) {
  return new SkillRequirements()
    ..requiredSkillLevels =
        (json['requiredSkillLevels'] as Map<String, dynamic>)
            ?.map((k, e) => new MapEntry(k, e as int))
    ..error = json['error'] as String;
}

Map<String, dynamic> _$SkillRequirementsToJson(SkillRequirements instance) =>
    <String, dynamic>{
      'requiredSkillLevels': instance.requiredSkillLevels,
      'error': instance.error
    };

ItemRequirements _$ItemRequirementsFromJson(Map<String, dynamic> json) {
  return new ItemRequirements()
    ..any = (json['any'] as List)?.map((e) => e as String)?.toList()
    ..all = (json['all'] as Map<String, dynamic>)
        ?.map((k, e) => new MapEntry(k, e as int))
    ..error = json['error'] as String;
}

Map<String, dynamic> _$ItemRequirementsToJson(ItemRequirements instance) =>
    <String, dynamic>{
      'any': instance.any,
      'all': instance.all,
      'error': instance.error
    };

EnergyRequirements _$EnergyRequirementsFromJson(Map<String, dynamic> json) {
  return new EnergyRequirements(energyAmount: json['energyAmount'] as int)
    ..error = json['error'] as String;
}

Map<String, dynamic> _$EnergyRequirementsToJson(EnergyRequirements instance) =>
    <String, dynamic>{
      'energyAmount': instance.energyAmount,
      'error': instance.error
    };

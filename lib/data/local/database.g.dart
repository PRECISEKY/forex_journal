// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
mixin _$TradeDaoMixin on DatabaseAccessor<AppDatabase> {
  $PairsTable get pairs => attachedDatabase.pairs;
  $StrategiesTable get strategies => attachedDatabase.strategies;
  $TradesTable get trades => attachedDatabase.trades;
}
mixin _$StrategyDaoMixin on DatabaseAccessor<AppDatabase> {
  $StrategiesTable get strategies => attachedDatabase.strategies;
}
mixin _$PairDaoMixin on DatabaseAccessor<AppDatabase> {
  $PairsTable get pairs => attachedDatabase.pairs;
}

class $PairsTable extends Pairs with TableInfo<$PairsTable, Pair> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PairsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 6),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => Supabase.instance.client.auth.currentUser!.id,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, userId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pairs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Pair> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Pair map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pair(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}user_id'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $PairsTable createAlias(String alias) {
    return $PairsTable(attachedDatabase, alias);
  }
}

class Pair extends DataClass implements Insertable<Pair> {
  final int id;
  final String name;
  final String userId;
  final DateTime createdAt;
  const Pair({
    required this.id,
    required this.name,
    required this.userId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PairsCompanion toCompanion(bool nullToAbsent) {
    return PairsCompanion(
      id: Value(id),
      name: Value(name),
      userId: Value(userId),
      createdAt: Value(createdAt),
    );
  }

  factory Pair.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pair(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Pair copyWith({int? id, String? name, String? userId, DateTime? createdAt}) =>
      Pair(
        id: id ?? this.id,
        name: name ?? this.name,
        userId: userId ?? this.userId,
        createdAt: createdAt ?? this.createdAt,
      );
  Pair copyWithCompanion(PairsCompanion data) {
    return Pair(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pair(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, userId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pair &&
          other.id == this.id &&
          other.name == this.name &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt);
}

class PairsCompanion extends UpdateCompanion<Pair> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> userId;
  final Value<DateTime> createdAt;
  const PairsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PairsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Pair> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? userId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PairsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? userId,
    Value<DateTime>? createdAt,
  }) {
    return PairsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PairsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $StrategiesTable extends Strategies
    with TableInfo<$StrategiesTable, Strategy> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StrategiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => Supabase.instance.client.auth.currentUser!.id,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    userId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'strategies';
  @override
  VerificationContext validateIntegrity(
    Insertable<Strategy> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Strategy map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Strategy(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}user_id'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $StrategiesTable createAlias(String alias) {
    return $StrategiesTable(attachedDatabase, alias);
  }
}

class Strategy extends DataClass implements Insertable<Strategy> {
  final int id;
  final String name;
  final String? description;
  final String userId;
  final DateTime createdAt;
  const Strategy({
    required this.id,
    required this.name,
    this.description,
    required this.userId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StrategiesCompanion toCompanion(bool nullToAbsent) {
    return StrategiesCompanion(
      id: Value(id),
      name: Value(name),
      description:
          description == null && nullToAbsent
              ? const Value.absent()
              : Value(description),
      userId: Value(userId),
      createdAt: Value(createdAt),
    );
  }

  factory Strategy.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Strategy(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Strategy copyWith({
    int? id,
    String? name,
    Value<String?> description = const Value.absent(),
    String? userId,
    DateTime? createdAt,
  }) => Strategy(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
  );
  Strategy copyWithCompanion(StrategiesCompanion data) {
    return Strategy(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Strategy(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, userId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Strategy &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt);
}

class StrategiesCompanion extends UpdateCompanion<Strategy> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> userId;
  final Value<DateTime> createdAt;
  const StrategiesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  StrategiesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Strategy> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? userId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  StrategiesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<String>? userId,
    Value<DateTime>? createdAt,
  }) {
    return StrategiesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StrategiesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TradesTable extends Trades with TableInfo<$TradesTable, Trade> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TradesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pairMeta = const VerificationMeta('pair');
  @override
  late final GeneratedColumn<String> pair = GeneratedColumn<String>(
    'pair',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 6,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pairIdMeta = const VerificationMeta('pairId');
  @override
  late final GeneratedColumn<int> pairId = GeneratedColumn<int>(
    'pair_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pairs (id)',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => Supabase.instance.client.auth.currentUser!.id,
  );
  static const VerificationMeta _entryDateMeta = const VerificationMeta(
    'entryDate',
  );
  @override
  late final GeneratedColumn<DateTime> entryDate = GeneratedColumn<DateTime>(
    'entry_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exitDateMeta = const VerificationMeta(
    'exitDate',
  );
  @override
  late final GeneratedColumn<DateTime> exitDate = GeneratedColumn<DateTime>(
    'exit_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isLongMeta = const VerificationMeta('isLong');
  @override
  late final GeneratedColumn<bool> isLong = GeneratedColumn<bool>(
    'is_long',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_long" IN (0, 1))',
    ),
  );
  static const VerificationMeta _entryPriceMeta = const VerificationMeta(
    'entryPrice',
  );
  @override
  late final GeneratedColumn<double> entryPrice = GeneratedColumn<double>(
    'entry_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exitPriceMeta = const VerificationMeta(
    'exitPrice',
  );
  @override
  late final GeneratedColumn<double> exitPrice = GeneratedColumn<double>(
    'exit_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionSizeLotsMeta = const VerificationMeta(
    'positionSizeLots',
  );
  @override
  late final GeneratedColumn<double> positionSizeLots = GeneratedColumn<double>(
    'position_size_lots',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stopLossPriceMeta = const VerificationMeta(
    'stopLossPrice',
  );
  @override
  late final GeneratedColumn<double> stopLossPrice = GeneratedColumn<double>(
    'stop_loss_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _takeProfitPriceMeta = const VerificationMeta(
    'takeProfitPrice',
  );
  @override
  late final GeneratedColumn<double> takeProfitPrice = GeneratedColumn<double>(
    'take_profit_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualProfitLossMeta = const VerificationMeta(
    'actualProfitLoss',
  );
  @override
  late final GeneratedColumn<double> actualProfitLoss = GeneratedColumn<double>(
    'actual_profit_loss',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commissionFeesMeta = const VerificationMeta(
    'commissionFees',
  );
  @override
  late final GeneratedColumn<double> commissionFees = GeneratedColumn<double>(
    'commission_fees',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _swapFeesMeta = const VerificationMeta(
    'swapFees',
  );
  @override
  late final GeneratedColumn<double> swapFees = GeneratedColumn<double>(
    'swap_fees',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _strategyTagMeta = const VerificationMeta(
    'strategyTag',
  );
  @override
  late final GeneratedColumn<String> strategyTag = GeneratedColumn<String>(
    'strategy_tag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _strategyIdMeta = const VerificationMeta(
    'strategyId',
  );
  @override
  late final GeneratedColumn<int> strategyId = GeneratedColumn<int>(
    'strategy_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES strategies (id)',
    ),
  );
  static const VerificationMeta _reasonForEntryMeta = const VerificationMeta(
    'reasonForEntry',
  );
  @override
  late final GeneratedColumn<String> reasonForEntry = GeneratedColumn<String>(
    'reason_for_entry',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reasonForExitMeta = const VerificationMeta(
    'reasonForExit',
  );
  @override
  late final GeneratedColumn<String> reasonForExit = GeneratedColumn<String>(
    'reason_for_exit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceScoreMeta = const VerificationMeta(
    'confidenceScore',
  );
  @override
  late final GeneratedColumn<int> confidenceScore = GeneratedColumn<int>(
    'confidence_score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customTagsJsonMeta = const VerificationMeta(
    'customTagsJson',
  );
  @override
  late final GeneratedColumn<String> customTagsJson = GeneratedColumn<String>(
    'custom_tags_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imagePathsJsonMeta = const VerificationMeta(
    'imagePathsJson',
  );
  @override
  late final GeneratedColumn<String> imagePathsJson = GeneratedColumn<String>(
    'image_paths_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pair,
    pairId,
    userId,
    entryDate,
    exitDate,
    isLong,
    entryPrice,
    exitPrice,
    positionSizeLots,
    stopLossPrice,
    takeProfitPrice,
    actualProfitLoss,
    commissionFees,
    swapFees,
    strategyTag,
    strategyId,
    reasonForEntry,
    reasonForExit,
    confidenceScore,
    customTagsJson,
    imagePathsJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trades';
  @override
  VerificationContext validateIntegrity(
    Insertable<Trade> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pair')) {
      context.handle(
        _pairMeta,
        pair.isAcceptableOrUnknown(data['pair']!, _pairMeta),
      );
    } else if (isInserting) {
      context.missing(_pairMeta);
    }
    if (data.containsKey('pair_id')) {
      context.handle(
        _pairIdMeta,
        pairId.isAcceptableOrUnknown(data['pair_id']!, _pairIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pairIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('entry_date')) {
      context.handle(
        _entryDateMeta,
        entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    if (data.containsKey('exit_date')) {
      context.handle(
        _exitDateMeta,
        exitDate.isAcceptableOrUnknown(data['exit_date']!, _exitDateMeta),
      );
    } else if (isInserting) {
      context.missing(_exitDateMeta);
    }
    if (data.containsKey('is_long')) {
      context.handle(
        _isLongMeta,
        isLong.isAcceptableOrUnknown(data['is_long']!, _isLongMeta),
      );
    } else if (isInserting) {
      context.missing(_isLongMeta);
    }
    if (data.containsKey('entry_price')) {
      context.handle(
        _entryPriceMeta,
        entryPrice.isAcceptableOrUnknown(data['entry_price']!, _entryPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_entryPriceMeta);
    }
    if (data.containsKey('exit_price')) {
      context.handle(
        _exitPriceMeta,
        exitPrice.isAcceptableOrUnknown(data['exit_price']!, _exitPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_exitPriceMeta);
    }
    if (data.containsKey('position_size_lots')) {
      context.handle(
        _positionSizeLotsMeta,
        positionSizeLots.isAcceptableOrUnknown(
          data['position_size_lots']!,
          _positionSizeLotsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_positionSizeLotsMeta);
    }
    if (data.containsKey('stop_loss_price')) {
      context.handle(
        _stopLossPriceMeta,
        stopLossPrice.isAcceptableOrUnknown(
          data['stop_loss_price']!,
          _stopLossPriceMeta,
        ),
      );
    }
    if (data.containsKey('take_profit_price')) {
      context.handle(
        _takeProfitPriceMeta,
        takeProfitPrice.isAcceptableOrUnknown(
          data['take_profit_price']!,
          _takeProfitPriceMeta,
        ),
      );
    }
    if (data.containsKey('actual_profit_loss')) {
      context.handle(
        _actualProfitLossMeta,
        actualProfitLoss.isAcceptableOrUnknown(
          data['actual_profit_loss']!,
          _actualProfitLossMeta,
        ),
      );
    }
    if (data.containsKey('commission_fees')) {
      context.handle(
        _commissionFeesMeta,
        commissionFees.isAcceptableOrUnknown(
          data['commission_fees']!,
          _commissionFeesMeta,
        ),
      );
    }
    if (data.containsKey('swap_fees')) {
      context.handle(
        _swapFeesMeta,
        swapFees.isAcceptableOrUnknown(data['swap_fees']!, _swapFeesMeta),
      );
    }
    if (data.containsKey('strategy_tag')) {
      context.handle(
        _strategyTagMeta,
        strategyTag.isAcceptableOrUnknown(
          data['strategy_tag']!,
          _strategyTagMeta,
        ),
      );
    }
    if (data.containsKey('strategy_id')) {
      context.handle(
        _strategyIdMeta,
        strategyId.isAcceptableOrUnknown(data['strategy_id']!, _strategyIdMeta),
      );
    }
    if (data.containsKey('reason_for_entry')) {
      context.handle(
        _reasonForEntryMeta,
        reasonForEntry.isAcceptableOrUnknown(
          data['reason_for_entry']!,
          _reasonForEntryMeta,
        ),
      );
    }
    if (data.containsKey('reason_for_exit')) {
      context.handle(
        _reasonForExitMeta,
        reasonForExit.isAcceptableOrUnknown(
          data['reason_for_exit']!,
          _reasonForExitMeta,
        ),
      );
    }
    if (data.containsKey('confidence_score')) {
      context.handle(
        _confidenceScoreMeta,
        confidenceScore.isAcceptableOrUnknown(
          data['confidence_score']!,
          _confidenceScoreMeta,
        ),
      );
    }
    if (data.containsKey('custom_tags_json')) {
      context.handle(
        _customTagsJsonMeta,
        customTagsJson.isAcceptableOrUnknown(
          data['custom_tags_json']!,
          _customTagsJsonMeta,
        ),
      );
    }
    if (data.containsKey('image_paths_json')) {
      context.handle(
        _imagePathsJsonMeta,
        imagePathsJson.isAcceptableOrUnknown(
          data['image_paths_json']!,
          _imagePathsJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Trade map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Trade(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      pair:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}pair'],
          )!,
      pairId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}pair_id'],
          )!,
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}user_id'],
          )!,
      entryDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}entry_date'],
          )!,
      exitDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}exit_date'],
          )!,
      isLong:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_long'],
          )!,
      entryPrice:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}entry_price'],
          )!,
      exitPrice:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}exit_price'],
          )!,
      positionSizeLots:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}position_size_lots'],
          )!,
      stopLossPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stop_loss_price'],
      ),
      takeProfitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}take_profit_price'],
      ),
      actualProfitLoss: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_profit_loss'],
      ),
      commissionFees: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}commission_fees'],
      ),
      swapFees: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}swap_fees'],
      ),
      strategyTag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strategy_tag'],
      ),
      strategyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}strategy_id'],
      ),
      reasonForEntry: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason_for_entry'],
      ),
      reasonForExit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason_for_exit'],
      ),
      confidenceScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}confidence_score'],
      ),
      customTagsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_tags_json'],
      ),
      imagePathsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_paths_json'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $TradesTable createAlias(String alias) {
    return $TradesTable(attachedDatabase, alias);
  }
}

class Trade extends DataClass implements Insertable<Trade> {
  final int id;
  final String pair;
  final int pairId;
  final String userId;
  final DateTime entryDate;
  final DateTime exitDate;
  final bool isLong;
  final double entryPrice;
  final double exitPrice;
  final double positionSizeLots;
  final double? stopLossPrice;
  final double? takeProfitPrice;
  final double? actualProfitLoss;
  final double? commissionFees;
  final double? swapFees;
  final String? strategyTag;
  final int? strategyId;
  final String? reasonForEntry;
  final String? reasonForExit;
  final int? confidenceScore;
  final String? customTagsJson;
  final String? imagePathsJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Trade({
    required this.id,
    required this.pair,
    required this.pairId,
    required this.userId,
    required this.entryDate,
    required this.exitDate,
    required this.isLong,
    required this.entryPrice,
    required this.exitPrice,
    required this.positionSizeLots,
    this.stopLossPrice,
    this.takeProfitPrice,
    this.actualProfitLoss,
    this.commissionFees,
    this.swapFees,
    this.strategyTag,
    this.strategyId,
    this.reasonForEntry,
    this.reasonForExit,
    this.confidenceScore,
    this.customTagsJson,
    this.imagePathsJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pair'] = Variable<String>(pair);
    map['pair_id'] = Variable<int>(pairId);
    map['user_id'] = Variable<String>(userId);
    map['entry_date'] = Variable<DateTime>(entryDate);
    map['exit_date'] = Variable<DateTime>(exitDate);
    map['is_long'] = Variable<bool>(isLong);
    map['entry_price'] = Variable<double>(entryPrice);
    map['exit_price'] = Variable<double>(exitPrice);
    map['position_size_lots'] = Variable<double>(positionSizeLots);
    if (!nullToAbsent || stopLossPrice != null) {
      map['stop_loss_price'] = Variable<double>(stopLossPrice);
    }
    if (!nullToAbsent || takeProfitPrice != null) {
      map['take_profit_price'] = Variable<double>(takeProfitPrice);
    }
    if (!nullToAbsent || actualProfitLoss != null) {
      map['actual_profit_loss'] = Variable<double>(actualProfitLoss);
    }
    if (!nullToAbsent || commissionFees != null) {
      map['commission_fees'] = Variable<double>(commissionFees);
    }
    if (!nullToAbsent || swapFees != null) {
      map['swap_fees'] = Variable<double>(swapFees);
    }
    if (!nullToAbsent || strategyTag != null) {
      map['strategy_tag'] = Variable<String>(strategyTag);
    }
    if (!nullToAbsent || strategyId != null) {
      map['strategy_id'] = Variable<int>(strategyId);
    }
    if (!nullToAbsent || reasonForEntry != null) {
      map['reason_for_entry'] = Variable<String>(reasonForEntry);
    }
    if (!nullToAbsent || reasonForExit != null) {
      map['reason_for_exit'] = Variable<String>(reasonForExit);
    }
    if (!nullToAbsent || confidenceScore != null) {
      map['confidence_score'] = Variable<int>(confidenceScore);
    }
    if (!nullToAbsent || customTagsJson != null) {
      map['custom_tags_json'] = Variable<String>(customTagsJson);
    }
    if (!nullToAbsent || imagePathsJson != null) {
      map['image_paths_json'] = Variable<String>(imagePathsJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TradesCompanion toCompanion(bool nullToAbsent) {
    return TradesCompanion(
      id: Value(id),
      pair: Value(pair),
      pairId: Value(pairId),
      userId: Value(userId),
      entryDate: Value(entryDate),
      exitDate: Value(exitDate),
      isLong: Value(isLong),
      entryPrice: Value(entryPrice),
      exitPrice: Value(exitPrice),
      positionSizeLots: Value(positionSizeLots),
      stopLossPrice:
          stopLossPrice == null && nullToAbsent
              ? const Value.absent()
              : Value(stopLossPrice),
      takeProfitPrice:
          takeProfitPrice == null && nullToAbsent
              ? const Value.absent()
              : Value(takeProfitPrice),
      actualProfitLoss:
          actualProfitLoss == null && nullToAbsent
              ? const Value.absent()
              : Value(actualProfitLoss),
      commissionFees:
          commissionFees == null && nullToAbsent
              ? const Value.absent()
              : Value(commissionFees),
      swapFees:
          swapFees == null && nullToAbsent
              ? const Value.absent()
              : Value(swapFees),
      strategyTag:
          strategyTag == null && nullToAbsent
              ? const Value.absent()
              : Value(strategyTag),
      strategyId:
          strategyId == null && nullToAbsent
              ? const Value.absent()
              : Value(strategyId),
      reasonForEntry:
          reasonForEntry == null && nullToAbsent
              ? const Value.absent()
              : Value(reasonForEntry),
      reasonForExit:
          reasonForExit == null && nullToAbsent
              ? const Value.absent()
              : Value(reasonForExit),
      confidenceScore:
          confidenceScore == null && nullToAbsent
              ? const Value.absent()
              : Value(confidenceScore),
      customTagsJson:
          customTagsJson == null && nullToAbsent
              ? const Value.absent()
              : Value(customTagsJson),
      imagePathsJson:
          imagePathsJson == null && nullToAbsent
              ? const Value.absent()
              : Value(imagePathsJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Trade.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Trade(
      id: serializer.fromJson<int>(json['id']),
      pair: serializer.fromJson<String>(json['pair']),
      pairId: serializer.fromJson<int>(json['pairId']),
      userId: serializer.fromJson<String>(json['userId']),
      entryDate: serializer.fromJson<DateTime>(json['entryDate']),
      exitDate: serializer.fromJson<DateTime>(json['exitDate']),
      isLong: serializer.fromJson<bool>(json['isLong']),
      entryPrice: serializer.fromJson<double>(json['entryPrice']),
      exitPrice: serializer.fromJson<double>(json['exitPrice']),
      positionSizeLots: serializer.fromJson<double>(json['positionSizeLots']),
      stopLossPrice: serializer.fromJson<double?>(json['stopLossPrice']),
      takeProfitPrice: serializer.fromJson<double?>(json['takeProfitPrice']),
      actualProfitLoss: serializer.fromJson<double?>(json['actualProfitLoss']),
      commissionFees: serializer.fromJson<double?>(json['commissionFees']),
      swapFees: serializer.fromJson<double?>(json['swapFees']),
      strategyTag: serializer.fromJson<String?>(json['strategyTag']),
      strategyId: serializer.fromJson<int?>(json['strategyId']),
      reasonForEntry: serializer.fromJson<String?>(json['reasonForEntry']),
      reasonForExit: serializer.fromJson<String?>(json['reasonForExit']),
      confidenceScore: serializer.fromJson<int?>(json['confidenceScore']),
      customTagsJson: serializer.fromJson<String?>(json['customTagsJson']),
      imagePathsJson: serializer.fromJson<String?>(json['imagePathsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pair': serializer.toJson<String>(pair),
      'pairId': serializer.toJson<int>(pairId),
      'userId': serializer.toJson<String>(userId),
      'entryDate': serializer.toJson<DateTime>(entryDate),
      'exitDate': serializer.toJson<DateTime>(exitDate),
      'isLong': serializer.toJson<bool>(isLong),
      'entryPrice': serializer.toJson<double>(entryPrice),
      'exitPrice': serializer.toJson<double>(exitPrice),
      'positionSizeLots': serializer.toJson<double>(positionSizeLots),
      'stopLossPrice': serializer.toJson<double?>(stopLossPrice),
      'takeProfitPrice': serializer.toJson<double?>(takeProfitPrice),
      'actualProfitLoss': serializer.toJson<double?>(actualProfitLoss),
      'commissionFees': serializer.toJson<double?>(commissionFees),
      'swapFees': serializer.toJson<double?>(swapFees),
      'strategyTag': serializer.toJson<String?>(strategyTag),
      'strategyId': serializer.toJson<int?>(strategyId),
      'reasonForEntry': serializer.toJson<String?>(reasonForEntry),
      'reasonForExit': serializer.toJson<String?>(reasonForExit),
      'confidenceScore': serializer.toJson<int?>(confidenceScore),
      'customTagsJson': serializer.toJson<String?>(customTagsJson),
      'imagePathsJson': serializer.toJson<String?>(imagePathsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Trade copyWith({
    int? id,
    String? pair,
    int? pairId,
    String? userId,
    DateTime? entryDate,
    DateTime? exitDate,
    bool? isLong,
    double? entryPrice,
    double? exitPrice,
    double? positionSizeLots,
    Value<double?> stopLossPrice = const Value.absent(),
    Value<double?> takeProfitPrice = const Value.absent(),
    Value<double?> actualProfitLoss = const Value.absent(),
    Value<double?> commissionFees = const Value.absent(),
    Value<double?> swapFees = const Value.absent(),
    Value<String?> strategyTag = const Value.absent(),
    Value<int?> strategyId = const Value.absent(),
    Value<String?> reasonForEntry = const Value.absent(),
    Value<String?> reasonForExit = const Value.absent(),
    Value<int?> confidenceScore = const Value.absent(),
    Value<String?> customTagsJson = const Value.absent(),
    Value<String?> imagePathsJson = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Trade(
    id: id ?? this.id,
    pair: pair ?? this.pair,
    pairId: pairId ?? this.pairId,
    userId: userId ?? this.userId,
    entryDate: entryDate ?? this.entryDate,
    exitDate: exitDate ?? this.exitDate,
    isLong: isLong ?? this.isLong,
    entryPrice: entryPrice ?? this.entryPrice,
    exitPrice: exitPrice ?? this.exitPrice,
    positionSizeLots: positionSizeLots ?? this.positionSizeLots,
    stopLossPrice:
        stopLossPrice.present ? stopLossPrice.value : this.stopLossPrice,
    takeProfitPrice:
        takeProfitPrice.present ? takeProfitPrice.value : this.takeProfitPrice,
    actualProfitLoss:
        actualProfitLoss.present
            ? actualProfitLoss.value
            : this.actualProfitLoss,
    commissionFees:
        commissionFees.present ? commissionFees.value : this.commissionFees,
    swapFees: swapFees.present ? swapFees.value : this.swapFees,
    strategyTag: strategyTag.present ? strategyTag.value : this.strategyTag,
    strategyId: strategyId.present ? strategyId.value : this.strategyId,
    reasonForEntry:
        reasonForEntry.present ? reasonForEntry.value : this.reasonForEntry,
    reasonForExit:
        reasonForExit.present ? reasonForExit.value : this.reasonForExit,
    confidenceScore:
        confidenceScore.present ? confidenceScore.value : this.confidenceScore,
    customTagsJson:
        customTagsJson.present ? customTagsJson.value : this.customTagsJson,
    imagePathsJson:
        imagePathsJson.present ? imagePathsJson.value : this.imagePathsJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Trade copyWithCompanion(TradesCompanion data) {
    return Trade(
      id: data.id.present ? data.id.value : this.id,
      pair: data.pair.present ? data.pair.value : this.pair,
      pairId: data.pairId.present ? data.pairId.value : this.pairId,
      userId: data.userId.present ? data.userId.value : this.userId,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      exitDate: data.exitDate.present ? data.exitDate.value : this.exitDate,
      isLong: data.isLong.present ? data.isLong.value : this.isLong,
      entryPrice:
          data.entryPrice.present ? data.entryPrice.value : this.entryPrice,
      exitPrice: data.exitPrice.present ? data.exitPrice.value : this.exitPrice,
      positionSizeLots:
          data.positionSizeLots.present
              ? data.positionSizeLots.value
              : this.positionSizeLots,
      stopLossPrice:
          data.stopLossPrice.present
              ? data.stopLossPrice.value
              : this.stopLossPrice,
      takeProfitPrice:
          data.takeProfitPrice.present
              ? data.takeProfitPrice.value
              : this.takeProfitPrice,
      actualProfitLoss:
          data.actualProfitLoss.present
              ? data.actualProfitLoss.value
              : this.actualProfitLoss,
      commissionFees:
          data.commissionFees.present
              ? data.commissionFees.value
              : this.commissionFees,
      swapFees: data.swapFees.present ? data.swapFees.value : this.swapFees,
      strategyTag:
          data.strategyTag.present ? data.strategyTag.value : this.strategyTag,
      strategyId:
          data.strategyId.present ? data.strategyId.value : this.strategyId,
      reasonForEntry:
          data.reasonForEntry.present
              ? data.reasonForEntry.value
              : this.reasonForEntry,
      reasonForExit:
          data.reasonForExit.present
              ? data.reasonForExit.value
              : this.reasonForExit,
      confidenceScore:
          data.confidenceScore.present
              ? data.confidenceScore.value
              : this.confidenceScore,
      customTagsJson:
          data.customTagsJson.present
              ? data.customTagsJson.value
              : this.customTagsJson,
      imagePathsJson:
          data.imagePathsJson.present
              ? data.imagePathsJson.value
              : this.imagePathsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Trade(')
          ..write('id: $id, ')
          ..write('pair: $pair, ')
          ..write('pairId: $pairId, ')
          ..write('userId: $userId, ')
          ..write('entryDate: $entryDate, ')
          ..write('exitDate: $exitDate, ')
          ..write('isLong: $isLong, ')
          ..write('entryPrice: $entryPrice, ')
          ..write('exitPrice: $exitPrice, ')
          ..write('positionSizeLots: $positionSizeLots, ')
          ..write('stopLossPrice: $stopLossPrice, ')
          ..write('takeProfitPrice: $takeProfitPrice, ')
          ..write('actualProfitLoss: $actualProfitLoss, ')
          ..write('commissionFees: $commissionFees, ')
          ..write('swapFees: $swapFees, ')
          ..write('strategyTag: $strategyTag, ')
          ..write('strategyId: $strategyId, ')
          ..write('reasonForEntry: $reasonForEntry, ')
          ..write('reasonForExit: $reasonForExit, ')
          ..write('confidenceScore: $confidenceScore, ')
          ..write('customTagsJson: $customTagsJson, ')
          ..write('imagePathsJson: $imagePathsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    pair,
    pairId,
    userId,
    entryDate,
    exitDate,
    isLong,
    entryPrice,
    exitPrice,
    positionSizeLots,
    stopLossPrice,
    takeProfitPrice,
    actualProfitLoss,
    commissionFees,
    swapFees,
    strategyTag,
    strategyId,
    reasonForEntry,
    reasonForExit,
    confidenceScore,
    customTagsJson,
    imagePathsJson,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Trade &&
          other.id == this.id &&
          other.pair == this.pair &&
          other.pairId == this.pairId &&
          other.userId == this.userId &&
          other.entryDate == this.entryDate &&
          other.exitDate == this.exitDate &&
          other.isLong == this.isLong &&
          other.entryPrice == this.entryPrice &&
          other.exitPrice == this.exitPrice &&
          other.positionSizeLots == this.positionSizeLots &&
          other.stopLossPrice == this.stopLossPrice &&
          other.takeProfitPrice == this.takeProfitPrice &&
          other.actualProfitLoss == this.actualProfitLoss &&
          other.commissionFees == this.commissionFees &&
          other.swapFees == this.swapFees &&
          other.strategyTag == this.strategyTag &&
          other.strategyId == this.strategyId &&
          other.reasonForEntry == this.reasonForEntry &&
          other.reasonForExit == this.reasonForExit &&
          other.confidenceScore == this.confidenceScore &&
          other.customTagsJson == this.customTagsJson &&
          other.imagePathsJson == this.imagePathsJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TradesCompanion extends UpdateCompanion<Trade> {
  final Value<int> id;
  final Value<String> pair;
  final Value<int> pairId;
  final Value<String> userId;
  final Value<DateTime> entryDate;
  final Value<DateTime> exitDate;
  final Value<bool> isLong;
  final Value<double> entryPrice;
  final Value<double> exitPrice;
  final Value<double> positionSizeLots;
  final Value<double?> stopLossPrice;
  final Value<double?> takeProfitPrice;
  final Value<double?> actualProfitLoss;
  final Value<double?> commissionFees;
  final Value<double?> swapFees;
  final Value<String?> strategyTag;
  final Value<int?> strategyId;
  final Value<String?> reasonForEntry;
  final Value<String?> reasonForExit;
  final Value<int?> confidenceScore;
  final Value<String?> customTagsJson;
  final Value<String?> imagePathsJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TradesCompanion({
    this.id = const Value.absent(),
    this.pair = const Value.absent(),
    this.pairId = const Value.absent(),
    this.userId = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.exitDate = const Value.absent(),
    this.isLong = const Value.absent(),
    this.entryPrice = const Value.absent(),
    this.exitPrice = const Value.absent(),
    this.positionSizeLots = const Value.absent(),
    this.stopLossPrice = const Value.absent(),
    this.takeProfitPrice = const Value.absent(),
    this.actualProfitLoss = const Value.absent(),
    this.commissionFees = const Value.absent(),
    this.swapFees = const Value.absent(),
    this.strategyTag = const Value.absent(),
    this.strategyId = const Value.absent(),
    this.reasonForEntry = const Value.absent(),
    this.reasonForExit = const Value.absent(),
    this.confidenceScore = const Value.absent(),
    this.customTagsJson = const Value.absent(),
    this.imagePathsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TradesCompanion.insert({
    this.id = const Value.absent(),
    required String pair,
    required int pairId,
    this.userId = const Value.absent(),
    required DateTime entryDate,
    required DateTime exitDate,
    required bool isLong,
    required double entryPrice,
    required double exitPrice,
    required double positionSizeLots,
    this.stopLossPrice = const Value.absent(),
    this.takeProfitPrice = const Value.absent(),
    this.actualProfitLoss = const Value.absent(),
    this.commissionFees = const Value.absent(),
    this.swapFees = const Value.absent(),
    this.strategyTag = const Value.absent(),
    this.strategyId = const Value.absent(),
    this.reasonForEntry = const Value.absent(),
    this.reasonForExit = const Value.absent(),
    this.confidenceScore = const Value.absent(),
    this.customTagsJson = const Value.absent(),
    this.imagePathsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : pair = Value(pair),
       pairId = Value(pairId),
       entryDate = Value(entryDate),
       exitDate = Value(exitDate),
       isLong = Value(isLong),
       entryPrice = Value(entryPrice),
       exitPrice = Value(exitPrice),
       positionSizeLots = Value(positionSizeLots);
  static Insertable<Trade> custom({
    Expression<int>? id,
    Expression<String>? pair,
    Expression<int>? pairId,
    Expression<String>? userId,
    Expression<DateTime>? entryDate,
    Expression<DateTime>? exitDate,
    Expression<bool>? isLong,
    Expression<double>? entryPrice,
    Expression<double>? exitPrice,
    Expression<double>? positionSizeLots,
    Expression<double>? stopLossPrice,
    Expression<double>? takeProfitPrice,
    Expression<double>? actualProfitLoss,
    Expression<double>? commissionFees,
    Expression<double>? swapFees,
    Expression<String>? strategyTag,
    Expression<int>? strategyId,
    Expression<String>? reasonForEntry,
    Expression<String>? reasonForExit,
    Expression<int>? confidenceScore,
    Expression<String>? customTagsJson,
    Expression<String>? imagePathsJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pair != null) 'pair': pair,
      if (pairId != null) 'pair_id': pairId,
      if (userId != null) 'user_id': userId,
      if (entryDate != null) 'entry_date': entryDate,
      if (exitDate != null) 'exit_date': exitDate,
      if (isLong != null) 'is_long': isLong,
      if (entryPrice != null) 'entry_price': entryPrice,
      if (exitPrice != null) 'exit_price': exitPrice,
      if (positionSizeLots != null) 'position_size_lots': positionSizeLots,
      if (stopLossPrice != null) 'stop_loss_price': stopLossPrice,
      if (takeProfitPrice != null) 'take_profit_price': takeProfitPrice,
      if (actualProfitLoss != null) 'actual_profit_loss': actualProfitLoss,
      if (commissionFees != null) 'commission_fees': commissionFees,
      if (swapFees != null) 'swap_fees': swapFees,
      if (strategyTag != null) 'strategy_tag': strategyTag,
      if (strategyId != null) 'strategy_id': strategyId,
      if (reasonForEntry != null) 'reason_for_entry': reasonForEntry,
      if (reasonForExit != null) 'reason_for_exit': reasonForExit,
      if (confidenceScore != null) 'confidence_score': confidenceScore,
      if (customTagsJson != null) 'custom_tags_json': customTagsJson,
      if (imagePathsJson != null) 'image_paths_json': imagePathsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TradesCompanion copyWith({
    Value<int>? id,
    Value<String>? pair,
    Value<int>? pairId,
    Value<String>? userId,
    Value<DateTime>? entryDate,
    Value<DateTime>? exitDate,
    Value<bool>? isLong,
    Value<double>? entryPrice,
    Value<double>? exitPrice,
    Value<double>? positionSizeLots,
    Value<double?>? stopLossPrice,
    Value<double?>? takeProfitPrice,
    Value<double?>? actualProfitLoss,
    Value<double?>? commissionFees,
    Value<double?>? swapFees,
    Value<String?>? strategyTag,
    Value<int?>? strategyId,
    Value<String?>? reasonForEntry,
    Value<String?>? reasonForExit,
    Value<int?>? confidenceScore,
    Value<String?>? customTagsJson,
    Value<String?>? imagePathsJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return TradesCompanion(
      id: id ?? this.id,
      pair: pair ?? this.pair,
      pairId: pairId ?? this.pairId,
      userId: userId ?? this.userId,
      entryDate: entryDate ?? this.entryDate,
      exitDate: exitDate ?? this.exitDate,
      isLong: isLong ?? this.isLong,
      entryPrice: entryPrice ?? this.entryPrice,
      exitPrice: exitPrice ?? this.exitPrice,
      positionSizeLots: positionSizeLots ?? this.positionSizeLots,
      stopLossPrice: stopLossPrice ?? this.stopLossPrice,
      takeProfitPrice: takeProfitPrice ?? this.takeProfitPrice,
      actualProfitLoss: actualProfitLoss ?? this.actualProfitLoss,
      commissionFees: commissionFees ?? this.commissionFees,
      swapFees: swapFees ?? this.swapFees,
      strategyTag: strategyTag ?? this.strategyTag,
      strategyId: strategyId ?? this.strategyId,
      reasonForEntry: reasonForEntry ?? this.reasonForEntry,
      reasonForExit: reasonForExit ?? this.reasonForExit,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      customTagsJson: customTagsJson ?? this.customTagsJson,
      imagePathsJson: imagePathsJson ?? this.imagePathsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pair.present) {
      map['pair'] = Variable<String>(pair.value);
    }
    if (pairId.present) {
      map['pair_id'] = Variable<int>(pairId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<DateTime>(entryDate.value);
    }
    if (exitDate.present) {
      map['exit_date'] = Variable<DateTime>(exitDate.value);
    }
    if (isLong.present) {
      map['is_long'] = Variable<bool>(isLong.value);
    }
    if (entryPrice.present) {
      map['entry_price'] = Variable<double>(entryPrice.value);
    }
    if (exitPrice.present) {
      map['exit_price'] = Variable<double>(exitPrice.value);
    }
    if (positionSizeLots.present) {
      map['position_size_lots'] = Variable<double>(positionSizeLots.value);
    }
    if (stopLossPrice.present) {
      map['stop_loss_price'] = Variable<double>(stopLossPrice.value);
    }
    if (takeProfitPrice.present) {
      map['take_profit_price'] = Variable<double>(takeProfitPrice.value);
    }
    if (actualProfitLoss.present) {
      map['actual_profit_loss'] = Variable<double>(actualProfitLoss.value);
    }
    if (commissionFees.present) {
      map['commission_fees'] = Variable<double>(commissionFees.value);
    }
    if (swapFees.present) {
      map['swap_fees'] = Variable<double>(swapFees.value);
    }
    if (strategyTag.present) {
      map['strategy_tag'] = Variable<String>(strategyTag.value);
    }
    if (strategyId.present) {
      map['strategy_id'] = Variable<int>(strategyId.value);
    }
    if (reasonForEntry.present) {
      map['reason_for_entry'] = Variable<String>(reasonForEntry.value);
    }
    if (reasonForExit.present) {
      map['reason_for_exit'] = Variable<String>(reasonForExit.value);
    }
    if (confidenceScore.present) {
      map['confidence_score'] = Variable<int>(confidenceScore.value);
    }
    if (customTagsJson.present) {
      map['custom_tags_json'] = Variable<String>(customTagsJson.value);
    }
    if (imagePathsJson.present) {
      map['image_paths_json'] = Variable<String>(imagePathsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TradesCompanion(')
          ..write('id: $id, ')
          ..write('pair: $pair, ')
          ..write('pairId: $pairId, ')
          ..write('userId: $userId, ')
          ..write('entryDate: $entryDate, ')
          ..write('exitDate: $exitDate, ')
          ..write('isLong: $isLong, ')
          ..write('entryPrice: $entryPrice, ')
          ..write('exitPrice: $exitPrice, ')
          ..write('positionSizeLots: $positionSizeLots, ')
          ..write('stopLossPrice: $stopLossPrice, ')
          ..write('takeProfitPrice: $takeProfitPrice, ')
          ..write('actualProfitLoss: $actualProfitLoss, ')
          ..write('commissionFees: $commissionFees, ')
          ..write('swapFees: $swapFees, ')
          ..write('strategyTag: $strategyTag, ')
          ..write('strategyId: $strategyId, ')
          ..write('reasonForEntry: $reasonForEntry, ')
          ..write('reasonForExit: $reasonForExit, ')
          ..write('confidenceScore: $confidenceScore, ')
          ..write('customTagsJson: $customTagsJson, ')
          ..write('imagePathsJson: $imagePathsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PairsTable pairs = $PairsTable(this);
  late final $StrategiesTable strategies = $StrategiesTable(this);
  late final $TradesTable trades = $TradesTable(this);
  late final TradeDao tradeDao = TradeDao(this as AppDatabase);
  late final StrategyDao strategyDao = StrategyDao(this as AppDatabase);
  late final PairDao pairDao = PairDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    pairs,
    strategies,
    trades,
  ];
}

typedef $$PairsTableCreateCompanionBuilder =
    PairsCompanion Function({
      Value<int> id,
      required String name,
      Value<String> userId,
      Value<DateTime> createdAt,
    });
typedef $$PairsTableUpdateCompanionBuilder =
    PairsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> userId,
      Value<DateTime> createdAt,
    });

final class $$PairsTableReferences
    extends BaseReferences<_$AppDatabase, $PairsTable, Pair> {
  $$PairsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TradesTable, List<Trade>> _tradesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.trades,
    aliasName: $_aliasNameGenerator(db.pairs.id, db.trades.pairId),
  );

  $$TradesTableProcessedTableManager get tradesRefs {
    final manager = $$TradesTableTableManager(
      $_db,
      $_db.trades,
    ).filter((f) => f.pairId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tradesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PairsTableFilterComposer extends Composer<_$AppDatabase, $PairsTable> {
  $$PairsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tradesRefs(
    Expression<bool> Function($$TradesTableFilterComposer f) f,
  ) {
    final $$TradesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trades,
      getReferencedColumn: (t) => t.pairId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TradesTableFilterComposer(
            $db: $db,
            $table: $db.trades,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PairsTableOrderingComposer
    extends Composer<_$AppDatabase, $PairsTable> {
  $$PairsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PairsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PairsTable> {
  $$PairsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> tradesRefs<T extends Object>(
    Expression<T> Function($$TradesTableAnnotationComposer a) f,
  ) {
    final $$TradesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trades,
      getReferencedColumn: (t) => t.pairId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TradesTableAnnotationComposer(
            $db: $db,
            $table: $db.trades,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PairsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PairsTable,
          Pair,
          $$PairsTableFilterComposer,
          $$PairsTableOrderingComposer,
          $$PairsTableAnnotationComposer,
          $$PairsTableCreateCompanionBuilder,
          $$PairsTableUpdateCompanionBuilder,
          (Pair, $$PairsTableReferences),
          Pair,
          PrefetchHooks Function({bool tradesRefs})
        > {
  $$PairsTableTableManager(_$AppDatabase db, $PairsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$PairsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$PairsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$PairsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PairsCompanion(
                id: id,
                name: name,
                userId: userId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PairsCompanion.insert(
                id: id,
                name: name,
                userId: userId,
                createdAt: createdAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$PairsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({tradesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tradesRefs) db.trades],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tradesRefs)
                    await $_getPrefetchedData<Pair, $PairsTable, Trade>(
                      currentTable: table,
                      referencedTable: $$PairsTableReferences._tradesRefsTable(
                        db,
                      ),
                      managerFromTypedResult:
                          (p0) =>
                              $$PairsTableReferences(db, table, p0).tradesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.pairId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PairsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PairsTable,
      Pair,
      $$PairsTableFilterComposer,
      $$PairsTableOrderingComposer,
      $$PairsTableAnnotationComposer,
      $$PairsTableCreateCompanionBuilder,
      $$PairsTableUpdateCompanionBuilder,
      (Pair, $$PairsTableReferences),
      Pair,
      PrefetchHooks Function({bool tradesRefs})
    >;
typedef $$StrategiesTableCreateCompanionBuilder =
    StrategiesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> description,
      Value<String> userId,
      Value<DateTime> createdAt,
    });
typedef $$StrategiesTableUpdateCompanionBuilder =
    StrategiesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> description,
      Value<String> userId,
      Value<DateTime> createdAt,
    });

final class $$StrategiesTableReferences
    extends BaseReferences<_$AppDatabase, $StrategiesTable, Strategy> {
  $$StrategiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TradesTable, List<Trade>> _tradesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.trades,
    aliasName: $_aliasNameGenerator(db.strategies.id, db.trades.strategyId),
  );

  $$TradesTableProcessedTableManager get tradesRefs {
    final manager = $$TradesTableTableManager(
      $_db,
      $_db.trades,
    ).filter((f) => f.strategyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tradesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StrategiesTableFilterComposer
    extends Composer<_$AppDatabase, $StrategiesTable> {
  $$StrategiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tradesRefs(
    Expression<bool> Function($$TradesTableFilterComposer f) f,
  ) {
    final $$TradesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trades,
      getReferencedColumn: (t) => t.strategyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TradesTableFilterComposer(
            $db: $db,
            $table: $db.trades,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StrategiesTableOrderingComposer
    extends Composer<_$AppDatabase, $StrategiesTable> {
  $$StrategiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StrategiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StrategiesTable> {
  $$StrategiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> tradesRefs<T extends Object>(
    Expression<T> Function($$TradesTableAnnotationComposer a) f,
  ) {
    final $$TradesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trades,
      getReferencedColumn: (t) => t.strategyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TradesTableAnnotationComposer(
            $db: $db,
            $table: $db.trades,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StrategiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StrategiesTable,
          Strategy,
          $$StrategiesTableFilterComposer,
          $$StrategiesTableOrderingComposer,
          $$StrategiesTableAnnotationComposer,
          $$StrategiesTableCreateCompanionBuilder,
          $$StrategiesTableUpdateCompanionBuilder,
          (Strategy, $$StrategiesTableReferences),
          Strategy,
          PrefetchHooks Function({bool tradesRefs})
        > {
  $$StrategiesTableTableManager(_$AppDatabase db, $StrategiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$StrategiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$StrategiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$StrategiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => StrategiesCompanion(
                id: id,
                name: name,
                description: description,
                userId: userId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => StrategiesCompanion.insert(
                id: id,
                name: name,
                description: description,
                userId: userId,
                createdAt: createdAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$StrategiesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({tradesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tradesRefs) db.trades],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tradesRefs)
                    await $_getPrefetchedData<
                      Strategy,
                      $StrategiesTable,
                      Trade
                    >(
                      currentTable: table,
                      referencedTable: $$StrategiesTableReferences
                          ._tradesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$StrategiesTableReferences(
                                db,
                                table,
                                p0,
                              ).tradesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.strategyId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$StrategiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StrategiesTable,
      Strategy,
      $$StrategiesTableFilterComposer,
      $$StrategiesTableOrderingComposer,
      $$StrategiesTableAnnotationComposer,
      $$StrategiesTableCreateCompanionBuilder,
      $$StrategiesTableUpdateCompanionBuilder,
      (Strategy, $$StrategiesTableReferences),
      Strategy,
      PrefetchHooks Function({bool tradesRefs})
    >;
typedef $$TradesTableCreateCompanionBuilder =
    TradesCompanion Function({
      Value<int> id,
      required String pair,
      required int pairId,
      Value<String> userId,
      required DateTime entryDate,
      required DateTime exitDate,
      required bool isLong,
      required double entryPrice,
      required double exitPrice,
      required double positionSizeLots,
      Value<double?> stopLossPrice,
      Value<double?> takeProfitPrice,
      Value<double?> actualProfitLoss,
      Value<double?> commissionFees,
      Value<double?> swapFees,
      Value<String?> strategyTag,
      Value<int?> strategyId,
      Value<String?> reasonForEntry,
      Value<String?> reasonForExit,
      Value<int?> confidenceScore,
      Value<String?> customTagsJson,
      Value<String?> imagePathsJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$TradesTableUpdateCompanionBuilder =
    TradesCompanion Function({
      Value<int> id,
      Value<String> pair,
      Value<int> pairId,
      Value<String> userId,
      Value<DateTime> entryDate,
      Value<DateTime> exitDate,
      Value<bool> isLong,
      Value<double> entryPrice,
      Value<double> exitPrice,
      Value<double> positionSizeLots,
      Value<double?> stopLossPrice,
      Value<double?> takeProfitPrice,
      Value<double?> actualProfitLoss,
      Value<double?> commissionFees,
      Value<double?> swapFees,
      Value<String?> strategyTag,
      Value<int?> strategyId,
      Value<String?> reasonForEntry,
      Value<String?> reasonForExit,
      Value<int?> confidenceScore,
      Value<String?> customTagsJson,
      Value<String?> imagePathsJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$TradesTableReferences
    extends BaseReferences<_$AppDatabase, $TradesTable, Trade> {
  $$TradesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PairsTable _pairIdTable(_$AppDatabase db) =>
      db.pairs.createAlias($_aliasNameGenerator(db.trades.pairId, db.pairs.id));

  $$PairsTableProcessedTableManager get pairId {
    final $_column = $_itemColumn<int>('pair_id')!;

    final manager = $$PairsTableTableManager(
      $_db,
      $_db.pairs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pairIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StrategiesTable _strategyIdTable(_$AppDatabase db) =>
      db.strategies.createAlias(
        $_aliasNameGenerator(db.trades.strategyId, db.strategies.id),
      );

  $$StrategiesTableProcessedTableManager? get strategyId {
    final $_column = $_itemColumn<int>('strategy_id');
    if ($_column == null) return null;
    final manager = $$StrategiesTableTableManager(
      $_db,
      $_db.strategies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_strategyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TradesTableFilterComposer
    extends Composer<_$AppDatabase, $TradesTable> {
  $$TradesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pair => $composableBuilder(
    column: $table.pair,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get exitDate => $composableBuilder(
    column: $table.exitDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLong => $composableBuilder(
    column: $table.isLong,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get entryPrice => $composableBuilder(
    column: $table.entryPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get exitPrice => $composableBuilder(
    column: $table.exitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get positionSizeLots => $composableBuilder(
    column: $table.positionSizeLots,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stopLossPrice => $composableBuilder(
    column: $table.stopLossPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get takeProfitPrice => $composableBuilder(
    column: $table.takeProfitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualProfitLoss => $composableBuilder(
    column: $table.actualProfitLoss,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get commissionFees => $composableBuilder(
    column: $table.commissionFees,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get swapFees => $composableBuilder(
    column: $table.swapFees,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get strategyTag => $composableBuilder(
    column: $table.strategyTag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reasonForEntry => $composableBuilder(
    column: $table.reasonForEntry,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reasonForExit => $composableBuilder(
    column: $table.reasonForExit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get confidenceScore => $composableBuilder(
    column: $table.confidenceScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customTagsJson => $composableBuilder(
    column: $table.customTagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePathsJson => $composableBuilder(
    column: $table.imagePathsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PairsTableFilterComposer get pairId {
    final $$PairsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pairId,
      referencedTable: $db.pairs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PairsTableFilterComposer(
            $db: $db,
            $table: $db.pairs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StrategiesTableFilterComposer get strategyId {
    final $$StrategiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strategyId,
      referencedTable: $db.strategies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategiesTableFilterComposer(
            $db: $db,
            $table: $db.strategies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TradesTableOrderingComposer
    extends Composer<_$AppDatabase, $TradesTable> {
  $$TradesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pair => $composableBuilder(
    column: $table.pair,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get exitDate => $composableBuilder(
    column: $table.exitDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLong => $composableBuilder(
    column: $table.isLong,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get entryPrice => $composableBuilder(
    column: $table.entryPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get exitPrice => $composableBuilder(
    column: $table.exitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get positionSizeLots => $composableBuilder(
    column: $table.positionSizeLots,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stopLossPrice => $composableBuilder(
    column: $table.stopLossPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get takeProfitPrice => $composableBuilder(
    column: $table.takeProfitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualProfitLoss => $composableBuilder(
    column: $table.actualProfitLoss,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get commissionFees => $composableBuilder(
    column: $table.commissionFees,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get swapFees => $composableBuilder(
    column: $table.swapFees,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strategyTag => $composableBuilder(
    column: $table.strategyTag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reasonForEntry => $composableBuilder(
    column: $table.reasonForEntry,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reasonForExit => $composableBuilder(
    column: $table.reasonForExit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get confidenceScore => $composableBuilder(
    column: $table.confidenceScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customTagsJson => $composableBuilder(
    column: $table.customTagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePathsJson => $composableBuilder(
    column: $table.imagePathsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PairsTableOrderingComposer get pairId {
    final $$PairsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pairId,
      referencedTable: $db.pairs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PairsTableOrderingComposer(
            $db: $db,
            $table: $db.pairs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StrategiesTableOrderingComposer get strategyId {
    final $$StrategiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strategyId,
      referencedTable: $db.strategies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategiesTableOrderingComposer(
            $db: $db,
            $table: $db.strategies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TradesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TradesTable> {
  $$TradesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pair =>
      $composableBuilder(column: $table.pair, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<DateTime> get exitDate =>
      $composableBuilder(column: $table.exitDate, builder: (column) => column);

  GeneratedColumn<bool> get isLong =>
      $composableBuilder(column: $table.isLong, builder: (column) => column);

  GeneratedColumn<double> get entryPrice => $composableBuilder(
    column: $table.entryPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get exitPrice =>
      $composableBuilder(column: $table.exitPrice, builder: (column) => column);

  GeneratedColumn<double> get positionSizeLots => $composableBuilder(
    column: $table.positionSizeLots,
    builder: (column) => column,
  );

  GeneratedColumn<double> get stopLossPrice => $composableBuilder(
    column: $table.stopLossPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get takeProfitPrice => $composableBuilder(
    column: $table.takeProfitPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get actualProfitLoss => $composableBuilder(
    column: $table.actualProfitLoss,
    builder: (column) => column,
  );

  GeneratedColumn<double> get commissionFees => $composableBuilder(
    column: $table.commissionFees,
    builder: (column) => column,
  );

  GeneratedColumn<double> get swapFees =>
      $composableBuilder(column: $table.swapFees, builder: (column) => column);

  GeneratedColumn<String> get strategyTag => $composableBuilder(
    column: $table.strategyTag,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reasonForEntry => $composableBuilder(
    column: $table.reasonForEntry,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reasonForExit => $composableBuilder(
    column: $table.reasonForExit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get confidenceScore => $composableBuilder(
    column: $table.confidenceScore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customTagsJson => $composableBuilder(
    column: $table.customTagsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagePathsJson => $composableBuilder(
    column: $table.imagePathsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$PairsTableAnnotationComposer get pairId {
    final $$PairsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pairId,
      referencedTable: $db.pairs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PairsTableAnnotationComposer(
            $db: $db,
            $table: $db.pairs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StrategiesTableAnnotationComposer get strategyId {
    final $$StrategiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.strategyId,
      referencedTable: $db.strategies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrategiesTableAnnotationComposer(
            $db: $db,
            $table: $db.strategies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TradesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TradesTable,
          Trade,
          $$TradesTableFilterComposer,
          $$TradesTableOrderingComposer,
          $$TradesTableAnnotationComposer,
          $$TradesTableCreateCompanionBuilder,
          $$TradesTableUpdateCompanionBuilder,
          (Trade, $$TradesTableReferences),
          Trade,
          PrefetchHooks Function({bool pairId, bool strategyId})
        > {
  $$TradesTableTableManager(_$AppDatabase db, $TradesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$TradesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$TradesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$TradesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> pair = const Value.absent(),
                Value<int> pairId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> entryDate = const Value.absent(),
                Value<DateTime> exitDate = const Value.absent(),
                Value<bool> isLong = const Value.absent(),
                Value<double> entryPrice = const Value.absent(),
                Value<double> exitPrice = const Value.absent(),
                Value<double> positionSizeLots = const Value.absent(),
                Value<double?> stopLossPrice = const Value.absent(),
                Value<double?> takeProfitPrice = const Value.absent(),
                Value<double?> actualProfitLoss = const Value.absent(),
                Value<double?> commissionFees = const Value.absent(),
                Value<double?> swapFees = const Value.absent(),
                Value<String?> strategyTag = const Value.absent(),
                Value<int?> strategyId = const Value.absent(),
                Value<String?> reasonForEntry = const Value.absent(),
                Value<String?> reasonForExit = const Value.absent(),
                Value<int?> confidenceScore = const Value.absent(),
                Value<String?> customTagsJson = const Value.absent(),
                Value<String?> imagePathsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TradesCompanion(
                id: id,
                pair: pair,
                pairId: pairId,
                userId: userId,
                entryDate: entryDate,
                exitDate: exitDate,
                isLong: isLong,
                entryPrice: entryPrice,
                exitPrice: exitPrice,
                positionSizeLots: positionSizeLots,
                stopLossPrice: stopLossPrice,
                takeProfitPrice: takeProfitPrice,
                actualProfitLoss: actualProfitLoss,
                commissionFees: commissionFees,
                swapFees: swapFees,
                strategyTag: strategyTag,
                strategyId: strategyId,
                reasonForEntry: reasonForEntry,
                reasonForExit: reasonForExit,
                confidenceScore: confidenceScore,
                customTagsJson: customTagsJson,
                imagePathsJson: imagePathsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String pair,
                required int pairId,
                Value<String> userId = const Value.absent(),
                required DateTime entryDate,
                required DateTime exitDate,
                required bool isLong,
                required double entryPrice,
                required double exitPrice,
                required double positionSizeLots,
                Value<double?> stopLossPrice = const Value.absent(),
                Value<double?> takeProfitPrice = const Value.absent(),
                Value<double?> actualProfitLoss = const Value.absent(),
                Value<double?> commissionFees = const Value.absent(),
                Value<double?> swapFees = const Value.absent(),
                Value<String?> strategyTag = const Value.absent(),
                Value<int?> strategyId = const Value.absent(),
                Value<String?> reasonForEntry = const Value.absent(),
                Value<String?> reasonForExit = const Value.absent(),
                Value<int?> confidenceScore = const Value.absent(),
                Value<String?> customTagsJson = const Value.absent(),
                Value<String?> imagePathsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TradesCompanion.insert(
                id: id,
                pair: pair,
                pairId: pairId,
                userId: userId,
                entryDate: entryDate,
                exitDate: exitDate,
                isLong: isLong,
                entryPrice: entryPrice,
                exitPrice: exitPrice,
                positionSizeLots: positionSizeLots,
                stopLossPrice: stopLossPrice,
                takeProfitPrice: takeProfitPrice,
                actualProfitLoss: actualProfitLoss,
                commissionFees: commissionFees,
                swapFees: swapFees,
                strategyTag: strategyTag,
                strategyId: strategyId,
                reasonForEntry: reasonForEntry,
                reasonForExit: reasonForExit,
                confidenceScore: confidenceScore,
                customTagsJson: customTagsJson,
                imagePathsJson: imagePathsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$TradesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({pairId = false, strategyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (pairId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.pairId,
                            referencedTable: $$TradesTableReferences
                                ._pairIdTable(db),
                            referencedColumn:
                                $$TradesTableReferences._pairIdTable(db).id,
                          )
                          as T;
                }
                if (strategyId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.strategyId,
                            referencedTable: $$TradesTableReferences
                                ._strategyIdTable(db),
                            referencedColumn:
                                $$TradesTableReferences._strategyIdTable(db).id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TradesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TradesTable,
      Trade,
      $$TradesTableFilterComposer,
      $$TradesTableOrderingComposer,
      $$TradesTableAnnotationComposer,
      $$TradesTableCreateCompanionBuilder,
      $$TradesTableUpdateCompanionBuilder,
      (Trade, $$TradesTableReferences),
      Trade,
      PrefetchHooks Function({bool pairId, bool strategyId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PairsTableTableManager get pairs =>
      $$PairsTableTableManager(_db, _db.pairs);
  $$StrategiesTableTableManager get strategies =>
      $$StrategiesTableTableManager(_db, _db.strategies);
  $$TradesTableTableManager get trades =>
      $$TradesTableTableManager(_db, _db.trades);
}

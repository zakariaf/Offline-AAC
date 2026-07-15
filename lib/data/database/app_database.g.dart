// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BoardsTable extends Boards with TableInfo<$BoardsTable, Board> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BoardsTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en'),
  );
  static const VerificationMeta _gridRowsMeta = const VerificationMeta(
    'gridRows',
  );
  @override
  late final GeneratedColumn<int> gridRows = GeneratedColumn<int>(
    'grid_rows',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gridColsMeta = const VerificationMeta(
    'gridCols',
  );
  @override
  late final GeneratedColumn<int> gridCols = GeneratedColumn<int>(
    'grid_cols',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isRootMeta = const VerificationMeta('isRoot');
  @override
  late final GeneratedColumn<bool> isRoot = GeneratedColumn<bool>(
    'is_root',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_root" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    name,
    locale,
    gridRows,
    gridCols,
    isRoot,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'boards';
  @override
  VerificationContext validateIntegrity(
    Insertable<Board> instance, {
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
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    }
    if (data.containsKey('grid_rows')) {
      context.handle(
        _gridRowsMeta,
        gridRows.isAcceptableOrUnknown(data['grid_rows']!, _gridRowsMeta),
      );
    } else if (isInserting) {
      context.missing(_gridRowsMeta);
    }
    if (data.containsKey('grid_cols')) {
      context.handle(
        _gridColsMeta,
        gridCols.isAcceptableOrUnknown(data['grid_cols']!, _gridColsMeta),
      );
    } else if (isInserting) {
      context.missing(_gridColsMeta);
    }
    if (data.containsKey('is_root')) {
      context.handle(
        _isRootMeta,
        isRoot.isAcceptableOrUnknown(data['is_root']!, _isRootMeta),
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
  Board map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Board(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      )!,
      gridRows: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grid_rows'],
      )!,
      gridCols: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grid_cols'],
      )!,
      isRoot: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_root'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BoardsTable createAlias(String alias) {
    return $BoardsTable(attachedDatabase, alias);
  }
}

class Board extends DataClass implements Insertable<Board> {
  final int id;
  final String name;
  final String locale;

  /// The grid is NOT hardcoded 3x4. A 2x3 large layout ships alongside it, so
  /// bounds live here as data and are enforced in BoardRepository — never as a
  /// SQL CHECK, which would make the 2x3 layout an insert failure at v2.
  final int gridRows;
  final int gridCols;
  final bool isRoot;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Board({
    required this.id,
    required this.name,
    required this.locale,
    required this.gridRows,
    required this.gridCols,
    required this.isRoot,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['locale'] = Variable<String>(locale);
    map['grid_rows'] = Variable<int>(gridRows);
    map['grid_cols'] = Variable<int>(gridCols);
    map['is_root'] = Variable<bool>(isRoot);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BoardsCompanion toCompanion(bool nullToAbsent) {
    return BoardsCompanion(
      id: Value(id),
      name: Value(name),
      locale: Value(locale),
      gridRows: Value(gridRows),
      gridCols: Value(gridCols),
      isRoot: Value(isRoot),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Board.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Board(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      locale: serializer.fromJson<String>(json['locale']),
      gridRows: serializer.fromJson<int>(json['gridRows']),
      gridCols: serializer.fromJson<int>(json['gridCols']),
      isRoot: serializer.fromJson<bool>(json['isRoot']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'locale': serializer.toJson<String>(locale),
      'gridRows': serializer.toJson<int>(gridRows),
      'gridCols': serializer.toJson<int>(gridCols),
      'isRoot': serializer.toJson<bool>(isRoot),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Board copyWith({
    int? id,
    String? name,
    String? locale,
    int? gridRows,
    int? gridCols,
    bool? isRoot,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Board(
    id: id ?? this.id,
    name: name ?? this.name,
    locale: locale ?? this.locale,
    gridRows: gridRows ?? this.gridRows,
    gridCols: gridCols ?? this.gridCols,
    isRoot: isRoot ?? this.isRoot,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Board copyWithCompanion(BoardsCompanion data) {
    return Board(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      locale: data.locale.present ? data.locale.value : this.locale,
      gridRows: data.gridRows.present ? data.gridRows.value : this.gridRows,
      gridCols: data.gridCols.present ? data.gridCols.value : this.gridCols,
      isRoot: data.isRoot.present ? data.isRoot.value : this.isRoot,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Board(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('locale: $locale, ')
          ..write('gridRows: $gridRows, ')
          ..write('gridCols: $gridCols, ')
          ..write('isRoot: $isRoot, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    locale,
    gridRows,
    gridCols,
    isRoot,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Board &&
          other.id == this.id &&
          other.name == this.name &&
          other.locale == this.locale &&
          other.gridRows == this.gridRows &&
          other.gridCols == this.gridCols &&
          other.isRoot == this.isRoot &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BoardsCompanion extends UpdateCompanion<Board> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> locale;
  final Value<int> gridRows;
  final Value<int> gridCols;
  final Value<bool> isRoot;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const BoardsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.locale = const Value.absent(),
    this.gridRows = const Value.absent(),
    this.gridCols = const Value.absent(),
    this.isRoot = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  BoardsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.locale = const Value.absent(),
    required int gridRows,
    required int gridCols,
    this.isRoot = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       gridRows = Value(gridRows),
       gridCols = Value(gridCols);
  static Insertable<Board> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? locale,
    Expression<int>? gridRows,
    Expression<int>? gridCols,
    Expression<bool>? isRoot,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (locale != null) 'locale': locale,
      if (gridRows != null) 'grid_rows': gridRows,
      if (gridCols != null) 'grid_cols': gridCols,
      if (isRoot != null) 'is_root': isRoot,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  BoardsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? locale,
    Value<int>? gridRows,
    Value<int>? gridCols,
    Value<bool>? isRoot,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return BoardsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      locale: locale ?? this.locale,
      gridRows: gridRows ?? this.gridRows,
      gridCols: gridCols ?? this.gridCols,
      isRoot: isRoot ?? this.isRoot,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (gridRows.present) {
      map['grid_rows'] = Variable<int>(gridRows.value);
    }
    if (gridCols.present) {
      map['grid_cols'] = Variable<int>(gridCols.value);
    }
    if (isRoot.present) {
      map['is_root'] = Variable<bool>(isRoot.value);
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
    return (StringBuffer('BoardsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('locale: $locale, ')
          ..write('gridRows: $gridRows, ')
          ..write('gridCols: $gridCols, ')
          ..write('isRoot: $isRoot, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ImagesTable extends Images with TableInfo<$ImagesTable, MediaImage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImagesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentTypeMeta = const VerificationMeta(
    'contentType',
  );
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
    'content_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _licenseMeta = const VerificationMeta(
    'license',
  );
  @override
  late final GeneratedColumn<String> license = GeneratedColumn<String>(
    'license',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attributionMeta = const VerificationMeta(
    'attribution',
  );
  @override
  late final GeneratedColumn<String> attribution = GeneratedColumn<String>(
    'attribution',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    path,
    contentType,
    width,
    height,
    license,
    attribution,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'images';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaImage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('content_type')) {
      context.handle(
        _contentTypeMeta,
        contentType.isAcceptableOrUnknown(
          data['content_type']!,
          _contentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentTypeMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    } else if (isInserting) {
      context.missing(_widthMeta);
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    } else if (isInserting) {
      context.missing(_heightMeta);
    }
    if (data.containsKey('license')) {
      context.handle(
        _licenseMeta,
        license.isAcceptableOrUnknown(data['license']!, _licenseMeta),
      );
    }
    if (data.containsKey('attribution')) {
      context.handle(
        _attributionMeta,
        attribution.isAcceptableOrUnknown(
          data['attribution']!,
          _attributionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaImage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaImage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      contentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_type'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      )!,
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      )!,
      license: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license'],
      ),
      attribution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attribution'],
      ),
    );
  }

  @override
  $ImagesTable createAlias(String alias) {
    return $ImagesTable(attachedDatabase, alias);
  }
}

class MediaImage extends DataClass implements Insertable<MediaImage> {
  final int id;
  final String path;
  final String contentType;
  final int width;
  final int height;

  /// Symbol-set attribution lives here, per image, because a licence obligation
  /// that lives only in a README is one refactor from being unmet.
  final String? license;
  final String? attribution;
  const MediaImage({
    required this.id,
    required this.path,
    required this.contentType,
    required this.width,
    required this.height,
    this.license,
    this.attribution,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['path'] = Variable<String>(path);
    map['content_type'] = Variable<String>(contentType);
    map['width'] = Variable<int>(width);
    map['height'] = Variable<int>(height);
    if (!nullToAbsent || license != null) {
      map['license'] = Variable<String>(license);
    }
    if (!nullToAbsent || attribution != null) {
      map['attribution'] = Variable<String>(attribution);
    }
    return map;
  }

  ImagesCompanion toCompanion(bool nullToAbsent) {
    return ImagesCompanion(
      id: Value(id),
      path: Value(path),
      contentType: Value(contentType),
      width: Value(width),
      height: Value(height),
      license: license == null && nullToAbsent
          ? const Value.absent()
          : Value(license),
      attribution: attribution == null && nullToAbsent
          ? const Value.absent()
          : Value(attribution),
    );
  }

  factory MediaImage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaImage(
      id: serializer.fromJson<int>(json['id']),
      path: serializer.fromJson<String>(json['path']),
      contentType: serializer.fromJson<String>(json['contentType']),
      width: serializer.fromJson<int>(json['width']),
      height: serializer.fromJson<int>(json['height']),
      license: serializer.fromJson<String?>(json['license']),
      attribution: serializer.fromJson<String?>(json['attribution']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'path': serializer.toJson<String>(path),
      'contentType': serializer.toJson<String>(contentType),
      'width': serializer.toJson<int>(width),
      'height': serializer.toJson<int>(height),
      'license': serializer.toJson<String?>(license),
      'attribution': serializer.toJson<String?>(attribution),
    };
  }

  MediaImage copyWith({
    int? id,
    String? path,
    String? contentType,
    int? width,
    int? height,
    Value<String?> license = const Value.absent(),
    Value<String?> attribution = const Value.absent(),
  }) => MediaImage(
    id: id ?? this.id,
    path: path ?? this.path,
    contentType: contentType ?? this.contentType,
    width: width ?? this.width,
    height: height ?? this.height,
    license: license.present ? license.value : this.license,
    attribution: attribution.present ? attribution.value : this.attribution,
  );
  MediaImage copyWithCompanion(ImagesCompanion data) {
    return MediaImage(
      id: data.id.present ? data.id.value : this.id,
      path: data.path.present ? data.path.value : this.path,
      contentType: data.contentType.present
          ? data.contentType.value
          : this.contentType,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      license: data.license.present ? data.license.value : this.license,
      attribution: data.attribution.present
          ? data.attribution.value
          : this.attribution,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaImage(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('contentType: $contentType, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('license: $license, ')
          ..write('attribution: $attribution')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, path, contentType, width, height, license, attribution);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaImage &&
          other.id == this.id &&
          other.path == this.path &&
          other.contentType == this.contentType &&
          other.width == this.width &&
          other.height == this.height &&
          other.license == this.license &&
          other.attribution == this.attribution);
}

class ImagesCompanion extends UpdateCompanion<MediaImage> {
  final Value<int> id;
  final Value<String> path;
  final Value<String> contentType;
  final Value<int> width;
  final Value<int> height;
  final Value<String?> license;
  final Value<String?> attribution;
  const ImagesCompanion({
    this.id = const Value.absent(),
    this.path = const Value.absent(),
    this.contentType = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.license = const Value.absent(),
    this.attribution = const Value.absent(),
  });
  ImagesCompanion.insert({
    this.id = const Value.absent(),
    required String path,
    required String contentType,
    required int width,
    required int height,
    this.license = const Value.absent(),
    this.attribution = const Value.absent(),
  }) : path = Value(path),
       contentType = Value(contentType),
       width = Value(width),
       height = Value(height);
  static Insertable<MediaImage> custom({
    Expression<int>? id,
    Expression<String>? path,
    Expression<String>? contentType,
    Expression<int>? width,
    Expression<int>? height,
    Expression<String>? license,
    Expression<String>? attribution,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (path != null) 'path': path,
      if (contentType != null) 'content_type': contentType,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (license != null) 'license': license,
      if (attribution != null) 'attribution': attribution,
    });
  }

  ImagesCompanion copyWith({
    Value<int>? id,
    Value<String>? path,
    Value<String>? contentType,
    Value<int>? width,
    Value<int>? height,
    Value<String?>? license,
    Value<String?>? attribution,
  }) {
    return ImagesCompanion(
      id: id ?? this.id,
      path: path ?? this.path,
      contentType: contentType ?? this.contentType,
      width: width ?? this.width,
      height: height ?? this.height,
      license: license ?? this.license,
      attribution: attribution ?? this.attribution,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (license.present) {
      map['license'] = Variable<String>(license.value);
    }
    if (attribution.present) {
      map['attribution'] = Variable<String>(attribution.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImagesCompanion(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('contentType: $contentType, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('license: $license, ')
          ..write('attribution: $attribution')
          ..write(')'))
        .toString();
  }
}

class $SoundsTable extends Sounds with TableInfo<$SoundsTable, MediaSound> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SoundsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentTypeMeta = const VerificationMeta(
    'contentType',
  );
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
    'content_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, path, contentType, durationMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sounds';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaSound> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('content_type')) {
      context.handle(
        _contentTypeMeta,
        contentType.isAcceptableOrUnknown(
          data['content_type']!,
          _contentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentTypeMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaSound map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaSound(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      contentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_type'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
    );
  }

  @override
  $SoundsTable createAlias(String alias) {
    return $SoundsTable(attachedDatabase, alias);
  }
}

class MediaSound extends DataClass implements Insertable<MediaSound> {
  final int id;
  final String path;
  final String contentType;
  final int durationMs;
  const MediaSound({
    required this.id,
    required this.path,
    required this.contentType,
    required this.durationMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['path'] = Variable<String>(path);
    map['content_type'] = Variable<String>(contentType);
    map['duration_ms'] = Variable<int>(durationMs);
    return map;
  }

  SoundsCompanion toCompanion(bool nullToAbsent) {
    return SoundsCompanion(
      id: Value(id),
      path: Value(path),
      contentType: Value(contentType),
      durationMs: Value(durationMs),
    );
  }

  factory MediaSound.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaSound(
      id: serializer.fromJson<int>(json['id']),
      path: serializer.fromJson<String>(json['path']),
      contentType: serializer.fromJson<String>(json['contentType']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'path': serializer.toJson<String>(path),
      'contentType': serializer.toJson<String>(contentType),
      'durationMs': serializer.toJson<int>(durationMs),
    };
  }

  MediaSound copyWith({
    int? id,
    String? path,
    String? contentType,
    int? durationMs,
  }) => MediaSound(
    id: id ?? this.id,
    path: path ?? this.path,
    contentType: contentType ?? this.contentType,
    durationMs: durationMs ?? this.durationMs,
  );
  MediaSound copyWithCompanion(SoundsCompanion data) {
    return MediaSound(
      id: data.id.present ? data.id.value : this.id,
      path: data.path.present ? data.path.value : this.path,
      contentType: data.contentType.present
          ? data.contentType.value
          : this.contentType,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaSound(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('contentType: $contentType, ')
          ..write('durationMs: $durationMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, path, contentType, durationMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaSound &&
          other.id == this.id &&
          other.path == this.path &&
          other.contentType == this.contentType &&
          other.durationMs == this.durationMs);
}

class SoundsCompanion extends UpdateCompanion<MediaSound> {
  final Value<int> id;
  final Value<String> path;
  final Value<String> contentType;
  final Value<int> durationMs;
  const SoundsCompanion({
    this.id = const Value.absent(),
    this.path = const Value.absent(),
    this.contentType = const Value.absent(),
    this.durationMs = const Value.absent(),
  });
  SoundsCompanion.insert({
    this.id = const Value.absent(),
    required String path,
    required String contentType,
    required int durationMs,
  }) : path = Value(path),
       contentType = Value(contentType),
       durationMs = Value(durationMs);
  static Insertable<MediaSound> custom({
    Expression<int>? id,
    Expression<String>? path,
    Expression<String>? contentType,
    Expression<int>? durationMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (path != null) 'path': path,
      if (contentType != null) 'content_type': contentType,
      if (durationMs != null) 'duration_ms': durationMs,
    });
  }

  SoundsCompanion copyWith({
    Value<int>? id,
    Value<String>? path,
    Value<String>? contentType,
    Value<int>? durationMs,
  }) {
    return SoundsCompanion(
      id: id ?? this.id,
      path: path ?? this.path,
      contentType: contentType ?? this.contentType,
      durationMs: durationMs ?? this.durationMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SoundsCompanion(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('contentType: $contentType, ')
          ..write('durationMs: $durationMs')
          ..write(')'))
        .toString();
  }
}

class $ButtonsTable extends Buttons with TableInfo<$ButtonsTable, Button> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ButtonsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _boardIdMeta = const VerificationMeta(
    'boardId',
  );
  @override
  late final GeneratedColumn<int> boardId = GeneratedColumn<int>(
    'board_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES boards (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 16,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vocalizationMeta = const VerificationMeta(
    'vocalization',
  );
  @override
  late final GeneratedColumn<String> vocalization = GeneratedColumn<String>(
    'vocalization',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayTextMeta = const VerificationMeta(
    'displayText',
  );
  @override
  late final GeneratedColumn<String> displayText = GeneratedColumn<String>(
    'display_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hiddenMeta = const VerificationMeta('hidden');
  @override
  late final GeneratedColumn<bool> hidden = GeneratedColumn<bool>(
    'hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _userEditedMeta = const VerificationMeta(
    'userEdited',
  );
  @override
  late final GeneratedColumn<bool> userEdited = GeneratedColumn<bool>(
    'user_edited',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("user_edited" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _backgroundColorMeta = const VerificationMeta(
    'backgroundColor',
  );
  @override
  late final GeneratedColumn<String> backgroundColor = GeneratedColumn<String>(
    'background_color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _borderColorMeta = const VerificationMeta(
    'borderColor',
  );
  @override
  late final GeneratedColumn<String> borderColor = GeneratedColumn<String>(
    'border_color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageIdMeta = const VerificationMeta(
    'imageId',
  );
  @override
  late final GeneratedColumn<int> imageId = GeneratedColumn<int>(
    'image_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES images (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _soundIdMeta = const VerificationMeta(
    'soundId',
  );
  @override
  late final GeneratedColumn<int> soundId = GeneratedColumn<int>(
    'sound_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sounds (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _loadBoardIdMeta = const VerificationMeta(
    'loadBoardId',
  );
  @override
  late final GeneratedColumn<int> loadBoardId = GeneratedColumn<int>(
    'load_board_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
    boardId,
    label,
    vocalization,
    displayText,
    hidden,
    isSystem,
    userEdited,
    backgroundColor,
    borderColor,
    imageId,
    soundId,
    loadBoardId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'buttons';
  @override
  VerificationContext validateIntegrity(
    Insertable<Button> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('board_id')) {
      context.handle(
        _boardIdMeta,
        boardId.isAcceptableOrUnknown(data['board_id']!, _boardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_boardIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('vocalization')) {
      context.handle(
        _vocalizationMeta,
        vocalization.isAcceptableOrUnknown(
          data['vocalization']!,
          _vocalizationMeta,
        ),
      );
    }
    if (data.containsKey('display_text')) {
      context.handle(
        _displayTextMeta,
        displayText.isAcceptableOrUnknown(
          data['display_text']!,
          _displayTextMeta,
        ),
      );
    }
    if (data.containsKey('hidden')) {
      context.handle(
        _hiddenMeta,
        hidden.isAcceptableOrUnknown(data['hidden']!, _hiddenMeta),
      );
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    if (data.containsKey('user_edited')) {
      context.handle(
        _userEditedMeta,
        userEdited.isAcceptableOrUnknown(data['user_edited']!, _userEditedMeta),
      );
    }
    if (data.containsKey('background_color')) {
      context.handle(
        _backgroundColorMeta,
        backgroundColor.isAcceptableOrUnknown(
          data['background_color']!,
          _backgroundColorMeta,
        ),
      );
    }
    if (data.containsKey('border_color')) {
      context.handle(
        _borderColorMeta,
        borderColor.isAcceptableOrUnknown(
          data['border_color']!,
          _borderColorMeta,
        ),
      );
    }
    if (data.containsKey('image_id')) {
      context.handle(
        _imageIdMeta,
        imageId.isAcceptableOrUnknown(data['image_id']!, _imageIdMeta),
      );
    }
    if (data.containsKey('sound_id')) {
      context.handle(
        _soundIdMeta,
        soundId.isAcceptableOrUnknown(data['sound_id']!, _soundIdMeta),
      );
    }
    if (data.containsKey('load_board_id')) {
      context.handle(
        _loadBoardIdMeta,
        loadBoardId.isAcceptableOrUnknown(
          data['load_board_id']!,
          _loadBoardIdMeta,
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
  Button map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Button(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      boardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}board_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      vocalization: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vocalization'],
      ),
      displayText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_text'],
      ),
      hidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hidden'],
      )!,
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
      userEdited: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}user_edited'],
      )!,
      backgroundColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}background_color'],
      ),
      borderColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}border_color'],
      ),
      imageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}image_id'],
      ),
      soundId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sound_id'],
      ),
      loadBoardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}load_board_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ButtonsTable createAlias(String alias) {
    return $ButtonsTable(attachedDatabase, alias);
  }
}

class Button extends DataClass implements Insertable<Button> {
  final int id;
  final int boardId;

  /// What the tile SHOWS. Capped at 16 characters — the editor refuses at the
  /// cap and never silently truncates, because an ellipsis on an AAC utterance
  /// is a *different utterance*. The cap is safe only because the tile is a
  /// handle for the phrase, not the phrase.
  final String label;

  /// What is SPOKEN. Uncapped. NULL falls back to [label].
  ///
  /// The tile shows "Overwhelmed"; it speaks "I need to leave, I'm not able to
  /// talk right now". Nothing in the type system distinguishes three Strings,
  /// so getting these backwards means a screen-reader user hears a paragraph on
  /// every scan step, or a stranger hears the wrong sentence.
  final String? vocalization;

  /// What show-text mode RENDERS. NULL falls back to `vocalization ?? label`.
  final String? displayText;

  /// Hide, never delete. Removing content is not a reason to destroy it.
  final bool hidden;

  /// The repair phrase. Undeletable. There is no STOP tile — the lit tile is
  /// the stop control, and repair is a phrase the user says, not a button the
  /// app supplies.
  final bool isSystem;

  /// Set to true the moment the user touches a tile. A HARD STOP: never
  /// overwrite, "upgrade", or reconcile a tile the user has touched — not in a
  /// migration, not in a seed step, not in a default-set update. User data is
  /// unmergeable ground truth.
  final bool userEdited;
  final String? backgroundColor;
  final String? borderColor;
  final int? imageId;
  final int? soundId;

  /// One level only. Never a tree.
  final int? loadBoardId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Button({
    required this.id,
    required this.boardId,
    required this.label,
    this.vocalization,
    this.displayText,
    required this.hidden,
    required this.isSystem,
    required this.userEdited,
    this.backgroundColor,
    this.borderColor,
    this.imageId,
    this.soundId,
    this.loadBoardId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['board_id'] = Variable<int>(boardId);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || vocalization != null) {
      map['vocalization'] = Variable<String>(vocalization);
    }
    if (!nullToAbsent || displayText != null) {
      map['display_text'] = Variable<String>(displayText);
    }
    map['hidden'] = Variable<bool>(hidden);
    map['is_system'] = Variable<bool>(isSystem);
    map['user_edited'] = Variable<bool>(userEdited);
    if (!nullToAbsent || backgroundColor != null) {
      map['background_color'] = Variable<String>(backgroundColor);
    }
    if (!nullToAbsent || borderColor != null) {
      map['border_color'] = Variable<String>(borderColor);
    }
    if (!nullToAbsent || imageId != null) {
      map['image_id'] = Variable<int>(imageId);
    }
    if (!nullToAbsent || soundId != null) {
      map['sound_id'] = Variable<int>(soundId);
    }
    if (!nullToAbsent || loadBoardId != null) {
      map['load_board_id'] = Variable<int>(loadBoardId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ButtonsCompanion toCompanion(bool nullToAbsent) {
    return ButtonsCompanion(
      id: Value(id),
      boardId: Value(boardId),
      label: Value(label),
      vocalization: vocalization == null && nullToAbsent
          ? const Value.absent()
          : Value(vocalization),
      displayText: displayText == null && nullToAbsent
          ? const Value.absent()
          : Value(displayText),
      hidden: Value(hidden),
      isSystem: Value(isSystem),
      userEdited: Value(userEdited),
      backgroundColor: backgroundColor == null && nullToAbsent
          ? const Value.absent()
          : Value(backgroundColor),
      borderColor: borderColor == null && nullToAbsent
          ? const Value.absent()
          : Value(borderColor),
      imageId: imageId == null && nullToAbsent
          ? const Value.absent()
          : Value(imageId),
      soundId: soundId == null && nullToAbsent
          ? const Value.absent()
          : Value(soundId),
      loadBoardId: loadBoardId == null && nullToAbsent
          ? const Value.absent()
          : Value(loadBoardId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Button.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Button(
      id: serializer.fromJson<int>(json['id']),
      boardId: serializer.fromJson<int>(json['boardId']),
      label: serializer.fromJson<String>(json['label']),
      vocalization: serializer.fromJson<String?>(json['vocalization']),
      displayText: serializer.fromJson<String?>(json['displayText']),
      hidden: serializer.fromJson<bool>(json['hidden']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      userEdited: serializer.fromJson<bool>(json['userEdited']),
      backgroundColor: serializer.fromJson<String?>(json['backgroundColor']),
      borderColor: serializer.fromJson<String?>(json['borderColor']),
      imageId: serializer.fromJson<int?>(json['imageId']),
      soundId: serializer.fromJson<int?>(json['soundId']),
      loadBoardId: serializer.fromJson<int?>(json['loadBoardId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'boardId': serializer.toJson<int>(boardId),
      'label': serializer.toJson<String>(label),
      'vocalization': serializer.toJson<String?>(vocalization),
      'displayText': serializer.toJson<String?>(displayText),
      'hidden': serializer.toJson<bool>(hidden),
      'isSystem': serializer.toJson<bool>(isSystem),
      'userEdited': serializer.toJson<bool>(userEdited),
      'backgroundColor': serializer.toJson<String?>(backgroundColor),
      'borderColor': serializer.toJson<String?>(borderColor),
      'imageId': serializer.toJson<int?>(imageId),
      'soundId': serializer.toJson<int?>(soundId),
      'loadBoardId': serializer.toJson<int?>(loadBoardId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Button copyWith({
    int? id,
    int? boardId,
    String? label,
    Value<String?> vocalization = const Value.absent(),
    Value<String?> displayText = const Value.absent(),
    bool? hidden,
    bool? isSystem,
    bool? userEdited,
    Value<String?> backgroundColor = const Value.absent(),
    Value<String?> borderColor = const Value.absent(),
    Value<int?> imageId = const Value.absent(),
    Value<int?> soundId = const Value.absent(),
    Value<int?> loadBoardId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Button(
    id: id ?? this.id,
    boardId: boardId ?? this.boardId,
    label: label ?? this.label,
    vocalization: vocalization.present ? vocalization.value : this.vocalization,
    displayText: displayText.present ? displayText.value : this.displayText,
    hidden: hidden ?? this.hidden,
    isSystem: isSystem ?? this.isSystem,
    userEdited: userEdited ?? this.userEdited,
    backgroundColor: backgroundColor.present
        ? backgroundColor.value
        : this.backgroundColor,
    borderColor: borderColor.present ? borderColor.value : this.borderColor,
    imageId: imageId.present ? imageId.value : this.imageId,
    soundId: soundId.present ? soundId.value : this.soundId,
    loadBoardId: loadBoardId.present ? loadBoardId.value : this.loadBoardId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Button copyWithCompanion(ButtonsCompanion data) {
    return Button(
      id: data.id.present ? data.id.value : this.id,
      boardId: data.boardId.present ? data.boardId.value : this.boardId,
      label: data.label.present ? data.label.value : this.label,
      vocalization: data.vocalization.present
          ? data.vocalization.value
          : this.vocalization,
      displayText: data.displayText.present
          ? data.displayText.value
          : this.displayText,
      hidden: data.hidden.present ? data.hidden.value : this.hidden,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      userEdited: data.userEdited.present
          ? data.userEdited.value
          : this.userEdited,
      backgroundColor: data.backgroundColor.present
          ? data.backgroundColor.value
          : this.backgroundColor,
      borderColor: data.borderColor.present
          ? data.borderColor.value
          : this.borderColor,
      imageId: data.imageId.present ? data.imageId.value : this.imageId,
      soundId: data.soundId.present ? data.soundId.value : this.soundId,
      loadBoardId: data.loadBoardId.present
          ? data.loadBoardId.value
          : this.loadBoardId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Button(')
          ..write('id: $id, ')
          ..write('boardId: $boardId, ')
          ..write('label: $label, ')
          ..write('vocalization: $vocalization, ')
          ..write('displayText: $displayText, ')
          ..write('hidden: $hidden, ')
          ..write('isSystem: $isSystem, ')
          ..write('userEdited: $userEdited, ')
          ..write('backgroundColor: $backgroundColor, ')
          ..write('borderColor: $borderColor, ')
          ..write('imageId: $imageId, ')
          ..write('soundId: $soundId, ')
          ..write('loadBoardId: $loadBoardId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    boardId,
    label,
    vocalization,
    displayText,
    hidden,
    isSystem,
    userEdited,
    backgroundColor,
    borderColor,
    imageId,
    soundId,
    loadBoardId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Button &&
          other.id == this.id &&
          other.boardId == this.boardId &&
          other.label == this.label &&
          other.vocalization == this.vocalization &&
          other.displayText == this.displayText &&
          other.hidden == this.hidden &&
          other.isSystem == this.isSystem &&
          other.userEdited == this.userEdited &&
          other.backgroundColor == this.backgroundColor &&
          other.borderColor == this.borderColor &&
          other.imageId == this.imageId &&
          other.soundId == this.soundId &&
          other.loadBoardId == this.loadBoardId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ButtonsCompanion extends UpdateCompanion<Button> {
  final Value<int> id;
  final Value<int> boardId;
  final Value<String> label;
  final Value<String?> vocalization;
  final Value<String?> displayText;
  final Value<bool> hidden;
  final Value<bool> isSystem;
  final Value<bool> userEdited;
  final Value<String?> backgroundColor;
  final Value<String?> borderColor;
  final Value<int?> imageId;
  final Value<int?> soundId;
  final Value<int?> loadBoardId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ButtonsCompanion({
    this.id = const Value.absent(),
    this.boardId = const Value.absent(),
    this.label = const Value.absent(),
    this.vocalization = const Value.absent(),
    this.displayText = const Value.absent(),
    this.hidden = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.userEdited = const Value.absent(),
    this.backgroundColor = const Value.absent(),
    this.borderColor = const Value.absent(),
    this.imageId = const Value.absent(),
    this.soundId = const Value.absent(),
    this.loadBoardId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ButtonsCompanion.insert({
    this.id = const Value.absent(),
    required int boardId,
    required String label,
    this.vocalization = const Value.absent(),
    this.displayText = const Value.absent(),
    this.hidden = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.userEdited = const Value.absent(),
    this.backgroundColor = const Value.absent(),
    this.borderColor = const Value.absent(),
    this.imageId = const Value.absent(),
    this.soundId = const Value.absent(),
    this.loadBoardId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : boardId = Value(boardId),
       label = Value(label);
  static Insertable<Button> custom({
    Expression<int>? id,
    Expression<int>? boardId,
    Expression<String>? label,
    Expression<String>? vocalization,
    Expression<String>? displayText,
    Expression<bool>? hidden,
    Expression<bool>? isSystem,
    Expression<bool>? userEdited,
    Expression<String>? backgroundColor,
    Expression<String>? borderColor,
    Expression<int>? imageId,
    Expression<int>? soundId,
    Expression<int>? loadBoardId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (boardId != null) 'board_id': boardId,
      if (label != null) 'label': label,
      if (vocalization != null) 'vocalization': vocalization,
      if (displayText != null) 'display_text': displayText,
      if (hidden != null) 'hidden': hidden,
      if (isSystem != null) 'is_system': isSystem,
      if (userEdited != null) 'user_edited': userEdited,
      if (backgroundColor != null) 'background_color': backgroundColor,
      if (borderColor != null) 'border_color': borderColor,
      if (imageId != null) 'image_id': imageId,
      if (soundId != null) 'sound_id': soundId,
      if (loadBoardId != null) 'load_board_id': loadBoardId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ButtonsCompanion copyWith({
    Value<int>? id,
    Value<int>? boardId,
    Value<String>? label,
    Value<String?>? vocalization,
    Value<String?>? displayText,
    Value<bool>? hidden,
    Value<bool>? isSystem,
    Value<bool>? userEdited,
    Value<String?>? backgroundColor,
    Value<String?>? borderColor,
    Value<int?>? imageId,
    Value<int?>? soundId,
    Value<int?>? loadBoardId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ButtonsCompanion(
      id: id ?? this.id,
      boardId: boardId ?? this.boardId,
      label: label ?? this.label,
      vocalization: vocalization ?? this.vocalization,
      displayText: displayText ?? this.displayText,
      hidden: hidden ?? this.hidden,
      isSystem: isSystem ?? this.isSystem,
      userEdited: userEdited ?? this.userEdited,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      imageId: imageId ?? this.imageId,
      soundId: soundId ?? this.soundId,
      loadBoardId: loadBoardId ?? this.loadBoardId,
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
    if (boardId.present) {
      map['board_id'] = Variable<int>(boardId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (vocalization.present) {
      map['vocalization'] = Variable<String>(vocalization.value);
    }
    if (displayText.present) {
      map['display_text'] = Variable<String>(displayText.value);
    }
    if (hidden.present) {
      map['hidden'] = Variable<bool>(hidden.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (userEdited.present) {
      map['user_edited'] = Variable<bool>(userEdited.value);
    }
    if (backgroundColor.present) {
      map['background_color'] = Variable<String>(backgroundColor.value);
    }
    if (borderColor.present) {
      map['border_color'] = Variable<String>(borderColor.value);
    }
    if (imageId.present) {
      map['image_id'] = Variable<int>(imageId.value);
    }
    if (soundId.present) {
      map['sound_id'] = Variable<int>(soundId.value);
    }
    if (loadBoardId.present) {
      map['load_board_id'] = Variable<int>(loadBoardId.value);
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
    return (StringBuffer('ButtonsCompanion(')
          ..write('id: $id, ')
          ..write('boardId: $boardId, ')
          ..write('label: $label, ')
          ..write('vocalization: $vocalization, ')
          ..write('displayText: $displayText, ')
          ..write('hidden: $hidden, ')
          ..write('isSystem: $isSystem, ')
          ..write('userEdited: $userEdited, ')
          ..write('backgroundColor: $backgroundColor, ')
          ..write('borderColor: $borderColor, ')
          ..write('imageId: $imageId, ')
          ..write('soundId: $soundId, ')
          ..write('loadBoardId: $loadBoardId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $GridSlotsTable extends GridSlots
    with TableInfo<$GridSlotsTable, GridSlot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GridSlotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _boardIdMeta = const VerificationMeta(
    'boardId',
  );
  @override
  late final GeneratedColumn<int> boardId = GeneratedColumn<int>(
    'board_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES boards (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _rowIndexMeta = const VerificationMeta(
    'rowIndex',
  );
  @override
  late final GeneratedColumn<int> rowIndex = GeneratedColumn<int>(
    'row_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colIndexMeta = const VerificationMeta(
    'colIndex',
  );
  @override
  late final GeneratedColumn<int> colIndex = GeneratedColumn<int>(
    'col_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _buttonIdMeta = const VerificationMeta(
    'buttonId',
  );
  @override
  late final GeneratedColumn<int> buttonId = GeneratedColumn<int>(
    'button_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES buttons (id) ON DELETE SET NULL',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [boardId, rowIndex, colIndex, buttonId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grid_slots';
  @override
  VerificationContext validateIntegrity(
    Insertable<GridSlot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('board_id')) {
      context.handle(
        _boardIdMeta,
        boardId.isAcceptableOrUnknown(data['board_id']!, _boardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_boardIdMeta);
    }
    if (data.containsKey('row_index')) {
      context.handle(
        _rowIndexMeta,
        rowIndex.isAcceptableOrUnknown(data['row_index']!, _rowIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_rowIndexMeta);
    }
    if (data.containsKey('col_index')) {
      context.handle(
        _colIndexMeta,
        colIndex.isAcceptableOrUnknown(data['col_index']!, _colIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_colIndexMeta);
    }
    if (data.containsKey('button_id')) {
      context.handle(
        _buttonIdMeta,
        buttonId.isAcceptableOrUnknown(data['button_id']!, _buttonIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {boardId, rowIndex, colIndex};
  @override
  GridSlot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GridSlot(
      boardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}board_id'],
      )!,
      rowIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_index'],
      )!,
      colIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}col_index'],
      )!,
      buttonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}button_id'],
      ),
    );
  }

  @override
  $GridSlotsTable createAlias(String alias) {
    return $GridSlotsTable(attachedDatabase, alias);
  }
}

class GridSlot extends DataClass implements Insertable<GridSlot> {
  final int boardId;
  final int rowIndex;
  final int colIndex;
  final int? buttonId;
  const GridSlot({
    required this.boardId,
    required this.rowIndex,
    required this.colIndex,
    this.buttonId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['board_id'] = Variable<int>(boardId);
    map['row_index'] = Variable<int>(rowIndex);
    map['col_index'] = Variable<int>(colIndex);
    if (!nullToAbsent || buttonId != null) {
      map['button_id'] = Variable<int>(buttonId);
    }
    return map;
  }

  GridSlotsCompanion toCompanion(bool nullToAbsent) {
    return GridSlotsCompanion(
      boardId: Value(boardId),
      rowIndex: Value(rowIndex),
      colIndex: Value(colIndex),
      buttonId: buttonId == null && nullToAbsent
          ? const Value.absent()
          : Value(buttonId),
    );
  }

  factory GridSlot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GridSlot(
      boardId: serializer.fromJson<int>(json['boardId']),
      rowIndex: serializer.fromJson<int>(json['rowIndex']),
      colIndex: serializer.fromJson<int>(json['colIndex']),
      buttonId: serializer.fromJson<int?>(json['buttonId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'boardId': serializer.toJson<int>(boardId),
      'rowIndex': serializer.toJson<int>(rowIndex),
      'colIndex': serializer.toJson<int>(colIndex),
      'buttonId': serializer.toJson<int?>(buttonId),
    };
  }

  GridSlot copyWith({
    int? boardId,
    int? rowIndex,
    int? colIndex,
    Value<int?> buttonId = const Value.absent(),
  }) => GridSlot(
    boardId: boardId ?? this.boardId,
    rowIndex: rowIndex ?? this.rowIndex,
    colIndex: colIndex ?? this.colIndex,
    buttonId: buttonId.present ? buttonId.value : this.buttonId,
  );
  GridSlot copyWithCompanion(GridSlotsCompanion data) {
    return GridSlot(
      boardId: data.boardId.present ? data.boardId.value : this.boardId,
      rowIndex: data.rowIndex.present ? data.rowIndex.value : this.rowIndex,
      colIndex: data.colIndex.present ? data.colIndex.value : this.colIndex,
      buttonId: data.buttonId.present ? data.buttonId.value : this.buttonId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GridSlot(')
          ..write('boardId: $boardId, ')
          ..write('rowIndex: $rowIndex, ')
          ..write('colIndex: $colIndex, ')
          ..write('buttonId: $buttonId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(boardId, rowIndex, colIndex, buttonId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GridSlot &&
          other.boardId == this.boardId &&
          other.rowIndex == this.rowIndex &&
          other.colIndex == this.colIndex &&
          other.buttonId == this.buttonId);
}

class GridSlotsCompanion extends UpdateCompanion<GridSlot> {
  final Value<int> boardId;
  final Value<int> rowIndex;
  final Value<int> colIndex;
  final Value<int?> buttonId;
  final Value<int> rowid;
  const GridSlotsCompanion({
    this.boardId = const Value.absent(),
    this.rowIndex = const Value.absent(),
    this.colIndex = const Value.absent(),
    this.buttonId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GridSlotsCompanion.insert({
    required int boardId,
    required int rowIndex,
    required int colIndex,
    this.buttonId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : boardId = Value(boardId),
       rowIndex = Value(rowIndex),
       colIndex = Value(colIndex);
  static Insertable<GridSlot> custom({
    Expression<int>? boardId,
    Expression<int>? rowIndex,
    Expression<int>? colIndex,
    Expression<int>? buttonId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (boardId != null) 'board_id': boardId,
      if (rowIndex != null) 'row_index': rowIndex,
      if (colIndex != null) 'col_index': colIndex,
      if (buttonId != null) 'button_id': buttonId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GridSlotsCompanion copyWith({
    Value<int>? boardId,
    Value<int>? rowIndex,
    Value<int>? colIndex,
    Value<int?>? buttonId,
    Value<int>? rowid,
  }) {
    return GridSlotsCompanion(
      boardId: boardId ?? this.boardId,
      rowIndex: rowIndex ?? this.rowIndex,
      colIndex: colIndex ?? this.colIndex,
      buttonId: buttonId ?? this.buttonId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (boardId.present) {
      map['board_id'] = Variable<int>(boardId.value);
    }
    if (rowIndex.present) {
      map['row_index'] = Variable<int>(rowIndex.value);
    }
    if (colIndex.present) {
      map['col_index'] = Variable<int>(colIndex.value);
    }
    if (buttonId.present) {
      map['button_id'] = Variable<int>(buttonId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GridSlotsCompanion(')
          ..write('boardId: $boardId, ')
          ..write('rowIndex: $rowIndex, ')
          ..write('colIndex: $colIndex, ')
          ..write('buttonId: $buttonId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BoardsTable boards = $BoardsTable(this);
  late final $ImagesTable images = $ImagesTable(this);
  late final $SoundsTable sounds = $SoundsTable(this);
  late final $ButtonsTable buttons = $ButtonsTable(this);
  late final $GridSlotsTable gridSlots = $GridSlotsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    boards,
    images,
    sounds,
    buttons,
    gridSlots,
    settings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'boards',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('buttons', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'images',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('buttons', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sounds',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('buttons', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'boards',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('grid_slots', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'buttons',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('grid_slots', kind: UpdateKind.update)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$BoardsTableCreateCompanionBuilder =
    BoardsCompanion Function({
      Value<int> id,
      required String name,
      Value<String> locale,
      required int gridRows,
      required int gridCols,
      Value<bool> isRoot,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$BoardsTableUpdateCompanionBuilder =
    BoardsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> locale,
      Value<int> gridRows,
      Value<int> gridCols,
      Value<bool> isRoot,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$BoardsTableReferences
    extends BaseReferences<_$AppDatabase, $BoardsTable, Board> {
  $$BoardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ButtonsTable, List<Button>> _buttonsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.buttons,
    aliasName: 'boards__id__buttons__board_id',
  );

  $$ButtonsTableProcessedTableManager get buttonsRefs {
    final manager = $$ButtonsTableTableManager(
      $_db,
      $_db.buttons,
    ).filter((f) => f.boardId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_buttonsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GridSlotsTable, List<GridSlot>>
  _gridSlotsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.gridSlots,
    aliasName: 'boards__id__grid_slots__board_id',
  );

  $$GridSlotsTableProcessedTableManager get gridSlotsRefs {
    final manager = $$GridSlotsTableTableManager(
      $_db,
      $_db.gridSlots,
    ).filter((f) => f.boardId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gridSlotsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BoardsTableFilterComposer
    extends Composer<_$AppDatabase, $BoardsTable> {
  $$BoardsTableFilterComposer({
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

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gridRows => $composableBuilder(
    column: $table.gridRows,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gridCols => $composableBuilder(
    column: $table.gridCols,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRoot => $composableBuilder(
    column: $table.isRoot,
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

  Expression<bool> buttonsRefs(
    Expression<bool> Function($$ButtonsTableFilterComposer f) f,
  ) {
    final $$ButtonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.buttons,
      getReferencedColumn: (t) => t.boardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ButtonsTableFilterComposer(
            $db: $db,
            $table: $db.buttons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> gridSlotsRefs(
    Expression<bool> Function($$GridSlotsTableFilterComposer f) f,
  ) {
    final $$GridSlotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gridSlots,
      getReferencedColumn: (t) => t.boardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GridSlotsTableFilterComposer(
            $db: $db,
            $table: $db.gridSlots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BoardsTableOrderingComposer
    extends Composer<_$AppDatabase, $BoardsTable> {
  $$BoardsTableOrderingComposer({
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

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gridRows => $composableBuilder(
    column: $table.gridRows,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gridCols => $composableBuilder(
    column: $table.gridCols,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRoot => $composableBuilder(
    column: $table.isRoot,
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
}

class $$BoardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BoardsTable> {
  $$BoardsTableAnnotationComposer({
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

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<int> get gridRows =>
      $composableBuilder(column: $table.gridRows, builder: (column) => column);

  GeneratedColumn<int> get gridCols =>
      $composableBuilder(column: $table.gridCols, builder: (column) => column);

  GeneratedColumn<bool> get isRoot =>
      $composableBuilder(column: $table.isRoot, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> buttonsRefs<T extends Object>(
    Expression<T> Function($$ButtonsTableAnnotationComposer a) f,
  ) {
    final $$ButtonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.buttons,
      getReferencedColumn: (t) => t.boardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ButtonsTableAnnotationComposer(
            $db: $db,
            $table: $db.buttons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> gridSlotsRefs<T extends Object>(
    Expression<T> Function($$GridSlotsTableAnnotationComposer a) f,
  ) {
    final $$GridSlotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gridSlots,
      getReferencedColumn: (t) => t.boardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GridSlotsTableAnnotationComposer(
            $db: $db,
            $table: $db.gridSlots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BoardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BoardsTable,
          Board,
          $$BoardsTableFilterComposer,
          $$BoardsTableOrderingComposer,
          $$BoardsTableAnnotationComposer,
          $$BoardsTableCreateCompanionBuilder,
          $$BoardsTableUpdateCompanionBuilder,
          (Board, $$BoardsTableReferences),
          Board,
          PrefetchHooks Function({bool buttonsRefs, bool gridSlotsRefs})
        > {
  $$BoardsTableTableManager(_$AppDatabase db, $BoardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BoardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BoardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BoardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<int> gridRows = const Value.absent(),
                Value<int> gridCols = const Value.absent(),
                Value<bool> isRoot = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => BoardsCompanion(
                id: id,
                name: name,
                locale: locale,
                gridRows: gridRows,
                gridCols: gridCols,
                isRoot: isRoot,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> locale = const Value.absent(),
                required int gridRows,
                required int gridCols,
                Value<bool> isRoot = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => BoardsCompanion.insert(
                id: id,
                name: name,
                locale: locale,
                gridRows: gridRows,
                gridCols: gridCols,
                isRoot: isRoot,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$BoardsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({buttonsRefs = false, gridSlotsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (buttonsRefs) db.buttons,
                    if (gridSlotsRefs) db.gridSlots,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (buttonsRefs)
                        await $_getPrefetchedData<Board, $BoardsTable, Button>(
                          currentTable: table,
                          referencedTable: $$BoardsTableReferences
                              ._buttonsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BoardsTableReferences(
                                db,
                                table,
                                p0,
                              ).buttonsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.boardId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (gridSlotsRefs)
                        await $_getPrefetchedData<
                          Board,
                          $BoardsTable,
                          GridSlot
                        >(
                          currentTable: table,
                          referencedTable: $$BoardsTableReferences
                              ._gridSlotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BoardsTableReferences(
                                db,
                                table,
                                p0,
                              ).gridSlotsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.boardId == item.id,
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

typedef $$BoardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BoardsTable,
      Board,
      $$BoardsTableFilterComposer,
      $$BoardsTableOrderingComposer,
      $$BoardsTableAnnotationComposer,
      $$BoardsTableCreateCompanionBuilder,
      $$BoardsTableUpdateCompanionBuilder,
      (Board, $$BoardsTableReferences),
      Board,
      PrefetchHooks Function({bool buttonsRefs, bool gridSlotsRefs})
    >;
typedef $$ImagesTableCreateCompanionBuilder =
    ImagesCompanion Function({
      Value<int> id,
      required String path,
      required String contentType,
      required int width,
      required int height,
      Value<String?> license,
      Value<String?> attribution,
    });
typedef $$ImagesTableUpdateCompanionBuilder =
    ImagesCompanion Function({
      Value<int> id,
      Value<String> path,
      Value<String> contentType,
      Value<int> width,
      Value<int> height,
      Value<String?> license,
      Value<String?> attribution,
    });

final class $$ImagesTableReferences
    extends BaseReferences<_$AppDatabase, $ImagesTable, MediaImage> {
  $$ImagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ButtonsTable, List<Button>> _buttonsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.buttons,
    aliasName: 'images__id__buttons__image_id',
  );

  $$ButtonsTableProcessedTableManager get buttonsRefs {
    final manager = $$ButtonsTableTableManager(
      $_db,
      $_db.buttons,
    ).filter((f) => f.imageId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_buttonsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ImagesTableFilterComposer
    extends Composer<_$AppDatabase, $ImagesTable> {
  $$ImagesTableFilterComposer({
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

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get license => $composableBuilder(
    column: $table.license,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attribution => $composableBuilder(
    column: $table.attribution,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> buttonsRefs(
    Expression<bool> Function($$ButtonsTableFilterComposer f) f,
  ) {
    final $$ButtonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.buttons,
      getReferencedColumn: (t) => t.imageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ButtonsTableFilterComposer(
            $db: $db,
            $table: $db.buttons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ImagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ImagesTable> {
  $$ImagesTableOrderingComposer({
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

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get license => $composableBuilder(
    column: $table.license,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attribution => $composableBuilder(
    column: $table.attribution,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImagesTable> {
  $$ImagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<String> get license =>
      $composableBuilder(column: $table.license, builder: (column) => column);

  GeneratedColumn<String> get attribution => $composableBuilder(
    column: $table.attribution,
    builder: (column) => column,
  );

  Expression<T> buttonsRefs<T extends Object>(
    Expression<T> Function($$ButtonsTableAnnotationComposer a) f,
  ) {
    final $$ButtonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.buttons,
      getReferencedColumn: (t) => t.imageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ButtonsTableAnnotationComposer(
            $db: $db,
            $table: $db.buttons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ImagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImagesTable,
          MediaImage,
          $$ImagesTableFilterComposer,
          $$ImagesTableOrderingComposer,
          $$ImagesTableAnnotationComposer,
          $$ImagesTableCreateCompanionBuilder,
          $$ImagesTableUpdateCompanionBuilder,
          (MediaImage, $$ImagesTableReferences),
          MediaImage,
          PrefetchHooks Function({bool buttonsRefs})
        > {
  $$ImagesTableTableManager(_$AppDatabase db, $ImagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> contentType = const Value.absent(),
                Value<int> width = const Value.absent(),
                Value<int> height = const Value.absent(),
                Value<String?> license = const Value.absent(),
                Value<String?> attribution = const Value.absent(),
              }) => ImagesCompanion(
                id: id,
                path: path,
                contentType: contentType,
                width: width,
                height: height,
                license: license,
                attribution: attribution,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String path,
                required String contentType,
                required int width,
                required int height,
                Value<String?> license = const Value.absent(),
                Value<String?> attribution = const Value.absent(),
              }) => ImagesCompanion.insert(
                id: id,
                path: path,
                contentType: contentType,
                width: width,
                height: height,
                license: license,
                attribution: attribution,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ImagesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({buttonsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (buttonsRefs) db.buttons],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (buttonsRefs)
                    await $_getPrefetchedData<MediaImage, $ImagesTable, Button>(
                      currentTable: table,
                      referencedTable: $$ImagesTableReferences
                          ._buttonsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ImagesTableReferences(db, table, p0).buttonsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.imageId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ImagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImagesTable,
      MediaImage,
      $$ImagesTableFilterComposer,
      $$ImagesTableOrderingComposer,
      $$ImagesTableAnnotationComposer,
      $$ImagesTableCreateCompanionBuilder,
      $$ImagesTableUpdateCompanionBuilder,
      (MediaImage, $$ImagesTableReferences),
      MediaImage,
      PrefetchHooks Function({bool buttonsRefs})
    >;
typedef $$SoundsTableCreateCompanionBuilder =
    SoundsCompanion Function({
      Value<int> id,
      required String path,
      required String contentType,
      required int durationMs,
    });
typedef $$SoundsTableUpdateCompanionBuilder =
    SoundsCompanion Function({
      Value<int> id,
      Value<String> path,
      Value<String> contentType,
      Value<int> durationMs,
    });

final class $$SoundsTableReferences
    extends BaseReferences<_$AppDatabase, $SoundsTable, MediaSound> {
  $$SoundsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ButtonsTable, List<Button>> _buttonsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.buttons,
    aliasName: 'sounds__id__buttons__sound_id',
  );

  $$ButtonsTableProcessedTableManager get buttonsRefs {
    final manager = $$ButtonsTableTableManager(
      $_db,
      $_db.buttons,
    ).filter((f) => f.soundId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_buttonsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SoundsTableFilterComposer
    extends Composer<_$AppDatabase, $SoundsTable> {
  $$SoundsTableFilterComposer({
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

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> buttonsRefs(
    Expression<bool> Function($$ButtonsTableFilterComposer f) f,
  ) {
    final $$ButtonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.buttons,
      getReferencedColumn: (t) => t.soundId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ButtonsTableFilterComposer(
            $db: $db,
            $table: $db.buttons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SoundsTableOrderingComposer
    extends Composer<_$AppDatabase, $SoundsTable> {
  $$SoundsTableOrderingComposer({
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

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SoundsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SoundsTable> {
  $$SoundsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  Expression<T> buttonsRefs<T extends Object>(
    Expression<T> Function($$ButtonsTableAnnotationComposer a) f,
  ) {
    final $$ButtonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.buttons,
      getReferencedColumn: (t) => t.soundId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ButtonsTableAnnotationComposer(
            $db: $db,
            $table: $db.buttons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SoundsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SoundsTable,
          MediaSound,
          $$SoundsTableFilterComposer,
          $$SoundsTableOrderingComposer,
          $$SoundsTableAnnotationComposer,
          $$SoundsTableCreateCompanionBuilder,
          $$SoundsTableUpdateCompanionBuilder,
          (MediaSound, $$SoundsTableReferences),
          MediaSound,
          PrefetchHooks Function({bool buttonsRefs})
        > {
  $$SoundsTableTableManager(_$AppDatabase db, $SoundsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SoundsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SoundsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SoundsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> contentType = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
              }) => SoundsCompanion(
                id: id,
                path: path,
                contentType: contentType,
                durationMs: durationMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String path,
                required String contentType,
                required int durationMs,
              }) => SoundsCompanion.insert(
                id: id,
                path: path,
                contentType: contentType,
                durationMs: durationMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$SoundsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({buttonsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (buttonsRefs) db.buttons],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (buttonsRefs)
                    await $_getPrefetchedData<MediaSound, $SoundsTable, Button>(
                      currentTable: table,
                      referencedTable: $$SoundsTableReferences
                          ._buttonsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SoundsTableReferences(db, table, p0).buttonsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.soundId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SoundsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SoundsTable,
      MediaSound,
      $$SoundsTableFilterComposer,
      $$SoundsTableOrderingComposer,
      $$SoundsTableAnnotationComposer,
      $$SoundsTableCreateCompanionBuilder,
      $$SoundsTableUpdateCompanionBuilder,
      (MediaSound, $$SoundsTableReferences),
      MediaSound,
      PrefetchHooks Function({bool buttonsRefs})
    >;
typedef $$ButtonsTableCreateCompanionBuilder =
    ButtonsCompanion Function({
      Value<int> id,
      required int boardId,
      required String label,
      Value<String?> vocalization,
      Value<String?> displayText,
      Value<bool> hidden,
      Value<bool> isSystem,
      Value<bool> userEdited,
      Value<String?> backgroundColor,
      Value<String?> borderColor,
      Value<int?> imageId,
      Value<int?> soundId,
      Value<int?> loadBoardId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$ButtonsTableUpdateCompanionBuilder =
    ButtonsCompanion Function({
      Value<int> id,
      Value<int> boardId,
      Value<String> label,
      Value<String?> vocalization,
      Value<String?> displayText,
      Value<bool> hidden,
      Value<bool> isSystem,
      Value<bool> userEdited,
      Value<String?> backgroundColor,
      Value<String?> borderColor,
      Value<int?> imageId,
      Value<int?> soundId,
      Value<int?> loadBoardId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$ButtonsTableReferences
    extends BaseReferences<_$AppDatabase, $ButtonsTable, Button> {
  $$ButtonsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BoardsTable _boardIdTable(_$AppDatabase db) =>
      db.boards.createAlias('buttons__board_id__boards__id');

  $$BoardsTableProcessedTableManager get boardId {
    final $_column = $_itemColumn<int>('board_id')!;

    final manager = $$BoardsTableTableManager(
      $_db,
      $_db.boards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_boardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ImagesTable _imageIdTable(_$AppDatabase db) =>
      db.images.createAlias('buttons__image_id__images__id');

  $$ImagesTableProcessedTableManager? get imageId {
    final $_column = $_itemColumn<int>('image_id');
    if ($_column == null) return null;
    final manager = $$ImagesTableTableManager(
      $_db,
      $_db.images,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_imageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SoundsTable _soundIdTable(_$AppDatabase db) =>
      db.sounds.createAlias('buttons__sound_id__sounds__id');

  $$SoundsTableProcessedTableManager? get soundId {
    final $_column = $_itemColumn<int>('sound_id');
    if ($_column == null) return null;
    final manager = $$SoundsTableTableManager(
      $_db,
      $_db.sounds,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_soundIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$GridSlotsTable, List<GridSlot>>
  _gridSlotsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.gridSlots,
    aliasName: 'buttons__id__grid_slots__button_id',
  );

  $$GridSlotsTableProcessedTableManager get gridSlotsRefs {
    final manager = $$GridSlotsTableTableManager(
      $_db,
      $_db.gridSlots,
    ).filter((f) => f.buttonId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gridSlotsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ButtonsTableFilterComposer
    extends Composer<_$AppDatabase, $ButtonsTable> {
  $$ButtonsTableFilterComposer({
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

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vocalization => $composableBuilder(
    column: $table.vocalization,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayText => $composableBuilder(
    column: $table.displayText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get userEdited => $composableBuilder(
    column: $table.userEdited,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backgroundColor => $composableBuilder(
    column: $table.backgroundColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get borderColor => $composableBuilder(
    column: $table.borderColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get loadBoardId => $composableBuilder(
    column: $table.loadBoardId,
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

  $$BoardsTableFilterComposer get boardId {
    final $$BoardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.boardId,
      referencedTable: $db.boards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BoardsTableFilterComposer(
            $db: $db,
            $table: $db.boards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImagesTableFilterComposer get imageId {
    final $$ImagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.imageId,
      referencedTable: $db.images,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImagesTableFilterComposer(
            $db: $db,
            $table: $db.images,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SoundsTableFilterComposer get soundId {
    final $$SoundsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.soundId,
      referencedTable: $db.sounds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SoundsTableFilterComposer(
            $db: $db,
            $table: $db.sounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> gridSlotsRefs(
    Expression<bool> Function($$GridSlotsTableFilterComposer f) f,
  ) {
    final $$GridSlotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gridSlots,
      getReferencedColumn: (t) => t.buttonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GridSlotsTableFilterComposer(
            $db: $db,
            $table: $db.gridSlots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ButtonsTableOrderingComposer
    extends Composer<_$AppDatabase, $ButtonsTable> {
  $$ButtonsTableOrderingComposer({
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

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vocalization => $composableBuilder(
    column: $table.vocalization,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayText => $composableBuilder(
    column: $table.displayText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get userEdited => $composableBuilder(
    column: $table.userEdited,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backgroundColor => $composableBuilder(
    column: $table.backgroundColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get borderColor => $composableBuilder(
    column: $table.borderColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get loadBoardId => $composableBuilder(
    column: $table.loadBoardId,
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

  $$BoardsTableOrderingComposer get boardId {
    final $$BoardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.boardId,
      referencedTable: $db.boards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BoardsTableOrderingComposer(
            $db: $db,
            $table: $db.boards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImagesTableOrderingComposer get imageId {
    final $$ImagesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.imageId,
      referencedTable: $db.images,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImagesTableOrderingComposer(
            $db: $db,
            $table: $db.images,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SoundsTableOrderingComposer get soundId {
    final $$SoundsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.soundId,
      referencedTable: $db.sounds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SoundsTableOrderingComposer(
            $db: $db,
            $table: $db.sounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ButtonsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ButtonsTable> {
  $$ButtonsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get vocalization => $composableBuilder(
    column: $table.vocalization,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayText => $composableBuilder(
    column: $table.displayText,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hidden =>
      $composableBuilder(column: $table.hidden, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<bool> get userEdited => $composableBuilder(
    column: $table.userEdited,
    builder: (column) => column,
  );

  GeneratedColumn<String> get backgroundColor => $composableBuilder(
    column: $table.backgroundColor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get borderColor => $composableBuilder(
    column: $table.borderColor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get loadBoardId => $composableBuilder(
    column: $table.loadBoardId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$BoardsTableAnnotationComposer get boardId {
    final $$BoardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.boardId,
      referencedTable: $db.boards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BoardsTableAnnotationComposer(
            $db: $db,
            $table: $db.boards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImagesTableAnnotationComposer get imageId {
    final $$ImagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.imageId,
      referencedTable: $db.images,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImagesTableAnnotationComposer(
            $db: $db,
            $table: $db.images,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SoundsTableAnnotationComposer get soundId {
    final $$SoundsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.soundId,
      referencedTable: $db.sounds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SoundsTableAnnotationComposer(
            $db: $db,
            $table: $db.sounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> gridSlotsRefs<T extends Object>(
    Expression<T> Function($$GridSlotsTableAnnotationComposer a) f,
  ) {
    final $$GridSlotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gridSlots,
      getReferencedColumn: (t) => t.buttonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GridSlotsTableAnnotationComposer(
            $db: $db,
            $table: $db.gridSlots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ButtonsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ButtonsTable,
          Button,
          $$ButtonsTableFilterComposer,
          $$ButtonsTableOrderingComposer,
          $$ButtonsTableAnnotationComposer,
          $$ButtonsTableCreateCompanionBuilder,
          $$ButtonsTableUpdateCompanionBuilder,
          (Button, $$ButtonsTableReferences),
          Button,
          PrefetchHooks Function({
            bool boardId,
            bool imageId,
            bool soundId,
            bool gridSlotsRefs,
          })
        > {
  $$ButtonsTableTableManager(_$AppDatabase db, $ButtonsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ButtonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ButtonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ButtonsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> boardId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String?> vocalization = const Value.absent(),
                Value<String?> displayText = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<bool> userEdited = const Value.absent(),
                Value<String?> backgroundColor = const Value.absent(),
                Value<String?> borderColor = const Value.absent(),
                Value<int?> imageId = const Value.absent(),
                Value<int?> soundId = const Value.absent(),
                Value<int?> loadBoardId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ButtonsCompanion(
                id: id,
                boardId: boardId,
                label: label,
                vocalization: vocalization,
                displayText: displayText,
                hidden: hidden,
                isSystem: isSystem,
                userEdited: userEdited,
                backgroundColor: backgroundColor,
                borderColor: borderColor,
                imageId: imageId,
                soundId: soundId,
                loadBoardId: loadBoardId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int boardId,
                required String label,
                Value<String?> vocalization = const Value.absent(),
                Value<String?> displayText = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<bool> userEdited = const Value.absent(),
                Value<String?> backgroundColor = const Value.absent(),
                Value<String?> borderColor = const Value.absent(),
                Value<int?> imageId = const Value.absent(),
                Value<int?> soundId = const Value.absent(),
                Value<int?> loadBoardId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ButtonsCompanion.insert(
                id: id,
                boardId: boardId,
                label: label,
                vocalization: vocalization,
                displayText: displayText,
                hidden: hidden,
                isSystem: isSystem,
                userEdited: userEdited,
                backgroundColor: backgroundColor,
                borderColor: borderColor,
                imageId: imageId,
                soundId: soundId,
                loadBoardId: loadBoardId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ButtonsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                boardId = false,
                imageId = false,
                soundId = false,
                gridSlotsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (gridSlotsRefs) db.gridSlots],
                  addJoins:
                      <
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
                        if (boardId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.boardId,
                                    referencedTable: $$ButtonsTableReferences
                                        ._boardIdTable(db),
                                    referencedColumn: $$ButtonsTableReferences
                                        ._boardIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (imageId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.imageId,
                                    referencedTable: $$ButtonsTableReferences
                                        ._imageIdTable(db),
                                    referencedColumn: $$ButtonsTableReferences
                                        ._imageIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (soundId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.soundId,
                                    referencedTable: $$ButtonsTableReferences
                                        ._soundIdTable(db),
                                    referencedColumn: $$ButtonsTableReferences
                                        ._soundIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (gridSlotsRefs)
                        await $_getPrefetchedData<
                          Button,
                          $ButtonsTable,
                          GridSlot
                        >(
                          currentTable: table,
                          referencedTable: $$ButtonsTableReferences
                              ._gridSlotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ButtonsTableReferences(
                                db,
                                table,
                                p0,
                              ).gridSlotsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.buttonId == item.id,
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

typedef $$ButtonsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ButtonsTable,
      Button,
      $$ButtonsTableFilterComposer,
      $$ButtonsTableOrderingComposer,
      $$ButtonsTableAnnotationComposer,
      $$ButtonsTableCreateCompanionBuilder,
      $$ButtonsTableUpdateCompanionBuilder,
      (Button, $$ButtonsTableReferences),
      Button,
      PrefetchHooks Function({
        bool boardId,
        bool imageId,
        bool soundId,
        bool gridSlotsRefs,
      })
    >;
typedef $$GridSlotsTableCreateCompanionBuilder =
    GridSlotsCompanion Function({
      required int boardId,
      required int rowIndex,
      required int colIndex,
      Value<int?> buttonId,
      Value<int> rowid,
    });
typedef $$GridSlotsTableUpdateCompanionBuilder =
    GridSlotsCompanion Function({
      Value<int> boardId,
      Value<int> rowIndex,
      Value<int> colIndex,
      Value<int?> buttonId,
      Value<int> rowid,
    });

final class $$GridSlotsTableReferences
    extends BaseReferences<_$AppDatabase, $GridSlotsTable, GridSlot> {
  $$GridSlotsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BoardsTable _boardIdTable(_$AppDatabase db) =>
      db.boards.createAlias('grid_slots__board_id__boards__id');

  $$BoardsTableProcessedTableManager get boardId {
    final $_column = $_itemColumn<int>('board_id')!;

    final manager = $$BoardsTableTableManager(
      $_db,
      $_db.boards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_boardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ButtonsTable _buttonIdTable(_$AppDatabase db) =>
      db.buttons.createAlias('grid_slots__button_id__buttons__id');

  $$ButtonsTableProcessedTableManager? get buttonId {
    final $_column = $_itemColumn<int>('button_id');
    if ($_column == null) return null;
    final manager = $$ButtonsTableTableManager(
      $_db,
      $_db.buttons,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_buttonIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GridSlotsTableFilterComposer
    extends Composer<_$AppDatabase, $GridSlotsTable> {
  $$GridSlotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rowIndex => $composableBuilder(
    column: $table.rowIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colIndex => $composableBuilder(
    column: $table.colIndex,
    builder: (column) => ColumnFilters(column),
  );

  $$BoardsTableFilterComposer get boardId {
    final $$BoardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.boardId,
      referencedTable: $db.boards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BoardsTableFilterComposer(
            $db: $db,
            $table: $db.boards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ButtonsTableFilterComposer get buttonId {
    final $$ButtonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.buttonId,
      referencedTable: $db.buttons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ButtonsTableFilterComposer(
            $db: $db,
            $table: $db.buttons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GridSlotsTableOrderingComposer
    extends Composer<_$AppDatabase, $GridSlotsTable> {
  $$GridSlotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get rowIndex => $composableBuilder(
    column: $table.rowIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colIndex => $composableBuilder(
    column: $table.colIndex,
    builder: (column) => ColumnOrderings(column),
  );

  $$BoardsTableOrderingComposer get boardId {
    final $$BoardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.boardId,
      referencedTable: $db.boards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BoardsTableOrderingComposer(
            $db: $db,
            $table: $db.boards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ButtonsTableOrderingComposer get buttonId {
    final $$ButtonsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.buttonId,
      referencedTable: $db.buttons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ButtonsTableOrderingComposer(
            $db: $db,
            $table: $db.buttons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GridSlotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GridSlotsTable> {
  $$GridSlotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get rowIndex =>
      $composableBuilder(column: $table.rowIndex, builder: (column) => column);

  GeneratedColumn<int> get colIndex =>
      $composableBuilder(column: $table.colIndex, builder: (column) => column);

  $$BoardsTableAnnotationComposer get boardId {
    final $$BoardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.boardId,
      referencedTable: $db.boards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BoardsTableAnnotationComposer(
            $db: $db,
            $table: $db.boards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ButtonsTableAnnotationComposer get buttonId {
    final $$ButtonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.buttonId,
      referencedTable: $db.buttons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ButtonsTableAnnotationComposer(
            $db: $db,
            $table: $db.buttons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GridSlotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GridSlotsTable,
          GridSlot,
          $$GridSlotsTableFilterComposer,
          $$GridSlotsTableOrderingComposer,
          $$GridSlotsTableAnnotationComposer,
          $$GridSlotsTableCreateCompanionBuilder,
          $$GridSlotsTableUpdateCompanionBuilder,
          (GridSlot, $$GridSlotsTableReferences),
          GridSlot,
          PrefetchHooks Function({bool boardId, bool buttonId})
        > {
  $$GridSlotsTableTableManager(_$AppDatabase db, $GridSlotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GridSlotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GridSlotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GridSlotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> boardId = const Value.absent(),
                Value<int> rowIndex = const Value.absent(),
                Value<int> colIndex = const Value.absent(),
                Value<int?> buttonId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GridSlotsCompanion(
                boardId: boardId,
                rowIndex: rowIndex,
                colIndex: colIndex,
                buttonId: buttonId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int boardId,
                required int rowIndex,
                required int colIndex,
                Value<int?> buttonId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GridSlotsCompanion.insert(
                boardId: boardId,
                rowIndex: rowIndex,
                colIndex: colIndex,
                buttonId: buttonId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GridSlotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({boardId = false, buttonId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                    if (boardId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.boardId,
                                referencedTable: $$GridSlotsTableReferences
                                    ._boardIdTable(db),
                                referencedColumn: $$GridSlotsTableReferences
                                    ._boardIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (buttonId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.buttonId,
                                referencedTable: $$GridSlotsTableReferences
                                    ._buttonIdTable(db),
                                referencedColumn: $$GridSlotsTableReferences
                                    ._buttonIdTable(db)
                                    .id,
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

typedef $$GridSlotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GridSlotsTable,
      GridSlot,
      $$GridSlotsTableFilterComposer,
      $$GridSlotsTableOrderingComposer,
      $$GridSlotsTableAnnotationComposer,
      $$GridSlotsTableCreateCompanionBuilder,
      $$GridSlotsTableUpdateCompanionBuilder,
      (GridSlot, $$GridSlotsTableReferences),
      GridSlot,
      PrefetchHooks Function({bool boardId, bool buttonId})
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BoardsTableTableManager get boards =>
      $$BoardsTableTableManager(_db, _db.boards);
  $$ImagesTableTableManager get images =>
      $$ImagesTableTableManager(_db, _db.images);
  $$SoundsTableTableManager get sounds =>
      $$SoundsTableTableManager(_db, _db.sounds);
  $$ButtonsTableTableManager get buttons =>
      $$ButtonsTableTableManager(_db, _db.buttons);
  $$GridSlotsTableTableManager get gridSlots =>
      $$GridSlotsTableTableManager(_db, _db.gridSlots);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}

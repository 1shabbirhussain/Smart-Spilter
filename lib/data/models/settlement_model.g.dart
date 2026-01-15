// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settlement_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSettlementCollection on Isar {
  IsarCollection<Settlement> get settlements => this.collection();
}

const SettlementSchema = CollectionSchema(
  name: r'Settlement',
  id: -1134216852554678745,
  properties: {
    r'amount': PropertySchema(
      id: 0,
      name: r'amount',
      type: IsarType.double,
    ),
    r'fromMemberId': PropertySchema(
      id: 1,
      name: r'fromMemberId',
      type: IsarType.long,
    ),
    r'groupId': PropertySchema(
      id: 2,
      name: r'groupId',
      type: IsarType.long,
    ),
    r'isPartial': PropertySchema(
      id: 3,
      name: r'isPartial',
      type: IsarType.bool,
    ),
    r'notes': PropertySchema(
      id: 4,
      name: r'notes',
      type: IsarType.string,
    ),
    r'settledAt': PropertySchema(
      id: 5,
      name: r'settledAt',
      type: IsarType.dateTime,
    ),
    r'toMemberId': PropertySchema(
      id: 6,
      name: r'toMemberId',
      type: IsarType.long,
    )
  },
  estimateSize: _settlementEstimateSize,
  serialize: _settlementSerialize,
  deserialize: _settlementDeserialize,
  deserializeProp: _settlementDeserializeProp,
  idName: r'id',
  indexes: {
    r'groupId': IndexSchema(
      id: -8523216633229774932,
      name: r'groupId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'groupId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _settlementGetId,
  getLinks: _settlementGetLinks,
  attach: _settlementAttach,
  version: '3.1.0+1',
);

int _settlementEstimateSize(
  Settlement object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _settlementSerialize(
  Settlement object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeLong(offsets[1], object.fromMemberId);
  writer.writeLong(offsets[2], object.groupId);
  writer.writeBool(offsets[3], object.isPartial);
  writer.writeString(offsets[4], object.notes);
  writer.writeDateTime(offsets[5], object.settledAt);
  writer.writeLong(offsets[6], object.toMemberId);
}

Settlement _settlementDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Settlement(
    amount: reader.readDouble(offsets[0]),
    fromMemberId: reader.readLong(offsets[1]),
    groupId: reader.readLong(offsets[2]),
    id: id,
    isPartial: reader.readBoolOrNull(offsets[3]) ?? false,
    notes: reader.readStringOrNull(offsets[4]),
    toMemberId: reader.readLong(offsets[6]),
  );
  object.settledAt = reader.readDateTime(offsets[5]);
  return object;
}

P _settlementDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _settlementGetId(Settlement object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _settlementGetLinks(Settlement object) {
  return [];
}

void _settlementAttach(IsarCollection<dynamic> col, Id id, Settlement object) {
  object.id = id;
}

extension SettlementQueryWhereSort
    on QueryBuilder<Settlement, Settlement, QWhere> {
  QueryBuilder<Settlement, Settlement, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterWhere> anyGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'groupId'),
      );
    });
  }
}

extension SettlementQueryWhere
    on QueryBuilder<Settlement, Settlement, QWhereClause> {
  QueryBuilder<Settlement, Settlement, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterWhereClause> groupIdEqualTo(
      int groupId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'groupId',
        value: [groupId],
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterWhereClause> groupIdNotEqualTo(
      int groupId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId',
              lower: [],
              upper: [groupId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId',
              lower: [groupId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId',
              lower: [groupId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId',
              lower: [],
              upper: [groupId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterWhereClause> groupIdGreaterThan(
    int groupId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'groupId',
        lower: [groupId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterWhereClause> groupIdLessThan(
    int groupId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'groupId',
        lower: [],
        upper: [groupId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterWhereClause> groupIdBetween(
    int lowerGroupId,
    int upperGroupId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'groupId',
        lower: [lowerGroupId],
        includeLower: includeLower,
        upper: [upperGroupId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SettlementQueryFilter
    on QueryBuilder<Settlement, Settlement, QFilterCondition> {
  QueryBuilder<Settlement, Settlement, QAfterFilterCondition> amountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition> amountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition> amountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition> amountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'amount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition>
      fromMemberIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fromMemberId',
        value: value,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition>
      fromMemberIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fromMemberId',
        value: value,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition>
      fromMemberIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fromMemberId',
        value: value,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition>
      fromMemberIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fromMemberId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition> groupIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'groupId',
        value: value,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition>
      groupIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'groupId',
        value: value,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition> groupIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'groupId',
        value: value,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition> groupIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'groupId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition> isPartialEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPartial',
        value: value,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition> notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition> notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition> notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition> notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition> notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition> notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition> notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition> notesContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition> notesMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition> settledAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settledAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition>
      settledAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'settledAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition> settledAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'settledAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition> settledAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'settledAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition> toMemberIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'toMemberId',
        value: value,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition>
      toMemberIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'toMemberId',
        value: value,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition>
      toMemberIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'toMemberId',
        value: value,
      ));
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterFilterCondition> toMemberIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'toMemberId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SettlementQueryObject
    on QueryBuilder<Settlement, Settlement, QFilterCondition> {}

extension SettlementQueryLinks
    on QueryBuilder<Settlement, Settlement, QFilterCondition> {}

extension SettlementQuerySortBy
    on QueryBuilder<Settlement, Settlement, QSortBy> {
  QueryBuilder<Settlement, Settlement, QAfterSortBy> sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterSortBy> sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterSortBy> sortByFromMemberId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromMemberId', Sort.asc);
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterSortBy> sortByFromMemberIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromMemberId', Sort.desc);
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterSortBy> sortByGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.asc);
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterSortBy> sortByGroupIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.desc);
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterSortBy> sortByIsPartial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPartial', Sort.asc);
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterSortBy> sortByIsPartialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPartial', Sort.desc);
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterSortBy> sortBySettledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settledAt', Sort.asc);
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterSortBy> sortBySettledAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settledAt', Sort.desc);
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterSortBy> sortByToMemberId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toMemberId', Sort.asc);
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterSortBy> sortByToMemberIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toMemberId', Sort.desc);
    });
  }
}

extension SettlementQuerySortThenBy
    on QueryBuilder<Settlement, Settlement, QSortThenBy> {
  QueryBuilder<Settlement, Settlement, QAfterSortBy> thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterSortBy> thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterSortBy> thenByFromMemberId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromMemberId', Sort.asc);
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterSortBy> thenByFromMemberIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromMemberId', Sort.desc);
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterSortBy> thenByGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.asc);
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterSortBy> thenByGroupIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.desc);
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterSortBy> thenByIsPartial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPartial', Sort.asc);
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterSortBy> thenByIsPartialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPartial', Sort.desc);
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterSortBy> thenBySettledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settledAt', Sort.asc);
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterSortBy> thenBySettledAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settledAt', Sort.desc);
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterSortBy> thenByToMemberId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toMemberId', Sort.asc);
    });
  }

  QueryBuilder<Settlement, Settlement, QAfterSortBy> thenByToMemberIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toMemberId', Sort.desc);
    });
  }
}

extension SettlementQueryWhereDistinct
    on QueryBuilder<Settlement, Settlement, QDistinct> {
  QueryBuilder<Settlement, Settlement, QDistinct> distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<Settlement, Settlement, QDistinct> distinctByFromMemberId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fromMemberId');
    });
  }

  QueryBuilder<Settlement, Settlement, QDistinct> distinctByGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'groupId');
    });
  }

  QueryBuilder<Settlement, Settlement, QDistinct> distinctByIsPartial() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPartial');
    });
  }

  QueryBuilder<Settlement, Settlement, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Settlement, Settlement, QDistinct> distinctBySettledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'settledAt');
    });
  }

  QueryBuilder<Settlement, Settlement, QDistinct> distinctByToMemberId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'toMemberId');
    });
  }
}

extension SettlementQueryProperty
    on QueryBuilder<Settlement, Settlement, QQueryProperty> {
  QueryBuilder<Settlement, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Settlement, double, QQueryOperations> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<Settlement, int, QQueryOperations> fromMemberIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fromMemberId');
    });
  }

  QueryBuilder<Settlement, int, QQueryOperations> groupIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'groupId');
    });
  }

  QueryBuilder<Settlement, bool, QQueryOperations> isPartialProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPartial');
    });
  }

  QueryBuilder<Settlement, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<Settlement, DateTime, QQueryOperations> settledAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'settledAt');
    });
  }

  QueryBuilder<Settlement, int, QQueryOperations> toMemberIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'toMemberId');
    });
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMemberCollection on Isar {
  IsarCollection<Member> get members => this.collection();
}

const MemberSchema = CollectionSchema(
  name: r'Member',
  id: -635267144951875289,
  properties: {
    r'colorHex': PropertySchema(
      id: 0,
      name: r'colorHex',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'emoji': PropertySchema(
      id: 2,
      name: r'emoji',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 3,
      name: r'name',
      type: IsarType.string,
    )
  },
  estimateSize: _memberEstimateSize,
  serialize: _memberSerialize,
  deserialize: _memberDeserialize,
  deserializeProp: _memberDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _memberGetId,
  getLinks: _memberGetLinks,
  attach: _memberAttach,
  version: '3.1.0+1',
);

int _memberEstimateSize(
  Member object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.colorHex.length * 3;
  bytesCount += 3 + object.emoji.length * 3;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _memberSerialize(
  Member object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.colorHex);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.emoji);
  writer.writeString(offsets[3], object.name);
}

Member _memberDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Member(
    colorHex: reader.readString(offsets[0]),
    emoji: reader.readString(offsets[2]),
    id: id,
    name: reader.readString(offsets[3]),
  );
  object.createdAt = reader.readDateTime(offsets[1]);
  return object;
}

P _memberDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _memberGetId(Member object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _memberGetLinks(Member object) {
  return [];
}

void _memberAttach(IsarCollection<dynamic> col, Id id, Member object) {
  object.id = id;
}

extension MemberQueryWhereSort on QueryBuilder<Member, Member, QWhere> {
  QueryBuilder<Member, Member, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MemberQueryWhere on QueryBuilder<Member, Member, QWhereClause> {
  QueryBuilder<Member, Member, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Member, Member, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Member, Member, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Member, Member, QAfterWhereClause> idBetween(
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
}

extension MemberQueryFilter on QueryBuilder<Member, Member, QFilterCondition> {
  QueryBuilder<Member, Member, QAfterFilterCondition> colorHexEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> colorHexGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'colorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> colorHexLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'colorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> colorHexBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'colorHex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> colorHexStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'colorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> colorHexEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'colorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> colorHexContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'colorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> colorHexMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'colorHex',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> colorHexIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colorHex',
        value: '',
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> colorHexIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'colorHex',
        value: '',
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> emojiEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'emoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> emojiGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'emoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> emojiLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'emoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> emojiBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'emoji',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> emojiStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'emoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> emojiEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'emoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> emojiContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'emoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> emojiMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'emoji',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> emojiIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'emoji',
        value: '',
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> emojiIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'emoji',
        value: '',
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Member, Member, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Member, Member, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Member, Member, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> nameContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Member, Member, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }
}

extension MemberQueryObject on QueryBuilder<Member, Member, QFilterCondition> {}

extension MemberQueryLinks on QueryBuilder<Member, Member, QFilterCondition> {}

extension MemberQuerySortBy on QueryBuilder<Member, Member, QSortBy> {
  QueryBuilder<Member, Member, QAfterSortBy> sortByColorHex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorHex', Sort.asc);
    });
  }

  QueryBuilder<Member, Member, QAfterSortBy> sortByColorHexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorHex', Sort.desc);
    });
  }

  QueryBuilder<Member, Member, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Member, Member, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Member, Member, QAfterSortBy> sortByEmoji() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emoji', Sort.asc);
    });
  }

  QueryBuilder<Member, Member, QAfterSortBy> sortByEmojiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emoji', Sort.desc);
    });
  }

  QueryBuilder<Member, Member, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Member, Member, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension MemberQuerySortThenBy on QueryBuilder<Member, Member, QSortThenBy> {
  QueryBuilder<Member, Member, QAfterSortBy> thenByColorHex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorHex', Sort.asc);
    });
  }

  QueryBuilder<Member, Member, QAfterSortBy> thenByColorHexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorHex', Sort.desc);
    });
  }

  QueryBuilder<Member, Member, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Member, Member, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Member, Member, QAfterSortBy> thenByEmoji() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emoji', Sort.asc);
    });
  }

  QueryBuilder<Member, Member, QAfterSortBy> thenByEmojiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emoji', Sort.desc);
    });
  }

  QueryBuilder<Member, Member, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Member, Member, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Member, Member, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Member, Member, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension MemberQueryWhereDistinct on QueryBuilder<Member, Member, QDistinct> {
  QueryBuilder<Member, Member, QDistinct> distinctByColorHex(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'colorHex', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Member, Member, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Member, Member, QDistinct> distinctByEmoji(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'emoji', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Member, Member, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }
}

extension MemberQueryProperty on QueryBuilder<Member, Member, QQueryProperty> {
  QueryBuilder<Member, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Member, String, QQueryOperations> colorHexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'colorHex');
    });
  }

  QueryBuilder<Member, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Member, String, QQueryOperations> emojiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'emoji');
    });
  }

  QueryBuilder<Member, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }
}

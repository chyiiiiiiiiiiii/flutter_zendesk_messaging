import '../enums/authentication_type.dart';

/// User information returned from Zendesk SDK.
///
/// Contains the user's ID, external ID, and authentication type.
class ZendeskUser {
  /// Creates a new [ZendeskUser] instance.
  const ZendeskUser({
    this.id,
    this.externalId,
    this.authenticationType = ZendeskAuthenticationType.anonymous,
  });

  /// The Zendesk internal user ID.
  final String? id;

  /// The external ID provided during JWT authentication.
  final String? externalId;

  /// The authentication type of the user.
  final ZendeskAuthenticationType authenticationType;

  /// Creates a [ZendeskUser] from a map.
  ///
  /// Used for deserializing data from the native platform.
  factory ZendeskUser.fromMap(Map<String, dynamic> map) {
    return ZendeskUser(
      id: map['id'] as String?,
      externalId: map['externalId'] as String?,
      authenticationType: ZendeskAuthenticationType.fromString(
        map['authenticationType'] as String?,
      ),
    );
  }

  @override
  String toString() {
    return 'ZendeskUser(id: $id, externalId: $externalId, '
        'authenticationType: ${authenticationType.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ZendeskUser &&
        other.id == id &&
        other.externalId == externalId &&
        other.authenticationType == authenticationType;
  }

  @override
  int get hashCode => Object.hash(id, externalId, authenticationType);
}

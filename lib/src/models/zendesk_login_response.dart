/// Response from a successful login operation.
///
/// Contains the user's ID and external ID after authentication.
class ZendeskLoginResponse {
  /// Creates a new [ZendeskLoginResponse] instance.
  const ZendeskLoginResponse({
    this.id,
    this.externalId,
  });

  /// The Zendesk internal user ID.
  final String? id;

  /// The external ID provided during JWT authentication.
  final String? externalId;

  /// Creates a [ZendeskLoginResponse] from a map.
  ///
  /// Used for deserializing data from the native platform.
  factory ZendeskLoginResponse.fromMap(Map<String, dynamic> map) {
    return ZendeskLoginResponse(
      id: map['id'] as String?,
      externalId: map['externalId'] as String?,
    );
  }

  @override
  String toString() {
    return 'ZendeskLoginResponse(id: $id, externalId: $externalId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ZendeskLoginResponse &&
        other.id == id &&
        other.externalId == externalId;
  }

  @override
  int get hashCode => Object.hash(id, externalId);
}

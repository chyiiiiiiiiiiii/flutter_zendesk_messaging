/// Authentication type for the Zendesk user.
enum ZendeskAuthenticationType {
  /// Anonymous user (not authenticated with JWT).
  anonymous,

  /// Authenticated user with JWT token.
  jwt;

  /// Parse authentication type from string.
  ///
  /// Returns [anonymous] if the value is null or not recognized.
  static ZendeskAuthenticationType fromString(String? value) {
    if (value == null) return ZendeskAuthenticationType.anonymous;
    return switch (value.toLowerCase()) {
      'jwt' => ZendeskAuthenticationType.jwt,
      _ => ZendeskAuthenticationType.anonymous,
    };
  }
}

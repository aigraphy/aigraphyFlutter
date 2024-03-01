mixin Subscription {
  static String listenUser = '''
    subscription GetUser(\$uuid: String = "") {
      User(where: {uuid: {_eq: \$uuid}}) {
        id
        name
        email
        uuid
        avatar
        token
        language
        date_checkin
        slot_recent_face
        slot_history
      }
    }
  ''';

  static String listenRecentFace = '''
    subscription listenRecentFace(\$user_uuid: String = "") {
      RecentFace(where: {user_uuid: {_eq: \$user_uuid}}, order_by: {updated_at: desc}) {
        id
        face
        user_uuid
        updated_at
      }
    }
  ''';

  static String listenRequests = '''
    subscription listenRequests(\$uuid: String = "") {
      Request(where: {uuid: {_eq: \$uuid}}, limit: 10, order_by: {created_at: desc}) {
        id
        uuid
        image_res
      }
    }
  ''';
}

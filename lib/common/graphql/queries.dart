import 'package:aigraphy_flutter/common/constant/helper.dart';

mixin Queries {
  static String getUser = '''
    query GetUser(\$uuid: String = "") {
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

  static String getRequests = '''
    query getRequests(\$uuid: String = "", \$offset: Int = 0, \$limit: Int = 0) {
      Request(where: {uuid: {_eq: \$uuid}}, order_by: {created_at: desc}, limit: \$limit, offset: \$offset) {
        id
        uuid
        image_res
        ImageRemBG {
          id
          image_rembg
          request_id
        }
      }
    }
  ''';

  static String getRecentFace = '''
    query getRecentFace(\$user_uuid: String = "") {
      RecentFace(where: {user_uuid: {_eq: \$user_uuid}}, order_by: {updated_at: desc}) {
        id
        face
        user_uuid
        updated_at
      }
    }
  ''';

  static String getCategories = '''
    query getCategories(\$offset: Int = 0, \$limit: Int = 0) {
      Category(order_by: {number: asc}, limit: \$limit, offset: \$offset) {
        id
        name
        number
        ImageCategories(order_by: {updated_at: desc}, limit: $IMAGE_SHOW_LIMIT) {
          id
          image
          category_id
          count_swap
        }
      }
    }
  ''';

  static String getFullImageCategory = '''
    query getFullImageCategory(\$category_id: Int = 10, \$limit: Int = 10, \$offset: Int = 10) {
      ImageCategory(where: {category_id: {_eq: \$category_id}}, order_by: {count_swap: desc}, limit: \$limit, offset: \$offset) {
        id
        category_id
        image
        count_swap
      }
    }
  ''';

  static String getImageToday = '''
    query getImageToday {
        ImageCategory(order_by: {created_at: desc}, limit: 20) {
          id
          category_id
          image
          count_swap
        }
      }
  ''';

  static String getImageTrending = '''
    query getImageTrending {
        ImageCategory(order_by: {count_swap: desc}, limit: 20) {
          id
          category_id
          image
          count_swap
        }
      }
  ''';
}

import '../config/config_helper.dart';

mixin ConfigQuery {
  static String getPerson = '''
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

  static String getHistories = '''
    query getRequests(\$uuid: String = "", \$offset: Int = 0, \$limit: Int = 0) {
      Request(where: {uuid: {_eq: \$uuid}}, order_by: {created_at: desc}, limit: \$limit, offset: \$offset) {
        id
        uuid
        image_res
        from_cate
        ImageRemBG {
          id
          image_rembg
          request_id
        }
      }
    }
  ''';

  static String getFace = '''
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
        is_pro
        ImageCategories(order_by: {updated_at: desc}, limit: $IMAGE_SHOW_LIMIT) {
          id
          image
          category_id
          count_swap
          is_pro
        }
      }
    }
  ''';

  static String getFullImgCate = '''
    query getFullImageCategory(\$category_id: Int = 10, \$limit: Int = 10, \$offset: Int = 10) {
      ImageCategory(where: {category_id: {_eq: \$category_id}}, order_by: {count_swap: desc}, limit: \$limit, offset: \$offset) {
        id
        category_id
        image
        count_swap
        is_pro
      }
    }
  ''';

  static String getImgToday = '''
    query getImageToday {
        ImageCategory(order_by: {created_at: desc}, limit: 20) {
          id
          category_id
          image
          count_swap
          is_pro
        }
      }
  ''';

  static String getImgTrending = '''
    query getImageTrending {
        ImageCategory(order_by: {count_swap: desc}, limit: 20) {
          id
          category_id
          image
          count_swap
          is_pro
        }
      }
  ''';

  static String getLikedPost = '''
    query getLikedPost(\$user_uuid: String = "") {
      LikePost(where: {user_uuid: {_eq: \$user_uuid}}) {
        id
        post_id
        user_uuid
      }
    }
  ''';

  static String getPosts = '''
    query getPosts(\$offset: Int = 0) {
      Post(limit: $POST_LIMIT, offset: \$offset, order_by: {published: desc}) {
        id
        published
        user_uuid
        link_image
        history_id
        User {
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
        LikePosts_aggregate {
          aggregate {
            count(columns: post_id)
          }
        }
      }
    }
  ''';
}

mixin ConfigMutation {
  static String updatePerson() {
    return '''mutation updateUser(\$token: Int = 0, \$uuid: String = "") {
      update_User(where: {uuid: {_eq: \$uuid}}, _set: {token: \$token}) {
        returning {
          id
          token
        }
      }
    }
''';
  }

  static String updateDateCheckIn() {
    return '''mutation updateDateCheckIn(\$uuid: String = "", \$date_checkin: timestamp = "", \$token: Int = 0) {
      update_User(where: {uuid: {_eq: \$uuid}}, _set: {date_checkin: \$date_checkin, token: \$token}) {
        returning {
          id
        }
      }
    }
''';
  }

  static String updateSlotFace() {
    return '''mutation updateSlotRecentFace(\$uuid: String = "", \$slot_recent_face: Int = 0, \$token: Int = 0) {
      update_User(where: {uuid: {_eq: \$uuid}}, _set: {slot_recent_face: \$slot_recent_face, token: \$token}) {
        returning {
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
    }
''';
  }

  static String updateSlotHistory() {
    return '''mutation updateSlotHistory(\$uuid: String = "", \$slot_history: Int = 0, \$token: Int = 0) {
      update_User(where: {uuid: {_eq: \$uuid}}, _set: {slot_history: \$slot_history, token: \$token}) {
        returning {
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
    }
''';
  }

  static String insertFace() {
    return '''mutation insertRecentFace(\$face: String = "", \$user_uuid: String = "") {
      insert_RecentFace_one(object: {face: \$face, user_uuid: \$user_uuid}) {
        id
      }
    }
''';
  }

  static String updateFace() {
    return '''mutation updateRecentFace(\$id: Int = 0, \$face: String = "") {
      update_RecentFace(where: {id: {_eq: \$id}}, _set: {face: \$face}) {
        returning {
          id
        }
      }
    }
''';
  }

  static String deleteFace() {
    return '''mutation deleteRecentFace(\$id: Int = 10) {
      delete_RecentFace(where: {id: {_eq: \$id}}) {
        returning {
          id
        }
      }
    }
''';
  }

  static String insertHistory() {
    return '''mutation InsertRequest(\$image_res: String = "", \$uuid: String = "", , \$from_cate: Boolean = false) {
      insert_Request_one(object: {image_res: \$image_res, uuid: \$uuid, from_cate: \$from_cate}) {
        id
        image_res
        from_cate
        uuid
        created_at
        ImageRemBG {
          id
          image_rembg
          request_id
        }
      }
    }
''';
  }

  static String insertImgRemBG() {
    return '''mutation insertImageRemBG(\$image_rembg: String = "", \$request_id: Int = 10) {
      insert_ImageRemBG_one(object: {image_rembg: \$image_rembg, request_id: \$request_id}) {
        id
        image_rembg
        request_id
      }
    }
''';
  }

  static String deleteHistory() {
    return '''mutation DeleteRequest(\$id: Int = 10) {
      delete_Request(where: {id: {_eq: \$id}}) {
        returning {
          id
        }
      }
    }
''';
  }

  static String deleteImgBG() {
    return '''mutation DeleteImageBG(\$id: Int = 10) {
      delete_ImageRemBG(where: {id: {_eq: \$id}}) {
        returning {
          id
        }
      }
    }
''';
  }

  static String deletePerson() {
    return '''mutation DeleteUser(\$uuid: String = "") {
      delete_User(where: {uuid: {_eq: \$uuid}}) {
        returning {
          id
        }
      }
    }
''';
  }

  static String updateLanguagePerson() {
    return '''mutation UpdateUser(\$uuid: String = "", \$language: String = "") {
      update_User(where: {uuid: {_eq: \$uuid}}, _set: {language: \$language}) {
        returning {
          id
        }
      }
    }
''';
  }

  static String updateImgCate() {
    return '''mutation updateImageCategory(\$count_swap: Int = 10, \$id: Int = 10) {
      update_ImageCategory(where: {id: {_eq: \$id}}, _set: {count_swap: \$count_swap}) {
        returning {
          id
        }
      }
    }
''';
  }

  static String insertFb() {
    return '''mutation insertFeedback(\$content: String = "", \$user_uuid: String = "") {
      insert_Feedback_one(object: {content: \$content, user_uuid: \$user_uuid}) {
        id
      }
    }
''';
  }

  static String deletePost() {
    return '''mutation deletePost(\$id: Int = 10) {
      delete_Post(where: {id: {_eq: \$id}}) {
        returning {
          id
        }
      }
    }
''';
  }

  static String insertPost() {
    return '''mutation insertPost(\$user_uuid: String = "", \$published: timestamp = "", \$history_id: Int = 10, \$link_image: String = "") {
      insert_Post_one(object: {user_uuid: \$user_uuid, published: \$published, history_id: \$history_id, link_image: \$link_image}) {
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

  static String insertLikePost() {
    return '''mutation insertLikePost(\$post_id: Int = 10, \$user_uuid: String = "") {
      insert_LikePost_one(object: {post_id: \$post_id, user_uuid: \$user_uuid}) {
        id
      }
    }
''';
  }

  static String deleteLikePost() {
    return '''mutation deleteLikePost(\$user_uuid: String = "", \$post_id: Int = 10) {
      delete_LikePost(where: {_and: {user_uuid: {_eq: \$user_uuid}, post_id: {_eq: \$post_id}}}) {
        returning {
          id
        }
      }
    }
''';
  }
}

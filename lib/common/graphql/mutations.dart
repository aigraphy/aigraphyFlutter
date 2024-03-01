mixin Mutations {
  static String updateUser() {
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

  static String updateSlotRecentFace() {
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

  static String insertRecentFace() {
    return '''mutation insertRecentFace(\$face: String = "", \$user_uuid: String = "") {
      insert_RecentFace_one(object: {face: \$face, user_uuid: \$user_uuid}) {
        id
      }
    }
''';
  }

  static String updateRecentFace() {
    return '''mutation updateRecentFace(\$id: Int = 0, \$face: String = "") {
      update_RecentFace(where: {id: {_eq: \$id}}, _set: {face: \$face}) {
        returning {
          id
        }
      }
    }
''';
  }

  static String deleteRecentFace() {
    return '''mutation deleteRecentFace(\$id: Int = 10) {
      delete_RecentFace(where: {id: {_eq: \$id}}) {
        returning {
          id
        }
      }
    }
''';
  }

  static String insertRequest() {
    return '''mutation InsertRequest(\$image_res: String = "", \$uuid: String = "") {
      insert_Request_one(object: {image_res: \$image_res, uuid: \$uuid}) {
        id
        image_res
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

  static String insertImageRemBG() {
    return '''mutation insertImageRemBG(\$image_rembg: String = "", \$request_id: Int = 10) {
      insert_ImageRemBG_one(object: {image_rembg: \$image_rembg, request_id: \$request_id}) {
        id
        image_rembg
        request_id
      }
    }
''';
  }

  static String deleteRequest() {
    return '''mutation DeleteRequest(\$id: Int = 10) {
      delete_Request(where: {id: {_eq: \$id}}) {
        returning {
          id
        }
      }
    }
''';
  }

  static String deleteImageBG() {
    return '''mutation DeleteImageBG(\$id: Int = 10) {
      delete_ImageRemBG(where: {id: {_eq: \$id}}) {
        returning {
          id
        }
      }
    }
''';
  }

  static String deleteUser() {
    return '''mutation DeleteUser(\$uuid: String = "") {
      delete_User(where: {uuid: {_eq: \$uuid}}) {
        returning {
          id
        }
      }
    }
''';
  }

  static String updateLanguageUser() {
    return '''mutation UpdateUser(\$uuid: String = "", \$language: String = "") {
      update_User(where: {uuid: {_eq: \$uuid}}, _set: {language: \$language}) {
        returning {
          id
        }
      }
    }
''';
  }

  static String updateImageCategory() {
    return '''mutation updateImageCategory(\$count_swap: Int = 10, \$id: Int = 10) {
      update_ImageCategory(where: {id: {_eq: \$id}}, _set: {count_swap: \$count_swap}) {
        returning {
          id
        }
      }
    }
''';
  }

  static String insertFeedback() {
    return '''mutation insertFeedback(\$content: String = "", \$user_uuid: String = "") {
      insert_Feedback_one(object: {content: \$content, user_uuid: \$user_uuid}) {
        id
      }
    }
''';
  }
}

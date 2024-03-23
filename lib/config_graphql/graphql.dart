import 'package:flutter/material.dart';
import 'package:graphql/client.dart';

import '../config/config_helper.dart';

mixin Graphql {
  static ValueNotifier<GraphQLClient> initialize(String _token) {
    final ValueNotifier<GraphQLClient> clt = ValueNotifier(
      GraphQLClient(
        cache: GraphQLCache(),
        link: WebSocketLink(
          apiGraphql,
          config: SocketClientConfig(
              autoReconnect: true,
              inactivityTimeout: const Duration(seconds: 120),
              initialPayload: <String, dynamic>{
                'headers': {
                  'Authorization': 'Bearer $_token',
                  'content-type': 'application/json',
                }
              }),
        ),
      ),
    );
    return clt;
  }
}

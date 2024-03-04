import 'package:flutter/material.dart';
import 'package:graphql/client.dart';

mixin Config {
  static ValueNotifier<GraphQLClient> initializeClient(String _token) {
    final ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        cache: GraphQLCache(),
        /* MUST CONFIG */
        link: WebSocketLink(
          'ws://138.68.111.65:8080/v1/graphql',
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
    return client;
  }
}

import 'dart:async';

import 'package:shelf/shelf.dart';

class AuthMiddleware {
  late Handler _serviceHandler;

  Middleware call() {
    // 返回以方法对象【即shelf要求的中间件格式】
    return middleware;
  }

  /// middleware 方法就是shelf的中间件，shelf的中间件就是一个方法对象而非类对象
  Handler middleware(Handler serviceHandler) {
    _serviceHandler = serviceHandler;
    return handler;
  }

  FutureOr<Response> handler(Request request) {
    if (request.url.toString().contains('secret')) {
      return Response.forbidden('抱歉，您不能访问隐私空间');
    } else {
      print('surround start auth');
      var response = _serviceHandler(request);
      print('surround end auth');
      return response;
    }
  }
}
import 'package:shelf/shelf.dart';
import 'package:shelf_static/shelf_static.dart';

import 'router_controllers/user_controller.dart';
import 'service_router.dart';

class AppConfig {
  bool _inited = false;

  late Handler _configHandler;

  final ServiceRouter _serviceRouter = ServiceRouter();

  /// 注意add的顺序，最先add的最先处理，因此在最外围
  final List<Middleware> _middlewares = [];

  AppConfig addMiddleware(Middleware middleware) {
    _middlewares.add(middleware);
    return this;
  }

  AppConfig addMiddlewares(List<Middleware> middlewares) {
    _middlewares.addAll(middlewares);
    return this;
  }

  /// 以描述形式出现时不用复数，以资源形式出现时要复数，如List<xxx> resources
  bool enableStaticResource = true;

  /// 相对于项目根目录的路径，这个就用resources其实就ok
  String resourceFolderRelativePath = 'resources';

  String defaultStaticResourceFileName = 'index.html';

  Handler handler404 = (req) {
    return Response.notFound('抱歉，您来到了没有资源的荒原');
  };  // 定义一种对象，所以这里需要;，而定义代码逻辑如switch，if或类型如class则不需要;

  void _config() {
    // 按顺序Filter请求
    var pipeline = const Pipeline();
    _middlewares.forEach((middleware) {
      // 必须重新赋值，addMiddleware后原先的pipeline没有变化【坑】
      pipeline = pipeline.addMiddleware(middleware);
    });

    _serviceRouter.addController(UserController());

    Handler resultHandler;
    var serviceHandler = _serviceRouter();
    if (enableStaticResource) {
      // 第二个参数只能是目录而不能是文件，所以index.html只能放到resources根目录
      var staticHandler = createStaticHandler(resourceFolderRelativePath, defaultDocument: defaultStaticResourceFileName);
      var cascade = Cascade()
        // 两个handler都能处理一个请求时，
        // 先add的handler优先处理，因此staticHandler应该放到业务逻辑的serviceHandler后面
        .add(serviceHandler)
        .add(staticHandler)
        .add(handler404);
      resultHandler = cascade.handler;
    } else {
      var cascade = Cascade().add(serviceHandler).add(handler404);
      resultHandler = cascade.handler;
    }
    _configHandler = pipeline.addHandler(resultHandler);
    _inited = true;
  }

  Handler call() {
    if (!_inited) {
      _config();
    }
    return _configHandler;
  }
}
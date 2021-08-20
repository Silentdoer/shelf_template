import 'package:meta/meta.dart';
import 'package:shelf_router/shelf_router.dart';

abstract class AbstractController {
  bool _inited = false;

  /// routes集合前缀（类似SpringBoot Controller上面的路径），要求/prefix/的格式
  /// 这个是shelf框架的mount方法要求的格式，为了和单个资源区分开来(/xx/表示xx是目录/xx表示xx是单个资源)
  final String _basePath;

  @protected
  late final Router router;

  String get basePath => _basePath;

  AbstractController(this._basePath) {
    // 校验prefix格式
    var pattern = RegExp(r'^/\w+/$');
    if (!pattern.hasMatch(_basePath)) {
      throw ArgumentError('base path must be /xxx/');
    }
  }

  @protected
  void config();

  Router call() {
    if (_inited) {
      return router;
    }
    router = Router();
    config();
    _inited = true;
    return router;
  }
}

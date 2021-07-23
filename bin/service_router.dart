import 'package:demo_shelf_template/abstract_controller.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

/// Controller和Handler都是Service的一种
class ServiceRouter {
  final Router _router = Router();

  final List<AbstractController> _controllers = [];

  ServiceRouter addController(AbstractController controller) {
    _controllers.add(controller);
    return this;
  }

  ServiceRouter addControllers(List<AbstractController> controllers) {
    _controllers.addAll(controllers);
    return this;
  }

  Router call() {
    // FIXME 这里只是为了演示，最好所有的route都用单独的Controller写出来，而不是直接在ServiceRouter里写；
    _router.all('/test', (req) => Response.ok('欢迎欢迎，热烈欢迎，${req.runtimeType}'));
    _router.get('/test1/<id>', _test1);
    _router.post('/test2', _test2);
    // 经过测试staticHandler最好是放到最后add
    _router.get('/aaa.txt', (_) => Response.ok('先执行了接口层面的handler'));

    _controllers.forEach((controller) => _router.mount(controller.basePath, controller()));
    return _router;
  }

  Response _test1(Request request) {
    print(request.url.queryParameters);
    print(request.url.queryParametersAll);
    return Response.ok('test1 process ${request.url}');
  }
  
  Future<Response> _test2(Request request) async {
    return Response.ok('test2 process ${request.context} -- ${await request.readAsString()}');
  }
}
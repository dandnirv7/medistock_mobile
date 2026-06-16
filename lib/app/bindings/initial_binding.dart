import 'package:get/get.dart';

/// Initial binding is intentionally a no-op: persistent services
/// (storage, api client, dummy store, auth session) are registered eagerly in
/// `main()` so the initial route decision can read hydrated state synchronously.
class InitialBinding extends Bindings {
  @override
  void dependencies() {}
}

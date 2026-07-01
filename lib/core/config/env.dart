import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'CURRENCYFREAKS_API_KEY', obfuscate: true)
  static final String currencyFreaksApiKey = _Env.currencyFreaksApiKey;
}

import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/profil/bindings/profil_binding.dart';
import '../modules/profil/views/profil_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/reset_password/bindings/reset_password_binding.dart';
import '../modules/reset_password/views/reset_password_view.dart';
// import '../modules/rincian_pesanan/bindings/rincian_pesanan_binding.dart';
// import '../modules/rincian_pesanan/views/rincian_pesanan_view.dart';
// import '../modules/rincian_pesanan/bindings/rincian_pesanan_binding.dart';
import '../modules/rincian_pesanan/bindings/rincian_pesanan_binding.dart';
import '../modules/rincian_pesanan/views/rincian_pesanan_view.dart';
import '../modules/splashscreen/bindings/splashscreen_binding.dart';
import '../modules/splashscreen/views/splashscreen_view.dart';
import '../modules/lacak/views/lacak_view.dart';
import '../modules/lacak/bindings/lacak_binding.dart';
import '../modules/pesanan/views/pesanan_view.dart';
import '../modules/pesanan/bindings/pesanan_binding.dart';
part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASHSCREEN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SPLASHSCREEN,
      page: () => const SplashscreenView(),
      binding: SplashscreenBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.RESET_PASSWORD,
      page: () => ResetPasswordView(),
      binding: ResetPasswordBinding(),
    ),
    GetPage(
      name: _Paths.PROFIL,
      page: () => ProfilView(),
      binding: ProfilBinding(),
    ),
    GetPage(
      name: Routes.RINCIAN_PESANAN,
      page: () => RincianPesananView(
          // pesananId: 'id',
          ),
      binding: RincianPesananBinding(),
    ),
    GetPage(
      name: Routes.PESANAN,
      page: () =>PesananView(),
      binding: PesananBinding(),
    ),
    GetPage(
      name: _Paths.LACAK,
      page: () => LacakView(),
      binding: LacakBinding(),
    ),
  ];
}

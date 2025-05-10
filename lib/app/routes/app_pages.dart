import 'package:get/get.dart';
import 'package:kos29/app/modules/auth/manage_user/bindings/manage_user_binding.dart';
import 'package:kos29/app/modules/auth/manage_user/views/manage_user_view.dart';
import '../modules/auth/edit_profile/bindings/edit_profile_binding.dart';
import '../modules/auth/edit_profile/views/edit_profile_view.dart';
import '../modules/auth/register/bindings/auth_register_binding.dart';
import '../modules/auth/register/views/auth_register_view.dart';
import '../modules/auth/reset_password/bindings/auth_reset_password_binding.dart';
import '../modules/auth/reset_password/views/auth_reset_password_view.dart';
import '../modules/auth/sign_in/bindings/sign_in_binding.dart';
import '../modules/auth/sign_in/views/sign_in_view.dart';
import '../modules/bottom_nav/bindings/bottom_nav_binding.dart';
import '../modules/bottom_nav/views/bottom_nav_view.dart';
import '../modules/change_location/bindings/change_location_binding.dart';
import '../modules/change_location/views/change_location_view.dart';
import '../modules/detail_page/bindings/detail_page_binding.dart';
import '../modules/detail_page/views/detail_page_view.dart';
import '../modules/form_profile/bindings/form_profile_binding.dart';
import '../modules/form_profile/views/form_profile_view.dart';
import '../modules/history_search/bindings/history_search_binding.dart';
import '../modules/history_search/views/history_search_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/kost_page/bindings/kost_page_binding.dart';
import '../modules/kost_page/views/kost_page_view.dart';
import '../modules/management_kost/add_kost/bindings/management_kost_add_kost_binding.dart';
import '../modules/management_kost/add_kost/views/management_kost_add_kost_view.dart';
import '../modules/management_kost/detail_kost/bindings/management_kost_detail_kost_binding.dart';
import '../modules/management_kost/detail_kost/views/management_kost_detail_kost_view.dart';
import '../modules/management_kost/edit_kost/bindings/management_kost_edit_kost_binding.dart';
import '../modules/management_kost/edit_kost/views/management_kost_edit_kost_view.dart';
import '../modules/management_kost/review_management/bindings/review_management_binding.dart';
import '../modules/management_kost/review_management/views/review_management_view.dart';
import '../modules/notification_page/bindings/notification_page_binding.dart';
import '../modules/notification_page/views/notification_page_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/search_page/bindings/search_page_binding.dart';
import '../modules/search_page/views/search_page_view.dart';
import '../modules/splash_screen/bindings/splash_screen_binding.dart';
import '../modules/splash_screen/views/splash_screen_view.dart';
import '../modules/unauth/bindings/unauth_binding.dart';
import '../modules/unauth/views/unauth_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH_SCREEN;

  static final routes = [
    GetPage(name: _Paths.HOME, page: () => HomeView(), binding: HomeBinding()),
    GetPage(
      name: _Paths.SPLASH_SCREEN,
      page: () => SplashScreenView(),
      binding: SplashScreenBinding(),
    ),
    GetPage(
      name: _Paths.SIGN_IN,
      page: () => SignInView(),
      binding: SignInBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.BOTTOM_NAV,
      page: () => const BottomNavView(),
      binding: BottomNavBinding(),
    ),
    GetPage(
      name: _Paths.SEARCH_PAGE,
      page: () => SearchPageView(),
      binding: SearchPageBinding(),
    ),
    GetPage(
      name: _Paths.FORM_PROFILE,
      page: () => const FormProfileView(),
      binding: FormProfileBinding(),
    ),
    GetPage(
      name: _Paths.UNAUTH,
      page: () => const UnauthView(),
      binding: UnauthBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.DETAIL_PAGE,
      page: () => DetailPageView(),
      binding: DetailPageBinding(),
    ),
    GetPage(
      name: _Paths.HISTORY_SEARCH,
      page: () => HistorySearchView(),
      binding: HistorySearchBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATION_PAGE,
      page: () => const NotificationPageView(),
      binding: NotificationPageBinding(),
    ),
    GetPage(
      name: _Paths.KOST_PAGE,
      page: () => const KostPageView(),
      binding: KostPageBinding(),
    ),
    GetPage(
      name: _Paths.MANAGEMENT_KOST_DETAIL_KOST,
      page: () => ManagementKostDetailKostView(),
      binding: ManagementKostDetailKostBinding(),
    ),
    GetPage(
      name: _Paths.MANAGEMENT_KOST_ADD_KOST,
      page: () => ManagementKostAddKostView(),
      binding: ManagementKostAddKostBinding(),
    ),
    GetPage(
      name: _Paths.MANAGEMENT_KOST_EDIT_KOST,
      page: () => ManagementKostEditKostView(),
      binding: ManagementKostEditKostBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_PROFILE,
      page: () => EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: _Paths.REVIEW_MANAGEMENT,
      page: () => const ReviewManagementView(),
      binding: ReviewManagementBinding(),
    ),
    GetPage(
      name: _Paths.CHANGE_LOCATION,
      page: () => const ChangeLocationView(),
      binding: ChangeLocationBinding(),
    ),
    GetPage(
      name: _Paths.AUTH_REGISTER,
      page: () => const AuthRegisterView(),
      binding: AuthRegisterBinding(),
    ),
    GetPage(
      name: _Paths.AUTH_RESET_PASSWORD,
      page: () => const AuthResetPasswordView(),
      binding: AuthResetPasswordBinding(),
    ),
    GetPage(
      name: _Paths.AUTH_MANAGE_USER,
      page: () => const ManageUserView(),
      binding: ManageUserBinding(),
    ),
  ];
}

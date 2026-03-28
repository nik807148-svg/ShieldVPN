import 'package:hiddify/core/preferences/general_preferences.dart';
import 'package:hiddify/features/profile/data/profile_repository.dart';
import 'package:hiddify/utils/custom_loggers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// ShieldVPN Auto-Connect Service
/// Automatically adds the default VPN profile on first launch
/// and skips the intro screen.
class AutoConnectService with InfraLogger {
  final ProfileRepository profileRepository;
  final Ref ref;

  AutoConnectService({required this.profileRepository, required this.ref});

  Future<void> setupDefaultProfile() async {
    try {
      final introCompleted = ref.read(Preferences.introCompleted);
      if (introCompleted) return;
      loggy.info('First launch - adding default ShieldVPN profile');
      const vlessUri =
          'vless://shieldvpn-default@107.174.133.39:443'
          '?type=tcp&security=reality'
          '&pbk=O_bkOgKLdswCloNcKJcGBV3fyVfbO786GtRQj3Utfkc'
          '&fp=chrome'
          '&sni=www.nvidia.com'
          '&sid=8e4a623c'
          '&spx=%2F'
          '&flow=xtls-rprx-vision'
          '#ShieldVPN';
      final result = await profileRepository.addLocal(vlessUri);
      result.match(
        (failure) => loggy.error('Failed to add default profile'),
        (_) {
          loggy.info('Default ShieldVPN profile added successfully');
          ref.read(Preferences.introCompleted.notifier).update(true);
        },
      );
    } catch (e, st) {
      loggy.error('Auto-connect setup failed', e, st);
    }
  }
}

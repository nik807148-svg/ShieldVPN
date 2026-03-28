import 'package:hiddify/core/preferences/general_preferences.dart';
import 'package:hiddify/features/profile/data/profile_repository.dart';
import 'package:hiddify/utils/custom_loggers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// ShieldVPN Auto-Connect Service
/// Automatically adds the default VPN profile on first launch
/// and skips the intro screen.
class AutoConnectService with InfraLogger {
  final ProfileRepository profileRepository;
  final ProviderContainer container;

  AutoConnectService({required this.profileRepository, required this.container});

  Future<void> setupDefaultProfile() async {
    try {
      final introCompleted = container.read(Preferences.introCompleted);
      if (introCompleted) return;

      loggy.info('First launch - adding default ShieldVPN profile');

      // Use addLocal with real VLESS URI from x-ui panel
      const vlessUri =
          'vless://206c6565-273e-42ca-b357-90db91c1c198@107.174.133.39:443'
          '?encryption=none'
          '&flow=xtls-rprx-vision'
          '&fp=chrome'
          '&pbk=O_bkOgKLdswCloNcKJcGBV3fyVfbO786GtRQj3Utfkc'
          '&security=reality'
          '&sid=302a05280f5f'
          '&sni=www.nvidia.com'
          '&spx=%2Fs1HrhDYmSlQ0ac4'
          '&type=tcp'
          '#ShieldVPN';

      final result = await profileRepository.addLocal(vlessUri);

      result.match(
        (failure) => loggy.error('Failed to add default profile: $failure'),
        (_) {
          loggy.info('Default ShieldVPN profile added successfully');
          container.read(Preferences.introCompleted.notifier).update(true);
        },
      );
    } catch (e, st) {
      loggy.error('Auto-connect setup failed', e, st);
    }
  }
}

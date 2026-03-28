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

      // Use subscription URL instead of local VLESS URI
      final result = await profileRepository.upsertRemote(
        'https://107.174.133.39:2096/sub/tv2p2clfy7j96cfj',
      );

      result.match(
        (failure) => loggy.error('Failed to add default profile'),
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

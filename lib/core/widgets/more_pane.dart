/// The More destination pane.
///
/// The fourth top-level destination of the validated navigation
/// (Home / Projects / Activity / More). Phase 0 of
/// `docs/ANDROID_DAILY_DRIVER_ROADMAP.md` requires the shell to expose every
/// capability instead of hiding it in a drawer, and requires an embedded
/// Dashboard fallback entry so no capability is blocked while the native UX
/// catches up.
///
/// Two rules drive this file:
///
/// 1. **Never hide a capability.** A surface that is not built yet is listed
///    as `Coming next`, and a surface the server cannot serve is listed as
///    disabled *with a precise reason* — never removed from the list.
/// 2. **Explain, do not crash.** Availability is data, so tests can assert it
///    without pumping a widget, and the pane simply renders it.
library;

import 'package:flutter/material.dart';

import '../theme/hermes_theme.dart';
import 'hermes_components.dart';

/// Whether a More entry can be opened right now, and why not when it cannot.
enum MoreEntryAvailability {
  /// Usable now.
  available,

  /// Native surface not implemented yet; listed so it stays discoverable.
  comingSoon,

  /// The connected Hermes instance cannot serve it (for example: no
  /// reachable dashboard). Disabled with an explanation, never hidden.
  unavailable,
}

/// One row of the More pane.
@immutable
class MoreEntry {
  /// Stable identifier used for routing and tests. Never localized.
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final MoreEntryAvailability availability;

  /// Why the entry is disabled. Required for [MoreEntryAvailability.unavailable]
  /// so the UI can always tell the user what to fix.
  final String? unavailableReason;

  const MoreEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.availability = MoreEntryAvailability.available,
    this.unavailableReason,
  }) : assert(
         availability != MoreEntryAvailability.unavailable ||
             unavailableReason != null,
         'A disabled entry must explain itself',
       );

  bool get isSelectable => availability == MoreEntryAvailability.available;
}

/// A titled group of [MoreEntry] rows.
@immutable
class MoreSection {
  final String title;
  final List<MoreEntry> entries;

  const MoreSection({required this.title, required this.entries});
}

const _dashboardRequired =
    '需要可达的 Hermes Dashboard。请检查此连接的地址、端口和凭据。';
const _gatewayAssetsRequired =
    '需要 Hermes Gateway 提供服务端资源索引。';
const _gatewayOrganizationRequired =
    '需要持久化排序、批量操作和撤销协议。';
const _gatewayAiFilingRequired =
    '需要带纠错功能的智能归档协议。';

/// Builds the More menu for the current connection.
///
/// [dashboardReachable] gates the surfaces served by the Hermes Dashboard.
/// Local device settings stay reachable regardless, so the user can always
/// repair a broken connection from inside the app.
List<MoreSection> buildMoreSections({required bool dashboardReachable}) {
  MoreEntryAvailability dashboardBacked() => dashboardReachable
      ? MoreEntryAvailability.available
      : MoreEntryAvailability.unavailable;
  String? dashboardReason() => dashboardReachable ? null : _dashboardRequired;

  return [
    MoreSection(
      title: '工作区',
      entries: [
        const MoreEntry(
          id: 'unassigned',
          title: '未分配对话',
          subtitle: '未关联到任何项目的对话',
          icon: Icons.inbox_outlined,
        ),
        const MoreEntry(
          id: 'archived-quick',
          title: '已归档快捷对话',
          subtitle: '查看或提升超过保留期的快捷对话',
          icon: Icons.archive_outlined,
        ),
        MoreEntry(
          id: 'files',
          title: '文件',
          subtitle: '浏览项目背后的文件夹',
          icon: Icons.folder_open_outlined,
          availability: dashboardBacked(),
          unavailableReason: dashboardReason(),
        ),
        const MoreEntry(
          id: 'assets',
          title: '资源',
          subtitle: '工件、附件与生成的媒体',
          icon: Icons.image_outlined,
          availability: MoreEntryAvailability.unavailable,
          unavailableReason: _gatewayAssetsRequired,
        ),
      ],
    ),
    MoreSection(
      title: '自动化',
      entries: [
        MoreEntry(
          id: 'cron',
          title: '定时任务',
          subtitle: '查看、创建和管理定时任务',
          icon: Icons.schedule_outlined,
          availability: dashboardBacked(),
          unavailableReason: dashboardReason(),
        ),
        MoreEntry(
          id: 'skills',
          title: '技能',
          subtitle: 'Hermes 掌握的能力',
          icon: Icons.auto_awesome_outlined,
          availability: dashboardBacked(),
          unavailableReason: dashboardReason(),
        ),
        MoreEntry(
          id: 'memory',
          title: '记忆',
          subtitle: 'Hermes 记住的持久事实',
          icon: Icons.psychology_outlined,
          availability: dashboardBacked(),
          unavailableReason: dashboardReason(),
        ),
      ],
    ),
    MoreSection(
      title: '系统',
      entries: [
        const MoreEntry(
          id: 'settings',
          title: '设置',
          subtitle: '连接、外观与设备偏好',
          icon: Icons.settings_outlined,
        ),
        MoreEntry(
          id: 'dashboard',
          title: '打开 Hermes Dashboard',
          subtitle: '原生界面未覆盖的功能，在网页 Dashboard 中查看',
          icon: Icons.open_in_new,
          availability: dashboardBacked(),
          unavailableReason: dashboardReason(),
        ),
      ],
    ),
  ];
}

/// Renders the More menu.
class MorePane extends StatelessWidget {
  final List<MoreSection> sections;
  final ValueChanged<MoreEntry> onSelect;

  const MorePane({required this.sections, required this.onSelect, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: HermesSpacing.xl),
      children: [
        for (final section in sections) ...[
          SectionHeader(title: section.title),
          for (final entry in section.entries)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                HermesSpacing.lg,
                0,
                HermesSpacing.lg,
                HermesSpacing.md,
              ),
              child: _MoreEntryCard(entry: entry, onSelect: onSelect),
            ),
        ],
      ],
    );
  }
}

class _MoreEntryCard extends StatelessWidget {
  final MoreEntry entry;
  final ValueChanged<MoreEntry> onSelect;

  const _MoreEntryCard({required this.entry, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final tokens = HermesTokens.of(context);
    final dimmed = !entry.isSelectable;
    final titleColor = dimmed ? tokens.muted : tokens.onSurface;

    return Semantics(
      button: entry.isSelectable,
      enabled: entry.isSelectable,
      label: entry.title,
      child: HermesCard(
        onTap: entry.isSelectable ? () => onSelect(entry) : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (dimmed ? tokens.muted : tokens.accent).withValues(
                  alpha: 0.14,
                ),
                borderRadius: BorderRadius.circular(HermesRadius.sm),
              ),
              child: Icon(
                entry.icon,
                size: 20,
                color: dimmed ? tokens.muted : tokens.accent,
              ),
            ),
            const SizedBox(width: HermesSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // A Wrap rather than a Row: at a large text scale the badge
                  // moves to its own line instead of overflowing the card.
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: HermesSpacing.sm,
                    runSpacing: HermesSpacing.xs,
                    children: [
                      Text(
                        entry.title,
                        style: tokens.typography.section.copyWith(
                          color: titleColor,
                        ),
                      ),
                      if (entry.availability ==
                          MoreEntryAvailability.comingSoon)
                        const StatusChip(
                          status: HermesStatus.idle,
                          label: 'Coming next',
                        ),
                    ],
                  ),
                  const SizedBox(height: HermesSpacing.xs),
                  Text(
                    entry.subtitle,
                    style: tokens.typography.body.copyWith(color: tokens.muted),
                  ),
                  if (entry.availability ==
                      MoreEntryAvailability.unavailable) ...[
                    const SizedBox(height: HermesSpacing.xs),
                    Text(
                      entry.unavailableReason!,
                      style: tokens.typography.label.copyWith(
                        color: tokens.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

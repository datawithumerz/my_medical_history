import 'package:flutter/material.dart';

import '../domain/records.dart';
import 'theme.dart';

const months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
String dateLabel(DateTime date) =>
    '${date.day} ${months[date.month - 1]} ${date.year}';
String monthLabel(DateTime date) => '${months[date.month - 1]} ${date.year}';
String dateTimeLabel(BuildContext context, DateTime date) =>
    '${dateLabel(date)} · ${TimeOfDay.fromDateTime(date).format(context)}';
String counted(int count, String singular, [String? plural]) =>
    '$count ${count == 1 ? singular : plural ?? '${singular}s'}';
String initials(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((s) => s.isNotEmpty && !['dr', 'dr.'].contains(s.toLowerCase()))
      .toList();
  if (words.isEmpty) return '?';
  return (words.first.characters.first +
          (words.length > 1 ? words.last.characters.first : ''))
      .toUpperCase();
}

class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children, this.controller});
  final List<Widget> children;
  final ScrollController? controller;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: children,
      ),
    ),
  );
}

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.color});
  final Widget child;
  final Color? color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
    decoration: BoxDecoration(
      color: color,
      border: const Border(bottom: BorderSide(color: borderColor)),
    ),
    child: child,
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.action});
  final String title;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 22, bottom: 8),
    child: JournalHeading(title, action: action, small: true),
  );
}

class JournalHeading extends StatelessWidget {
  const JournalHeading(
    this.title, {
    super.key,
    this.action,
    this.small = false,
  });
  final String title;
  final Widget? action;
  final bool small;
  @override
  Widget build(BuildContext context) {
    final label = Text(
      title,
      style: small
          ? Theme.of(context).textTheme.titleMedium
          : Theme.of(context).textTheme.titleLarge,
    );
    if (action == null) return label;
    if (MediaQuery.textScalerOf(context).scale(1) > 1.3) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          label,
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerLeft, child: action),
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: label),
        const SizedBox(width: 8),
        Flexible(child: action!),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 28),
    child: Column(
      children: [
        Icon(icon, size: 30, color: journalTeal),
        const SizedBox(height: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center),
        if (action != null) ...[const SizedBox(height: 16), action!],
      ],
    ),
  );
}

class InfoPill extends StatelessWidget {
  const InfoPill(this.text, {super.key, this.icon});
  final String text;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: mutedSurface,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 15, color: journalTeal),
          const SizedBox(width: 5),
        ],
        Flexible(child: Text(text, style: const TextStyle(fontSize: 12))),
      ],
    ),
  );
}

class DoctorCard extends StatelessWidget {
  const DoctorCard({
    super.key,
    required this.doctor,
    required this.visitCount,
    required this.onOpen,
  });
  final Doctor doctor;
  final int visitCount;
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        leading: CircleAvatar(
          backgroundColor: mutedSurface,
          foregroundColor: journalTeal,
          child: Text(
            initials(doctor.name),
            textScaler: TextScaler.noScaling,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        title: Text(
          doctor.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          [
            if (doctor.specialty.isNotEmpty) doctor.specialty,
            if (doctor.facility.isNotEmpty) doctor.facility,
            counted(visitCount, 'visit'),
          ].join(' · '),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onOpen,
      ),
      const Divider(),
    ],
  );
}

class VisitCard extends StatelessWidget {
  const VisitCard({
    super.key,
    required this.visit,
    required this.doctorName,
    required this.onOpen,
    this.attachmentCount = 0,
  });
  final Visit visit;
  final String doctorName;
  final VoidCallback onOpen;
  final int attachmentCount;
  @override
  Widget build(BuildContext context) {
    final dateWidth = MediaQuery.textScalerOf(context)
        .scale(56)
        .clamp(56.0, 90.0);
    return Semantics(
      button: true,
      label: dateLabel(visit.date),
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: dateWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${visit.date.day}'.padLeft(2, '0'),
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w600,
                        color: journalTeal,
                      ),
                    ),
                    Text(
                      months[visit.date.month - 1]
                          .substring(0, 3)
                          .toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: 1,
                        color: journalTeal,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(left: 14, bottom: 14),
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: borderColor, width: 2),
                      bottom: BorderSide(color: borderColor),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visit.reason,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(doctorName),
                      if (visit.facility.isNotEmpty)
                        Text(
                          visit.facility,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      const SizedBox(height: 6),
                      Text(
                        TimeOfDay.fromDateTime(visit.date).format(context),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (visit.medicines.isNotEmpty ||
                          visit.tests.isNotEmpty ||
                          attachmentCount > 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          [
                            if (visit.medicines.isNotEmpty)
                              counted(visit.medicines.length, 'medicine'),
                            if (visit.tests.isNotEmpty)
                              counted(visit.tests.length, 'test'),
                            if (attachmentCount > 0)
                              counted(attachmentCount, 'file'),
                          ].join(' · '),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, size: 18, color: journalTeal),
            ],
          ),
        ),
      ),
    );
  }
}

void showMessage(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String action,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              action,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    ) ??
    false;

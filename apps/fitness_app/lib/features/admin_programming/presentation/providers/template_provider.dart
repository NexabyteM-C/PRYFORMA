import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../organizations/presentation/providers/organization_provider.dart';
import 'programming_provider.dart';

/// Lightweight view model for a reusable program template.
class ProgramTemplate {
  const ProgramTemplate({
    required this.id,
    required this.name,
    this.description,
    this.focusTags = const [],
  });

  final String id;
  final String name;
  final String? description;
  final List<String> focusTags;

  factory ProgramTemplate.fromJson(Map<String, dynamic> json) {
    return ProgramTemplate(
      id: json['id'] as String,
      name: (json['name'] ?? json['title'] ?? 'Plantilla') as String,
      description: json['description'] as String?,
      focusTags:
          (json['focus_tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }
}

final templateListProvider = FutureProvider<List<ProgramTemplate>>((ref) async {
  final ds = ref.watch(programmingDatasourceProvider);
  final org = ref.watch(resolvedAdminOrgProvider);
  if (org == null) return [];
  final rows = await ds.listTemplates(org.id);
  return rows.map(ProgramTemplate.fromJson).toList();
});

/// Full structure (blocks + exercises) for a single template, used to preview
/// a template before applying it.
final templateWithBlocksProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, templateId) async {
      final ds = ref.watch(programmingDatasourceProvider);
      return ds.getTemplateWithBlocks(templateId);
    });

/// Action helper: applies [templateId] onto [date] and returns the new
/// program id. Exposed as a provider so screens can call it via `ref.read`.
class ApplyTemplateAction {
  ApplyTemplateAction(this._ref);
  final Ref _ref;

  Future<String> call(String templateId, DateTime date) async {
    final ds = _ref.read(programmingDatasourceProvider);
    final org = _ref.read(resolvedAdminOrgProvider);
    if (org == null) {
      throw Exception('Sin organización seleccionada');
    }
    return ds.applyTemplate(org.id, templateId, date);
  }
}

final applyTemplateActionProvider = Provider<ApplyTemplateAction>(
  (ref) => ApplyTemplateAction(ref),
);

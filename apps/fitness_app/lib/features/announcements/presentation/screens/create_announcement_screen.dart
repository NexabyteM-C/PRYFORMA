import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/fit_back_button.dart';
import '../../../organizations/presentation/providers/organization_provider.dart';
import '../providers/announcement_provider.dart';

class CreateAnnouncementScreen extends ConsumerStatefulWidget {
  const CreateAnnouncementScreen({super.key, this.announcementId});

  /// When set, the screen edits that announcement instead of creating one.
  final String? announcementId;

  @override
  ConsumerState<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState
    extends ConsumerState<CreateAnnouncementScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _pinned = false;
  bool _saving = false;
  DateTime? _originalPublishedAt;

  bool get _isEdit => widget.announcementId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final existing = ref
          .read(announcementListProvider)
          .valueOrNull
          ?.where((a) => a.id == widget.announcementId)
          .firstOrNull;
      if (existing != null) {
        _titleController.text = existing.title;
        _bodyController.text = existing.body;
        _pinned = existing.pinned;
        _originalPublishedAt = existing.publishedAt;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  Future<void> _save({required bool publishNow}) async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty) {
      _snack('El título es obligatorio', isError: true);
      return;
    }
    if (body.isEmpty) {
      _snack('El mensaje es obligatorio', isError: true);
      return;
    }
    final org = ref.read(resolvedAdminOrgProvider);
    if (org == null) {
      _snack('Sin box seleccionado', isError: true);
      return;
    }
    // On edit, publishing keeps the original publish time if already published.
    final publishedAt = publishNow
        ? (_originalPublishedAt ?? DateTime.now()).toIso8601String()
        : null;

    setState(() => _saving = true);
    try {
      final ds = ref.read(announcementDatasourceProvider);
      if (_isEdit) {
        await ds.update(widget.announcementId!, {
          'title': title,
          'body': body,
          'pinned': _pinned,
          'published_at': publishedAt,
        });
      } else {
        await ds.create(org.id, {
          'title': title,
          'body': body,
          'pinned': _pinned,
          'published_at': publishedAt,
        });
      }
      ref.invalidate(announcementListProvider);
      _snack(_isEdit
          ? (publishNow ? 'Comunicado actualizado' : 'Borrador guardado')
          : (publishNow ? 'Comunicado publicado' : 'Borrador guardado'));
      if (mounted) context.pop();
    } catch (e) {
      _snack('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          narrow ? 12 : 28,
          narrow ? 12 : 28,
          narrow ? 16 : 28,
          28,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const FitBackButton(fallbackLocation: '/admin/announcements'),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isEdit ? 'Editar comunicado' : 'Nuevo comunicado',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      hintText: 'Título del comunicado',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _bodyController,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Mensaje',
                      hintText: 'Escribe el contenido...',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.push_pin_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Fijar comunicado',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Switch(
                          value: _pinned,
                          activeThumbColor: AppColors.primary,
                          onChanged: (v) => setState(() => _pinned = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_saving)
                    const Center(child: CircularProgressIndicator())
                  else
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _save(publishNow: false),
                            child: const Text('Guardar borrador'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () => _save(publishNow: true),
                              child: Text(
                                _isEdit ? 'Guardar y publicar' : 'Publicar comunicado',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Token warna admin web. Satu sumber agar semua halaman konsisten.
class AdminColors {
  static const primary = Color(0xFFB83B7E);
  static const primaryDark = Color(0xFF8E2C62);
  static const primarySoft = Color(0xFFF8EAF2);
  static const sidebarTop = Color(0xFF4A1534);
  static const sidebarBottom = Color(0xFF7A2556);

  static const background = Color(0xFFF6F4F8);
  static const surface = Colors.white;
  static const border = Color(0xFFEAE5EE);
  static const divider = Color(0xFFF1EDF4);

  static const text = Color(0xFF1E1A24);
  static const textMuted = Color(0xFF6D6578);
  static const textSubtle = Color(0xFF9C95A6);

  static const pasien = primary;
  static const keluarga = Color(0xFF2E8B6E);
  static const info = Color(0xFF3B6FD8);
  static const warning = Color(0xFFD9822B);
  static const danger = Color(0xFFD14343);
  static const success = Color(0xFF2E8B57);
}

/// Tema khusus admin web, diturunkan dari tema aplikasi.
ThemeData buildAdminTheme(ThemeData base) {
  final radius = BorderRadius.circular(10);
  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: c, width: w),
      );

  return base.copyWith(
    scaffoldBackgroundColor: AdminColors.background,
    colorScheme: base.colorScheme.copyWith(
      primary: AdminColors.primary,
      surface: AdminColors.surface,
      surfaceTint: Colors.transparent,
    ),
    dividerTheme: const DividerThemeData(
        color: AdminColors.divider, thickness: 1, space: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      labelStyle: const TextStyle(color: AdminColors.textMuted),
      hintStyle: const TextStyle(color: AdminColors.textSubtle),
      prefixIconColor: AdminColors.textSubtle,
      suffixIconColor: AdminColors.textSubtle,
      border: border(AdminColors.border),
      enabledBorder: border(AdminColors.border),
      disabledBorder: border(AdminColors.divider),
      focusedBorder: border(AdminColors.primary, 1.5),
      errorBorder: border(AdminColors.danger),
      focusedErrorBorder: border(AdminColors.danger, 1.5),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: radius),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: radius),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AdminColors.text,
        side: const BorderSide(color: AdminColors.border),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: radius),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AdminColors.primary,
        shape: RoundedRectangleBorder(borderRadius: radius),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AdminColors.text,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AdminColors.border),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AdminColors.border),
      ),
      textStyle: const TextStyle(fontSize: 14, color: AdminColors.text),
    ),
    dataTableTheme: const DataTableThemeData(
      headingRowColor: WidgetStatePropertyAll(Color(0xFFFAF8FB)),
      headingTextStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AdminColors.textMuted,
        letterSpacing: 0.3,
      ),
      dataTextStyle: TextStyle(fontSize: 14, color: AdminColors.text),
      dividerThickness: 1,
      headingRowHeight: 48,
      dataRowMinHeight: 60,
      dataRowMaxHeight: 68,
      horizontalMargin: 20,
      columnSpacing: 28,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AdminColors.text,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      width: 420,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AdminColors.text.withOpacity(0.92),
        borderRadius: BorderRadius.circular(6),
      ),
      textStyle: const TextStyle(color: Colors.white, fontSize: 12),
      waitDuration: const Duration(milliseconds: 400),
    ),
    progressIndicatorTheme:
        const ProgressIndicatorThemeData(color: AdminColors.primary),
  );
}

/// Kerangka halaman admin: judul, subjudul, tombol aksi, lalu isi.
class AdminPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget child;

  /// true → isi digulir bersama header; false → isi mengisi sisa tinggi
  /// (dipakai untuk daftar/tabel yang punya scroll sendiri).
  final bool scrollable;

  const AdminPage({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    required this.child,
    this.scrollable = true,
  });

  static EdgeInsets paddingFor(double width) => width < 600
      ? const EdgeInsets.fromLTRB(16, 20, 16, 16)
      : const EdgeInsets.fromLTRB(32, 28, 32, 24);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final pad = paddingFor(c.maxWidth);
      final header = AdminPageHeader(
          title: title, subtitle: subtitle, actions: actions);
      if (scrollable) {
        return SingleChildScrollView(
          padding: pad,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [header, const SizedBox(height: 24), child],
          ),
        );
      }
      return Padding(
        padding: pad,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [header, const SizedBox(height: 20), Expanded(child: child)],
        ),
      );
    });
  }
}

class AdminPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;

  const AdminPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AdminColors.text,
            height: 1.2,
            letterSpacing: -0.3,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: const TextStyle(
                fontSize: 14, color: AdminColors.textMuted, height: 1.4),
          ),
        ],
      ],
    );
    if (actions.isEmpty) return titleBlock;
    return LayoutBuilder(builder: (context, c) {
      final actionRow = Wrap(spacing: 10, runSpacing: 10, children: actions);
      if (c.maxWidth < 720) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [titleBlock, const SizedBox(height: 16), actionRow],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: titleBlock),
          const SizedBox(width: 16),
          actionRow,
        ],
      );
    });
  }
}

/// Kartu putih dengan garis tipis dan bayangan halus.
class AdminCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Clip clip;

  const AdminCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.clip = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: clip,
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AdminColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A1534).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}

/// Judul kecil di dalam kartu.
class AdminCardTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const AdminCardTitle(this.title, {super.key, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AdminColors.text)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!,
                    style: const TextStyle(
                        fontSize: 13, color: AdminColors.textMuted)),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Label kecil berwarna, mis. role atau status.
class AdminBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const AdminBadge(this.text, {super.key, required this.color, this.icon});

  factory AdminBadge.role(String role) {
    switch (role) {
      case 'pasien':
        return const AdminBadge('Pasien', color: AdminColors.pasien);
      case 'keluarga':
        return const AdminBadge('Keluarga', color: AdminColors.keluarga);
      case 'superadmin':
        return const AdminBadge('Super Admin', color: AdminColors.primaryDark);
      case 'admin':
        return const AdminBadge('Admin', color: AdminColors.info);
    }
    return AdminBadge(role, color: AdminColors.textMuted);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Avatar bulat berisi inisial nama.
class AdminAvatar extends StatelessWidget {
  final String name;
  final Color color;
  final double size;

  const AdminAvatar(this.name,
      {super.key, this.color = AdminColors.primary, this.size = 36});

  static String initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Text(
        initials(name),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}

/// Tombol ikon kecil dengan tooltip untuk kolom aksi.
class AdminIconAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onPressed;

  const AdminIconAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color = AdminColors.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        hoverColor: color.withOpacity(0.08),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 19, color: color),
        ),
      ),
    );
  }
}

/// Tampilan kosong yang ramah.
class AdminEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;

  const AdminEmptyState(
      {super.key, required this.icon, required this.title, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AdminColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: AdminColors.primary),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.text)),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AdminColors.textMuted)),
            ],
          ],
        ),
      ),
    );
  }
}

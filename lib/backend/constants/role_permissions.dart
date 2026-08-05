// =============================================================
// FILE   : lib/backend/constants/role_permissions.dart
// TEKNIK : Table-Driven Construction
// -------------------------------------------------------------
// FUNGSI :
//   Mendefinisikan tabel permission berbasis Map<String, List<String>>.
//   Setiap role (super_admin, admin_lapangan, kontraktor, client, aph)
//   dipetakan ke daftar aksi yang diizinkan.
//   Digunakan oleh permission_checker.dart untuk validasi hak akses.
//
// STRUKTUR TABEL :
//   const Map<String, List<String>> rolePermissions = {
//     'super_admin'    : ['read','write','delete','validate','grant_access'],
//     'admin_lapangan' : ['read','write','upload_photo'],
//     'kontraktor'     : ['read'],
//     'client'         : ['read'],
//     'aph'            : ['read'], // hanya setelah izin super_admin
//   };
//
// CATATAN DEFENSIVE :
//   Jangan lookup role yang tidak ada di Map — tambahkan guard
//   di permission_checker.dart sebelum akses Map ini.
// =============================================================

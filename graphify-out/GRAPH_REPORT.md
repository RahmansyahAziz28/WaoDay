# Graph Report - waoday  (2026-09-16)

## Corpus Check
- 105 files · ~63,723 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1198 nodes · 1535 edges · 80 communities (70 shown, 10 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 18 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `ece4ec6e`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Win32Window
- AppDelegate
- nilai_sub_bab.dart
- dummy_data.dart
- app_button.dart
- login_screen.dart
- my_application.cc
- app_input.dart
- buat_token_ujian_screen.dart
- auth_user.dart
- ../data/dummy_data.dart
- api_client.dart
- wWinMain
- widgets.dart
- List
- StatelessWidget
- manifest.json
- State
- main.dart
- What You Must Do When Invoked
- confirm_dialog.dart
- auth_401_test.dart
- package:flutter/material.dart
- detail_kelas_screen.dart
- info_row.dart
- guru.dart
- MainActivity.kt
- guru_dashboard.dart
- String?
- api_config.dart
- admin_service.dart
- admin_dashboard_screen.dart
- kelas_service.dart
- game_token.dart
- manajemen_guru_screen.dart
- auth_service.dart
- forgot_password_screen.dart
- caveman/SKILL.md
- guru_service.dart
- manajemen_admin_sekolah_screen.dart
- kelas_saya_screen.dart
- guru_dashboard_screen.dart
- graphify reference: extra exports and benchmark
- app_card.dart
- empty_state.dart
- siswa.dart
- search_bar.dart
- graphify reference: query, path, explain
- graphify reference: add a URL and watch a folder
- graphify reference: commit hook and native CLAUDE.md integration
- graphify reference: incremental update and cluster-only
- graphify reference: GitHub clone and cross-repo merge
- graphify reference: transcribe video and audio
- waoday
- rules/graphify.md
- extraction-spec.md
- workflows/graphify.md
- LaunchImage.imageset/README.md
- daftar_siswa_screen.dart
- navigation_service.dart
- superadmin/manajemen_sekolah_screen.dart
- admin_sekolah.dart
- admin_sekolah_service.dart
- rekap_nilai_ujian_screen.dart
- MaterialPageRoute
- manajemen_kelas_screen.dart
- kelas.dart
- nilai_sub_bab_service.dart
- @email
- @sekolah
- admin/manajemen_sekolah_screen.dart
- game_token_service.dart
- superadmin_home.dart
- register_screen.dart
- models.dart
- StatefulWidget

## God Nodes (most connected - your core abstractions)
1. `Win32Window` - 22 edges
2. `MessageHandler` - 12 edges
3. `What You Must Do When Invoked` - 12 edges
4. `FlutterWindow` - 10 edges
5. `Create` - 10 edges
6. `WndProc` - 10 edges
7. `/graphify` - 10 edges
8. `MessageHandler` - 9 edges
9. `graphify reference: extra exports and benchmark` - 8 edges
10. `_MyApplication` - 7 edges

## Surprising Connections (you probably didn't know these)
- `wWinMain()` --calls--> `CreateAndAttachConsole()`  [INFERRED]
  windows/runner/main.cpp → windows/runner/utils.cpp
- `Win32Window::Win32Window()` --calls--> `Destroy`  [INFERRED]
  windows/runner/win32_window.cpp → windows/runner/win32_window.h
- `my_application_activate()` --calls--> `fl_register_plugins()`  [INFERRED]
  linux/runner/my_application.cc → linux/flutter/generated_plugin_registrant.cc
- `main()` --calls--> `my_application_new()`  [INFERRED]
  linux/runner/main.cc → linux/runner/my_application.cc
- `OnCreate` --calls--> `RegisterPlugins()`  [INFERRED]
  windows/runner/flutter_window.h → windows/flutter/generated_plugin_registrant.cc

## Import Cycles
- None detected.

## Communities (80 total, 10 thin omitted)

### Community 0 - "Win32Window"
Cohesion: 0.06
Nodes (53): PluginRegistry, Point, RECT, Size, unique_ptr, RegisterPlugins(), DartProject, HWND (+45 more)

### Community 1 - "AppDelegate"
Cohesion: 0.06
Nodes (27): Any, Cocoa, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterMacOS, FlutterPluginRegistry (+19 more)

### Community 2 - "nilai_sub_bab.dart"
Cohesion: 0.03
Nodes (65): belumMengerjakan, belumTuntas, benar, data, dimainkanAt, fromJson, guru, id (+57 more)

### Community 3 - "dummy_data.dart"
Cohesion: 0.08
Nodes (25): ChangeNotifier, AppData, clearAuth, currentGuru, currentRole, currentUser, deleteSiswa, guruDashboardData (+17 more)

### Community 4 - "app_button.dart"
Cohesion: 0.18
Nodes (10): bool get, AppButtonVariant, build, fullWidth, icon, _isFilled, isLoading, label (+2 more)

### Community 5 - "login_screen.dart"
Cohesion: 0.08
Nodes (26): ../admin/admin_home.dart, ../guru/guru_home.dart, build, createState, dispose, _emailController, _emailError, _errorMessage (+18 more)

### Community 6 - "my_application.cc"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 7 - "app_input.dart"
Cohesion: 0.14
Nodes (13): build, controller, enabled, errorText, hint, icon, keyboardType, label (+5 more)

### Community 8 - "buat_token_ujian_screen.dart"
Cohesion: 0.08
Nodes (24): DateTime?, int get, _berlakuSampai, BuatTokenUjianScreen, _BuatTokenUjianScreenState, build, createState, dispose (+16 more)

### Community 9 - "auth_user.dart"
Cohesion: 0.05
Nodes (35): int?, ApiResponse, AuthData, data, email, expiresAt, expiresIn, fromJson (+27 more)

### Community 10 - "../data/dummy_data.dart"
Cohesion: 0.22
Nodes (9): ../auth/login_screen.dart, ../data/dummy_data.dart, build, _handleLogout, build, _handleLogout, _handleRefresh, ../../services/guru_service.dart (+1 more)

### Community 11 - "api_client.dart"
Cohesion: 0.12
Nodes (15): Client, dart:async, ApiClient, _buildHeaders, _client, defaultTimeout, delete, instance (+7 more)

### Community 12 - "wWinMain"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, vector, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 13 - "widgets.dart"
Cohesion: 0.20
Nodes (9): app_button.dart, app_card.dart, app_input.dart, avatar.dart, confirm_dialog.dart, empty_state.dart, info_row.dart, loading_state.dart (+1 more)

### Community 14 - "List"
Cohesion: 0.07
Nodes (27): alamat, count, createdAt, data, fromJson, id, limit, message (+19 more)

### Community 15 - "StatelessWidget"
Cohesion: 0.25
Nodes (8): AkademikApp, ProfilAdminScreen, _StatCard, ProfilGuruScreen, AppButton, AppCard, AppInput, StatelessWidget

### Community 16 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 17 - "State"
Cohesion: 0.67
Nodes (4): _ManajemenSekolahScreenState, _ManajemenSekolahScreenState, ManajemenSekolahScreen, State

### Community 18 - "main.dart"
Cohesion: 0.18
Nodes (10): build, main, screens/admin/admin_home.dart, screens/auth/forgot_password_screen.dart, ../screens/auth/login_screen.dart, screens/auth/register_screen.dart, screens/auth/splash_screen.dart, screens/guru/guru_home.dart (+2 more)

### Community 19 - "What You Must Do When Invoked"
Cohesion: 0.08
Nodes (24): For /graphify add and --watch, For /graphify query, For the commit hook and native CLAUDE.md integration, For --update and --cluster-only, /graphify, Honesty Rules, Interpreter guard for subcommands, Part A - Structural extraction for code files (+16 more)

### Community 20 - "confirm_dialog.dart"
Cohesion: 0.22
Nodes (8): cancelLabel, confirmLabel, false, isDangerous, result, showConfirmDialog, required String message,
  String, return result ??

### Community 21 - "auth_401_test.dart"
Cohesion: 0.15
Nodes (13): package:flutter_test/flutter_test.dart, package:shared_preferences/shared_preferences.dart, package:waoday/data/dummy_data.dart, package:waoday/main.dart, package:waoday/models/admin_sekolah.dart, package:waoday/models/auth_user.dart, package:waoday/models/sekolah.dart, package:waoday/screens/auth/login_screen.dart (+5 more)

### Community 22 - "package:flutter/material.dart"
Cohesion: 0.17
Nodes (11): Color?, AppAvatar, backgroundColor, build, name, size, build, LoadingState (+3 more)

### Community 23 - "detail_kelas_screen.dart"
Cohesion: 0.10
Nodes (21): buat_token_ujian_screen.dart, _buildTokenInfoChip, createState, _currentKelas, DetailKelasScreen, _DetailKelasScreenState, _downloadingTokenId, _errorMessage (+13 more)

### Community 24 - "info_row.dart"
Cohesion: 0.29
Nodes (6): IconData, build, icon, InfoRow, label, value

### Community 25 - "guru.dart"
Cohesion: 0.09
Nodes (22): count, createdAt, SekolahInfo, data, fromJson, id, kelasList, kodeKelas (+14 more)

### Community 26 - "MainActivity.kt"
Cohesion: 0.60
Nodes (3): MainActivity, FlutterActivity, RenderMode

### Community 30 - "guru_dashboard.dart"
Cohesion: 0.08
Nodes (23): alamat, createdAt, fromJson, GuruKelasItem, GuruProfil, GuruStatistik, id, kelas (+15 more)

### Community 33 - "api_config.dart"
Cohesion: 0.06
Nodes (32): adminDetailUri, adminQueryUri, adminUri, ApiConfig, baseUrl, dashboardGuruEndpoint, dashboardGuruUri, gameTokenExportExcelUri (+24 more)

### Community 34 - "admin_service.dart"
Cohesion: 0.12
Nodes (16): Guru, AdminService, createGuru, createSekolah, deleteGuru, deleteSekolah, getGuruDetail, getGuruList (+8 more)

### Community 35 - "admin_dashboard_screen.dart"
Cohesion: 0.13
Nodes (15): AdminDashboardScreen, _AdminDashboardScreenState, build, _buildStatCard, createState, _errorMessage, _fetchDashboardData, _guruList (+7 more)

### Community 36 - "kelas_service.dart"
Cohesion: 0.12
Nodes (15): ../config/api_config.dart, createKelas, createSiswa, deleteKelas, deleteSiswa, getKelas, getKelasDetail, getSiswaInKelas (+7 more)

### Community 37 - "game_token.dart"
Cohesion: 0.05
Nodes (40): acak, aktif, belumTuntas, benar, createdAt, dimainkanAt, fromJson, GameTokenItem (+32 more)

### Community 38 - "manajemen_guru_screen.dart"
Cohesion: 0.08
Nodes (25): build, createState, _currentPage, dispose, _errorMessage, _guruList, _handleDeleteGuru, _handleLogout (+17 more)

### Community 39 - "auth_service.dart"
Cohesion: 0.12
Nodes (16): AuthService, _clearSession, getToken, handleSessionExpired, instance, _isHandlingSessionExpired, _keyRefreshToken, _keyToken (+8 more)

### Community 40 - "forgot_password_screen.dart"
Cohesion: 0.05
Nodes (39): guru_dashboard_screen.dart, kelas_saya_screen.dart, build, _buildForm, _buildSuccess, createState, dispose, _emailController (+31 more)

### Community 41 - "caveman/SKILL.md"
Cohesion: 0.17
Nodes (10): caveman, Example output, How to invoke, See also, What it does, Auto-Clarity, Boundaries, Intensity (+2 more)

### Community 42 - "guru_service.dart"
Cohesion: 0.20
Nodes (9): auth_service.dart, dart:convert, GuruDashboardData, getDashboardData, GuruService, instance, ../models/guru_dashboard.dart, package:flutter/foundation.dart (+1 more)

### Community 43 - "manajemen_admin_sekolah_screen.dart"
Cohesion: 0.08
Nodes (25): class, _admins, _adminService, build, _buildAdminCard, createState, didUpdateWidget, dispose (+17 more)

### Community 44 - "kelas_saya_screen.dart"
Cohesion: 0.20
Nodes (10): _apiKelasList, createState, _errorMessage, _handleRefresh, initState, _isLoading, KelasSayaScreen, _KelasSayaScreenState (+2 more)

### Community 45 - "guru_dashboard_screen.dart"
Cohesion: 0.17
Nodes (12): daftar_siswa_screen.dart, detail_kelas_screen.dart, createState, _errorMessage, _fetchDashboard, GuruDashboardScreen, _GuruDashboardScreenState, icon (+4 more)

### Community 46 - "graphify reference: extra exports and benchmark"
Cohesion: 0.22
Nodes (8): graphify reference: extra exports and benchmark, Step 6b - Wiki (only if --wiki flag), Step 7 - Neo4j export (only if --neo4j or --neo4j-push flag), Step 7a - FalkorDB export (only if --falkordb or --falkordb-push flag), Step 7b - SVG export (only if --svg flag), Step 7c - GraphML export (only if --graphml flag), Step 7d - MCP server (only if --mcp flag), Step 8 - Token reduction benchmark (only if total_words > 5000)

### Community 47 - "app_card.dart"
Cohesion: 0.22
Nodes (8): EdgeInsetsGeometry, build, child, onLongPress, onTap, padding, VoidCallback?, Widget?

### Community 48 - "empty_state.dart"
Cohesion: 0.25
Nodes (7): actionLabel, build, EmptyState, icon, message, onAction, title

### Community 49 - "siswa.dart"
Cohesion: 0.15
Nodes (12): fromJson, id, kelas, kelasId, nama, nis, pivotId, sekolah (+4 more)

### Community 50 - "search_bar.dart"
Cohesion: 0.25
Nodes (7): AppSearchBar, build, controller, hint, onChanged, TextEditingController, ValueChanged

### Community 51 - "graphify reference: query, path, explain"
Cohesion: 0.33
Nodes (5): For /graphify explain, For /graphify path, graphify reference: query, path, explain, Step 0 — Constrained query expansion (REQUIRED before traversal), Step 1 — Traversal

### Community 52 - "graphify reference: add a URL and watch a folder"
Cohesion: 0.50
Nodes (3): For /graphify add, For --watch, graphify reference: add a URL and watch a folder

### Community 53 - "graphify reference: commit hook and native CLAUDE.md integration"
Cohesion: 0.50
Nodes (3): For git commit hook, For native CLAUDE.md integration, graphify reference: commit hook and native CLAUDE.md integration

### Community 54 - "graphify reference: incremental update and cluster-only"
Cohesion: 0.50
Nodes (3): For --cluster-only, For --update (incremental re-extraction), graphify reference: incremental update and cluster-only

### Community 62 - "daftar_siswa_screen.dart"
Cohesion: 0.17
Nodes (12): Kelas, build, createState, DaftarSiswaScreen, _DaftarSiswaScreenState, dispose, _handleDelete, kelas (+4 more)

### Community 63 - "navigation_service.dart"
Cohesion: 0.33
Nodes (5): GlobalKey, appMessengerKey, appNavigatorKey, NavigatorState, ScaffoldMessengerState

### Community 64 - "superadmin/manajemen_sekolah_screen.dart"
Cohesion: 0.08
Nodes (24): FormState, build, _buildSekolahCard, createState, _currentPage, dispose, _errorMessage, _handleDeleteSekolah (+16 more)

### Community 65 - "admin_sekolah.dart"
Cohesion: 0.08
Nodes (24): copyWith, count, createdAt, data, email, fromJson, id, isActive (+16 more)

### Community 66 - "admin_sekolah_service.dart"
Cohesion: 0.14
Nodes (13): api_client.dart, AdminSekolah, _admins, allAdmins, createAdmin, deleteAdmin, getAdminList, _getToken (+5 more)

### Community 67 - "rekap_nilai_ujian_screen.dart"
Cohesion: 0.09
Nodes (22): build, _buildBody, _buildStatCard, createState, _data, _downloadExcel, _errorMessage, _expandedStudentIds (+14 more)

### Community 68 - "MaterialPageRoute"
Cohesion: 0.40
Nodes (5): build, _openBuatToken, build, build, MaterialPageRoute

### Community 69 - "manajemen_kelas_screen.dart"
Cohesion: 0.11
Nodes (18): build, createState, dispose, _errorMessage, _guruList, _handleDeleteKelas, _handleLogout, initState (+10 more)

### Community 70 - "kelas.dart"
Cohesion: 0.12
Nodes (16): copyWith, daftarSiswa, _extractTingkat, fromJson, guruId, guruPengampu, id, jumlahSiswa (+8 more)

### Community 71 - "nilai_sub_bab_service.dart"
Cohesion: 0.14
Nodes (13): File, RaporNilaiSiswaResponse, RekapNilaiKelasResponse, downloadExportExcelToken, getNilaiSubBabKelas, getNilaiSubBabSiswa, _getToken, instance (+5 more)

### Community 74 - "admin/manajemen_sekolah_screen.dart"
Cohesion: 0.13
Nodes (14): build, createState, dispose, _errorMessage, _handleDeleteSekolah, initState, _isLoading, _loadSekolah (+6 more)

### Community 75 - "game_token_service.dart"
Cohesion: 0.15
Nodes (12): dart:io, RekapNilaiData, createGameToken, GameTokenService, getMateri, getRekapNilai, _getToken, getTokensByKelas (+4 more)

### Community 76 - "superadmin_home.dart"
Cohesion: 0.17
Nodes (12): build, createState, _currentIndex, _filterSekolahIdForAdmin, _handleLogout, _onSelectSekolahForAdmin, routeName, SuperAdminHome (+4 more)

### Community 77 - "register_screen.dart"
Cohesion: 0.11
Nodes (19): build, _confirmController, createState, dispose, _errors, _handleRegister, _isLoading, _kelasController (+11 more)

### Community 78 - "models.dart"
Cohesion: 0.18
Nodes (10): admin_sekolah.dart, auth_user.dart, game_token.dart, guru.dart, guru_dashboard.dart, kelas.dart, materi.dart, nilai_sub_bab.dart (+2 more)

### Community 79 - "StatefulWidget"
Cohesion: 0.67
Nodes (3): ManajemenSekolahScreen, ManajemenSekolahScreen, StatefulWidget

## Knowledge Gaps
- **766 isolated node(s):** `ApiConfig`, `baseUrl`, `loginEndpoint`, `logoutEndpoint`, `dashboardGuruEndpoint` (+761 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **10 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AuthData` connect `auth_user.dart` to `auth_service.dart`?**
  _High betweenness centrality (0.008) - this node is a cross-community bridge._
- **Why does `RekapNilaiData` connect `game_token_service.dart` to `rekap_nilai_ujian_screen.dart`, `game_token.dart`?**
  _High betweenness centrality (0.008) - this node is a cross-community bridge._
- **Why does `Kelas` connect `daftar_siswa_screen.dart` to `buat_token_ujian_screen.dart`, `kelas_service.dart`, `kelas.dart`, `detail_kelas_screen.dart`?**
  _High betweenness centrality (0.006) - this node is a cross-community bridge._
- **What connects `ApiConfig`, `baseUrl`, `loginEndpoint` to the rest of the system?**
  _766 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Win32Window` be split into smaller, more focused modules?**
  _Cohesion score 0.0597567424643046 - nodes in this community are weakly interconnected._
- **Should `AppDelegate` be split into smaller, more focused modules?**
  _Cohesion score 0.05975609756097561 - nodes in this community are weakly interconnected._
- **Should `nilai_sub_bab.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.030303030303030304 - nodes in this community are weakly interconnected._
# Graph Report - Smart-Spilter  (2026-10-28)

## Corpus Check
- 71 files · ~138,529 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 662 nodes · 822 edges · 52 communities (43 shown, 9 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `3b6b0897`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]
- [[_COMMUNITY_Community 22|Community 22]]
- [[_COMMUNITY_Community 23|Community 23]]
- [[_COMMUNITY_Community 24|Community 24]]
- [[_COMMUNITY_Community 25|Community 25]]
- [[_COMMUNITY_Community 26|Community 26]]
- [[_COMMUNITY_Community 27|Community 27]]
- [[_COMMUNITY_Community 28|Community 28]]
- [[_COMMUNITY_Community 29|Community 29]]
- [[_COMMUNITY_Community 30|Community 30]]
- [[_COMMUNITY_Community 31|Community 31]]
- [[_COMMUNITY_Community 32|Community 32]]
- [[_COMMUNITY_Community 33|Community 33]]
- [[_COMMUNITY_Community 34|Community 34]]
- [[_COMMUNITY_Community 35|Community 35]]
- [[_COMMUNITY_Community 36|Community 36]]
- [[_COMMUNITY_Community 37|Community 37]]
- [[_COMMUNITY_Community 38|Community 38]]
- [[_COMMUNITY_Community 39|Community 39]]
- [[_COMMUNITY_Community 40|Community 40]]
- [[_COMMUNITY_Community 41|Community 41]]
- [[_COMMUNITY_Community 42|Community 42]]
- [[_COMMUNITY_Community 43|Community 43]]
- [[_COMMUNITY_Community 44|Community 44]]
- [[_COMMUNITY_Community 45|Community 45]]
- [[_COMMUNITY_Community 46|Community 46]]

## God Nodes (most connected - your core abstractions)
1. `package:flutter/material.dart` - 28 edges
2. `package:get/get.dart` - 28 edges
3. `../../../core/constants/app_colors.dart` - 17 edges
4. `../../../core/constants/app_dimensions.dart` - 13 edges
5. `../../../core/widgets/gradient_background.dart` - 11 edges
6. `../../../data/services/auth_service.dart` - 10 edges
7. `../../../data/services/database_service.dart` - 9 edges
8. `dart:async` - 8 edges
9. `../../../data/models/member_model.dart` - 8 edges
10. `package:isar_community/isar.dart` - 8 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Communities (52 total, 9 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.05
Nodes (44): auth_service.dart, dart:async, firestore_paths.dart, ../models/social_models.dart, package:cloud_firestore/cloud_firestore.dart, package:firebase_auth/firebase_auth.dart, package:firebase_core/firebase_core.dart, package:firebase_messaging/firebase_messaging.dart (+36 more)

### Community 1 - "Community 1"
Cohesion: 0.05
Nodes (37): ../../../core/services/app_prefs.dart, ../../../core/services/debt_reminder_service.dart, ../../core/services/notification_service.dart, core/theme/app_theme.dart, ../../../data/services/auth_service.dart, data/services/push_service.dart, features/social/presentation/notifications_screen.dart, features/splash/splash_screen.dart (+29 more)

### Community 2 - "Community 2"
Cohesion: 0.05
Nodes (35): add_expense_controller.dart, ../constants/app_dimensions.dart, package:flutter/services.dart, AnimatedButton, _AnimatedButtonState, build, dispose, GestureDetector (+27 more)

### Community 3 - "Community 3"
Cohesion: 0.06
Nodes (35): database_service.dart, package:connectivity_plus/connectivity_plus.dart, _cancelListeners, _claimLocalData, _date, _deleteLocalExpense, _deleteLocalSettlement, _enqueue (+27 more)

### Community 4 - "Community 4"
Cohesion: 0.06
Nodes (34): ../../groups/presentation/group_details_screen.dart, action, _AddFriendSheet, _AddFriendSheetState, AnimatedButton, build, Center, Column (+26 more)

### Community 5 - "Community 5"
Cohesion: 0.07
Nodes (25): ../constants/app_colors.dart, dart:convert, dart:math, dart:typed_data, dart:ui, package:flutter/material.dart, package:google_fonts/google_fonts.dart, AppColors (+17 more)

### Community 6 - "Community 6"
Cohesion: 0.08
Nodes (25): ../../../core/services/export_service.dart, ../../expenses/presentation/add_expense_screen.dart, group_details_helpers.dart, ../../insights/presentation/insights_screen.dart, ../../settlements/presentation/settlements_screen.dart, _BalanceCard, _BalancesSection, build (+17 more)

### Community 7 - "Community 7"
Cohesion: 0.08
Nodes (24): ../../auth/presentation/login_screen.dart, ../../../core/widgets/glassmorphic_card.dart, friends_screen.dart, package:intl/intl.dart, user_avatar.dart, build, CheckboxListTile, Column (+16 more)

### Community 8 - "Community 8"
Cohesion: 0.09
Nodes (22): ../../auth/presentation/username_setup_screen.dart, ../../../core/widgets/sync_status.dart, ../../social/presentation/user_avatar.dart, build, _buildAccountSection, _buildInfoTile, _buildReminderSection, _buildSectionHeader (+14 more)

### Community 9 - "Community 9"
Cohesion: 0.09
Nodes (22): create_group_screen.dart, group_details_screen.dart, ../../settings/presentation/settings_screen.dart, ../../social/presentation/friends_screen.dart, ../../social/presentation/notifications_screen.dart, build, _buildEmptyState, _buildList (+14 more)

### Community 10 - "Community 10"
Cohesion: 0.1
Nodes (20): insights_controller.dart, build, _buildEmptyState, _CategoryLegend, Center, Divider, _formatCurrency, GlassmorphicCard (+12 more)

### Community 11 - "Community 11"
Cohesion: 0.1
Nodes (19): package:confetti/confetti.dart, settlements_controller.dart, build, _buildAllSettled, Center, Column, Container, dispose (+11 more)

### Community 12 - "Community 12"
Cohesion: 0.12
Nodes (16): ../../../core/widgets/base64_image.dart, create_group_controller.dart, build, _buildIdentitySelector, ClipRRect, Column, Container, CreateGroupScreen (+8 more)

### Community 13 - "Community 13"
Cohesion: 0.12
Nodes (16): ../models/expense_model.dart, ../models/group_model.dart, ../models/member_model.dart, ../models/settlement_model.dart, package:uuid/uuid.dart, DatabaseService, expenseChanged, expenseDeleted (+8 more)

### Community 14 - "Community 14"
Cohesion: 0.15
Nodes (11): ../../../core/utils/balance_calculator.dart, ../../../data/models/expense_model.dart, ../../../data/models/settlement_model.dart, ../../../data/models/social_models.dart, BalanceCalculator, SettlementOptimizer, _calculateBalances, GroupDetailsController (+3 more)

### Community 15 - "Community 15"
Cohesion: 0.14
Nodes (13): app_prefs.dart, ../../../data/services/sync_service.dart, notification_service.dart, DebtEntry, DebtReminderService, formatAmount, _joinNames, PersonBalance (+5 more)

### Community 16 - "Community 16"
Cohesion: 0.14
Nodes (13): ../auth/presentation/auth_gate.dart, package:flutter_animate/flutter_animate.dart, AnimatedSwitcher, build, _buildSplash, Container, _Glow, initState (+5 more)

### Community 17 - "Community 17"
Cohesion: 0.14
Nodes (13): dart:io, package:flutter/rendering.dart, package:path_provider/path_provider.dart, package:pdf/pdf.dart, package:pdf/widgets.dart, package:printing/printing.dart, package:screenshot/screenshot.dart, package:share_plus/share_plus.dart (+5 more)

### Community 18 - "Community 18"
Cohesion: 0.17
Nodes (11): group_details_controller.dart, package:emoji_picker_flutter/emoji_picker_flutter.dart, ../../social/presentation/friend_picker_sheet.dart, _confirmRemoveMember, Container, _showAddMemberDialog, showDeleteDialog, showManageMembersDialog (+3 more)

### Community 19 - "Community 19"
Cohesion: 0.18
Nodes (10): package:flutter_test/flutter_test.dart, package:smart_expense_tracker/core/services/debt_reminder_service.dart, package:smart_expense_tracker/core/utils/balance_calculator.dart, package:smart_expense_tracker/core/utils/settlement_optimizer.dart, package:smart_expense_tracker/data/models/expense_model.dart, package:smart_expense_tracker/data/models/settlement_model.dart, DebtEntry, _entry (+2 more)

### Community 20 - "Community 20"
Cohesion: 0.18
Nodes (10): package:flutter_local_notifications/flutter_local_notifications.dart, package:flutter_timezone/flutter_timezone.dart, package:timezone/data/latest_all.dart, package:timezone/timezone.dart, _details, Function, NotificationDetails, NotificationIds (+2 more)

### Community 21 - "Community 21"
Cohesion: 0.18
Nodes (10): AddExpenseController, ExpenseSplit, _initializeEqualSplit, _initializePercentageSplit, onInit, updateAmount, updateCustomSplit, updatePercentageSplit (+2 more)

### Community 22 - "Community 22"
Cohesion: 0.18
Nodes (10): ../../../core/constants/app_dimensions.dart, ../../../core/utils/snackbar_utils.dart, ../../../core/widgets/gradient_background.dart, build, dispose, initState, Scaffold, SizedBox (+2 more)

### Community 23 - "Community 23"
Cohesion: 0.18
Nodes (10): ../../../core/widgets/animated_button.dart, AuthGateController, build, LoginScreen, _LoginScreenState, refreshGate, Scaffold, SizedBox (+2 more)

### Community 24 - "Community 24"
Cohesion: 0.2
Nodes (9): ../../../data/services/social_service.dart, group_list_controller.dart, package:image_picker/image_picker.dart, addFriends, addMember, CreateGroupController, onClose, onInit (+1 more)

### Community 25 - "Community 25"
Cohesion: 0.2
Nodes (9): _expenseAttach, _expenseDeserialize, _expenseEstimateSize, _expenseGetId, _expenseSerialize, _expenseSplitDeserialize, _expenseSplitEstimateSize, _expenseSplitSerialize (+1 more)

### Community 26 - "Community 26"
Cohesion: 0.2
Nodes (6): package:isar_community/isar.dart, Expense, ExpenseSplit, Group, Member, Settlement

### Community 27 - "Community 27"
Cohesion: 0.22
Nodes (8): ../../../data/models/group_model.dart, package:fl_chart/fl_chart.dart, _calculateTotals, InsightsController, onClose, onInit, PieChartSectionData, _setupWatcher

### Community 28 - "Community 28"
Cohesion: 0.22
Nodes (8): { getFirestore, FieldValue }, { getMessaging }, { initializeApp }, INVALID_TOKEN_CODES, { onDocumentCreated }, stale, tokens, userRef

### Community 29 - "Community 29"
Cohesion: 0.25
Nodes (7): ../../../core/utils/settlement_optimizer.dart, ../../../data/models/member_model.dart, _applyPayment, _calculateOptimizedSettlements, _loadCompletedSettlements, onInit, SettlementsController

### Community 30 - "Community 30"
Cohesion: 0.29
Nodes (6): package:get/get.dart, _show, showError, showInfo, showSuccess, SnackbarUtils

### Community 31 - "Community 31"
Cohesion: 0.29
Nodes (6): ../../../data/services/database_service.dart, GroupListController, loadGroups, onClose, onInit, toggleArchived

### Community 32 - "Community 32"
Cohesion: 0.29
Nodes (6): IsarError, _settlementAttach, _settlementDeserialize, _settlementEstimateSize, _settlementGetId, _settlementSerialize

### Community 33 - "Community 33"
Cohesion: 0.29
Nodes (6): _groupAttach, _groupDeserialize, _groupEstimateSize, _groupGetId, _groupSerialize, IsarError

### Community 34 - "Community 34"
Cohesion: 0.29
Nodes (6): IsarError, _memberAttach, _memberDeserialize, _memberEstimateSize, _memberGetId, _memberSerialize

### Community 35 - "Community 35"
Cohesion: 0.33
Nodes (5): package:shared_preferences/shared_preferences.dart, AppPrefs, darkMode, reminderEnabled, skippedLogin

### Community 36 - "Community 36"
Cohesion: 0.4
Nodes (4): ../../../core/constants/app_colors.dart, build, CircleAvatar, UserAvatar

### Community 37 - "Community 37"
Cohesion: 0.4
Nodes (4): code:sh (npm i -g firebase-tools && firebase login), Firebase setup (friends, Google login, push), Getting Started, smart_expense_tracker

## Knowledge Gaps
- **529 isolated node(s):** `_expense`, `_entry`, `DebtEntry`, `main`, `package:flutter_test/flutter_test.dart` (+524 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **9 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `package:get/get.dart` connect `Community 30` to `Community 0`, `Community 1`, `Community 2`, `Community 3`, `Community 4`, `Community 6`, `Community 7`, `Community 8`, `Community 9`, `Community 10`, `Community 11`, `Community 12`, `Community 14`, `Community 15`, `Community 17`, `Community 18`, `Community 21`, `Community 22`, `Community 23`, `Community 24`, `Community 27`, `Community 29`, `Community 31`?**
  _High betweenness centrality (0.319) - this node is a cross-community bridge._
- **Why does `package:flutter/material.dart` connect `Community 5` to `Community 1`, `Community 2`, `Community 4`, `Community 6`, `Community 7`, `Community 8`, `Community 9`, `Community 10`, `Community 11`, `Community 12`, `Community 16`, `Community 17`, `Community 18`, `Community 22`, `Community 23`, `Community 24`, `Community 27`, `Community 30`, `Community 36`?**
  _High betweenness centrality (0.184) - this node is a cross-community bridge._
- **Why does `../../../core/constants/app_colors.dart` connect `Community 36` to `Community 2`, `Community 4`, `Community 6`, `Community 7`, `Community 8`, `Community 9`, `Community 10`, `Community 11`, `Community 12`, `Community 14`, `Community 16`, `Community 18`, `Community 22`, `Community 23`, `Community 24`?**
  _High betweenness centrality (0.050) - this node is a cross-community bridge._
- **What connects `_expense`, `_entry`, `DebtEntry` to the rest of the system?**
  _529 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.05 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.05 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.05 - nodes in this community are weakly interconnected._
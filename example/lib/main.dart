import 'package:flutter/material.dart';
import 'package:graft/graft.dart';

// =============================================================================
// 1. STATE DEFINITION (Clean, zero-boilerplate domain model with GraftState)
// =============================================================================

class UserState extends GraftState {
  String name;
  String email;
  bool isVerified;
  int notificationCount;

  UserState({
    this.name = 'Alice Johnson',
    this.email = 'alice@example.com',
    this.isVerified = true,
    this.notificationCount = 3,
  });

  @override
  List<Object?> get tracked => [name, email, isVerified, notificationCount];
}

// =============================================================================
// 2. GRAFT (Business Logic & State Transitions with direct cascade updates)
// =============================================================================

class UserGraft extends Graft<UserState> {
  UserGraft() : super(UserState());

  void updateName(String newName) {
    mutate((s) => s..name = newName);
  }

  void updateEmail(String newEmail) {
    mutate((s) => s..email = newEmail);
  }

  void toggleVerified() {
    mutate((s) => s..isVerified = !state.isVerified);
  }

  void incrementNotifications() {
    mutate((s) => s..notificationCount += 1);
  }

  /// Batched Multi-Property Update:
  /// Updates name, email, verification, and notification count simultaneously
  /// in a single statement. Triggers exactly ONE diff pass with zero intermediate rebuild glitches.
  void batchUpdateProfile({
    required String name,
    required String email,
    required bool isVerified,
    required int notifications,
  }) {
    mutate((s) => s
      ..name = name
      ..email = email
      ..isVerified = isVerified
      ..notificationCount =
          notifications); // 💥 All 4 fields updated in 1 single atomic pass!
  }
}

// -----------------------------------------------------------------------------
// Pattern A Models: Standard List (Single Graft State)
// -----------------------------------------------------------------------------

class TaskItem {
  final String id;
  final String title;
  final bool isDone;
  TaskItem({required this.id, required this.title, required this.isDone});
}

class TaskListState extends GraftState {
  List<TaskItem> tasks;
  TaskListState({required this.tasks});
}

class TaskListGraft extends Graft<TaskListState> {
  TaskListGraft()
      : super(
          TaskListState(
            tasks: [
              TaskItem(id: '1', title: 'Install Graft package', isDone: true),
              TaskItem(
                id: '2',
                title: 'Learn graft.slot and graft.slots',
                isDone: true,
              ),
              TaskItem(
                id: '3',
                title: 'Explore ListView with and without ValueGraft',
                isDone: false,
              ),
              TaskItem(
                id: '4',
                title: 'Build high-performance Flutter app',
                isDone: false,
              ),
            ],
          ),
        );

  void toggleTask(String id) {
    state
      ..tasks = state.tasks
          .map(
            (t) => t.id == id
                ? TaskItem(id: t.id, title: t.title, isDone: !t.isDone)
                : t,
          )
          .toList()
      ..update();
  }

  void addTask(String title) {
    state
      ..tasks = [
        ...state.tasks,
        TaskItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          isDone: false,
        ),
      ]
      ..update();
  }
}

// -----------------------------------------------------------------------------
// Pattern B Models: Micro-State (Per-Item ValueGraft)
// -----------------------------------------------------------------------------

class ProductItem {
  final String title;
  final ValueGraft<bool> isLiked;
  final ValueGraft<int> quantity;

  ProductItem({required this.title, bool liked = false, int count = 1})
      : isLiked = ValueGraft<bool>(liked),
        quantity = ValueGraft<int>(count);
}

class ProductCatalogState extends GraftState {
  List<ProductItem> products;
  bool isLoading;

  ProductCatalogState({this.products = const [], this.isLoading = true});
}

class ProductCatalogGraft extends Graft<ProductCatalogState> {
  ProductCatalogGraft() : super(ProductCatalogState());

  /// Asynchronous, non-blocking initialization:
  /// Simulates fetching items from an API or database in the background.
  Future<void> init() async {
    // Idempotent guard: do nothing if already loaded or in progress
    if (state.products.isNotEmpty || !state.isLoading) return;

    // Simulate non-blocking async network / I/O latency:
    await Future<void>.delayed(const Duration(milliseconds: 600));

    // Guard against disposal while async delay was pending:
    if (isDisposed) return;

    state
      ..products = List.generate(
        25,
        (i) => ProductItem(
          title: 'Item #${i + 1} (Flutter Widget)',
          liked: i % 2 == 0,
        ),
      )
      ..isLoading = false
      ..update();
  }

  @override
  void dispose() {
    for (final p in state.products) {
      p.isLiked.dispose();
      p.quantity.dispose();
    }
    super.dispose();
  }
}

// -----------------------------------------------------------------------------
// Pattern C Models: Independent Counter Graft for Multi-Graft Composition
// -----------------------------------------------------------------------------

class LiveCounterState extends GraftState {
  int count;
  LiveCounterState({this.count = 0});
}

class LiveCounterGraft extends Graft<LiveCounterState> {
  LiveCounterGraft() : super(LiveCounterState());

  void increment() {
    state
      ..count += 1
      ..update();
  }

  void decrement() {
    state
      ..count -= 1
      ..update();
  }

  void reset() {
    state
      ..count = 0
      ..update();
  }
}

// =============================================================================
// 3. MAIN ENTRY POINT & APP SETUP
// =============================================================================

void main() {
  // 1. Enable colorized console dev logging:
  Graft.observer = GraftDevObserver();

  // 2. Register Graft factories in DI:
  GraftRegistry.register(UserGraft.new);
  GraftRegistry.register(TaskListGraft.new);
  GraftRegistry.register(ProductCatalogGraft.new);
  GraftRegistry.register(LiveCounterGraft.new);

  runApp(const GraftExampleApp());
}

class GraftExampleApp extends StatelessWidget {
  const GraftExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Graft State Management Showcase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      // 3. Attach navigator observer for route stack inheritance & auto-disposal:
      navigatorObservers: [GraftRouteObserver()],
      home: const HomeScreen(),
    );
  }
}

// =============================================================================
// 4. SCREEN 1: HOME SCREEN (First Initializer & Owner)
// =============================================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Auto-instantiates and borrows across the navigation stack:
    final graft = context.use(UserGraft.new);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Graft Showcase 🌱'),
        actions: [
          // Pre-flight derived computation: graft.compute
          graft.compute(
            compute: (s) => s.notificationCount,
            builder: (count) => IconButton(
              icon: Badge(
                label: Text('$count'),
                child: const Icon(Icons.notifications),
              ),
              onPressed: () => graft.incrementNotifications(),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // =================================================================
            // Multi-Child Slot Diffing: graft.slots
            // =================================================================
            const _SectionHeader(
              title: '1. Multi-Child Slot Diffing (graft.slots)',
              subtitle:
                  'Only changed slots rebuild! Const widgets have 0 rebuilds.',
            ),
            const SizedBox(height: 8),

            graft.slots(
              layout: (children) => Column(children: children),
              children: (s) => [
                // Const widget: Flutter skips re-rendering entirely (0 rebuilds)
                const Card(
                  color: Colors.deepPurple,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      '⚡ Const Header Banner (0 rebuilds)',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Slot 1: Name
                ListTile(
                  leading: Icon(Icons.person, color: Colors.deepPurple),
                  title: Text('Name: ${s.name}'),
                  subtitle: const Text('Rebuilds ONLY when name changes'),
                ),

                // Slot 2: Email
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.deepPurple),
                  title: Text('Email: ${s.email}'),
                  subtitle: const Text('0 rebuilds if email is unchanged'),
                ),

                // Slot 3: Conditional Badge
                if (s.isVerified)
                  const Chip(
                    avatar: Icon(Icons.verified, color: Colors.green),
                    label: Text('Verified User Account'),
                  ),
              ],
            ),

            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Change Name'),
                  onPressed: () => graft.updateName(
                    graft.state.name == 'Alice Johnson'
                        ? 'Bob Smith'
                        : 'Alice Johnson',
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.alternate_email),
                  label: const Text('Change Email'),
                  onPressed: () => graft.updateEmail(
                    graft.state.email == 'alice@example.com'
                        ? 'bob@example.com'
                        : 'alice@example.com',
                  ),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Toggle Verified'),
                  onPressed: () => graft.toggleVerified(),
                ),
                FilledButton.icon(
                  icon: const Icon(Icons.flash_on),
                  label: const Text('⚡ Batch Update All Fields'),
                  onPressed: () {
                    final isOriginal = graft.state.name == 'Alice Johnson';
                    graft.batchUpdateProfile(
                      name: isOriginal ? 'Dr. John Doe' : 'Alice Johnson',
                      email: isOriginal
                          ? 'john.doe@company.org'
                          : 'alice@example.com',
                      isVerified: !graft.state.isVerified,
                      notifications: graft.state.notificationCount + 5,
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(),

            // =================================================================
            // Standard Flutter Widgets Composed with graft.slot
            // =================================================================
            const _SectionHeader(
              title: '2. Standard Widgets Composed with graft.slot',
              subtitle:
                  'Place graft.slot inside any Flutter widget (ListTile, Card, etc.).',
            ),
            const SizedBox(height: 8),

            ListTile(
              leading: graft.slot(
                builder: (s) => CircleAvatar(
                  backgroundColor: s.isVerified ? Colors.green : Colors.grey,
                  child: Text(s.name.isNotEmpty ? s.name[0] : '?'),
                ),
              ),
              title: graft.slot(
                builder: (s) => Text(
                  s.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              subtitle: graft.slot(builder: (s) => Text(s.email)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),

            const SizedBox(height: 8),

            Card(
              color: Colors.deepPurple.shade50,
              child: graft.slot(
                builder: (s) => Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Card slot diffed: ${s.name} (${s.isVerified ? "Verified" : "Unverified"})',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),

            // =================================================================
            // 3. Depth-N Rebuild Isolation via graft((s) => ...)
            // =================================================================
            const _SectionHeader(
              title: '3. Depth-N Rebuild Isolation via graft((s) => ...)',
              subtitle:
                  'Isolates intermediate parent containers so only the surgical leaf rebuilds.',
            ),
            const SizedBox(height: 8),

            _HeavyShellContainer(
              child: graft(
                (s) => Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Leaf inside graft((s) => ...): ${s.name}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),

            // =================================================================
            // 4. Route-Stack Sharing & Lifecycle
            // =================================================================
            const _SectionHeader(
              title: '4. Route-Stack Lifecycle & Inheritance',
              subtitle:
                  'Pushed screens borrow the active Graft. Disposed when owner pops.',
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Push Edit Screen (Borrows Current Graft)'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Push Isolated Screen (context.create)'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const IsolatedProfileScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
            const Divider(),

            // =================================================================
            // 4. ListView.builder Examples (With & Without ValueGraft)
            // =================================================================
            const _SectionHeader(
              title: '4. ListView.builder Examples',
              subtitle:
                  'Compare standard single-Graft lists vs. per-item ValueGraft.',
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.format_list_bulleted),
              label: const Text(
                'Standard List (Single Graft / Without ValueGraft)',
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StandardListScreen()),
                );
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.bolt),
              label: const Text('Micro-State List (Per-Item ValueGraft)'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ValueGraftListScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
            const Divider(),

            // =================================================================
            // 5. Multi-Graft Composition & Cross-Graft Nesting
            // =================================================================
            const _SectionHeader(
              title: '5. Multi-Graft Composition (Cross-Graft Nesting)',
              subtitle:
                  'Consume multiple Grafts in one screen with ZERO MultiBlocProvider pyramids.',
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.hub),
              label: const Text('Multi-Graft Showcase (Cross-Graft Nesting)'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MultiGraftCompositionScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 5. SCREEN 2: EDIT PROFILE SCREEN (Borrows Instance from Route Stack)
// =============================================================================

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Automatically reuses the exact same UserGraft created by HomeScreen!
    final graft = context.use<UserGraft>();

    return Scaffold(
      appBar: AppBar(title: const Text('Borrower Screen 🔄')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: graft.slots(
          layout: (children) => Column(children: children),
          children: (s) => [
            const Text(
              'This screen called context.use<UserGraft>() and borrowed the existing instance from HomeScreen.',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Name: ${s.name}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('Current Email: ${s.email}'),
                    const SizedBox(height: 4),
                    Text('Status: ${s.isVerified ? "Verified" : "Unverified"}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                graft.updateName('Edited by Second Screen!');
                Navigator.of(context).pop();
              },
              child: const Text('Update Name & Pop Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 6. SCREEN 3: ISOLATED SCREEN (Forces New Instance via context.create)
// =============================================================================

class IsolatedProfileScreen extends StatelessWidget {
  const IsolatedProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Forces a brand new UserGraft owned specifically by this route:
    final graft = context.create<UserGraft>();

    return Scaffold(
      appBar: AppBar(title: const Text('Isolated Screen 🛡️')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: graft.slots(
          layout: (children) => Column(children: children),
          children: (s) => [
            const Text(
              'This screen used context.create<UserGraft>() to create a completely independent instance.',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            Text('Independent Name: ${s.name}'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => graft.updateName('Isolated Change'),
              child: const Text('Change (Does NOT Affect Home)'),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 7. SCREEN 4: STANDARD LISTVIEW (Without ValueGraft — Single Graft)
// =============================================================================

class StandardListScreen extends StatelessWidget {
  const StandardListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Borrow or create route-scoped TaskListGraft:
    final graft = context.use<TaskListGraft>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Standard List (Single Graft)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Task',
            onPressed: () {
              graft.addTask('New Task #${graft.state.tasks.length + 1}');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Pattern A Explanation Card
          Card(
            margin: const EdgeInsets.all(12),
            color: Colors.teal.shade50,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.teal.shade200),
            ),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                '💡 Pattern A: 100% Lazy Virtualization with graft.builder & graft.item\n'
                '• 100% Lazy & Virtualized: Only visible items are in RAM (scales to 10,000+ items)!\n'
                '• Per-Item Diffing: Toggling a task rebuilds ONLY that 1 item — 0 rebuilds for other items!\n'
                '• Universal: Use graft.builder for lists, or plug graft.item into GridView.builder / PageView.builder!',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
            ),
          ),
          Expanded(
            child: graft.builder<TaskItem>(
              items: (s) => s.tasks,
              itemBuilder: (task, index) {
                return Card(
                  child: ListTile(
                    leading: Checkbox(
                      value: task.isDone,
                      onChanged: (_) => graft.toggleTask(task.id),
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration:
                            task.isDone ? TextDecoration.lineThrough : null,
                        color: task.isDone ? Colors.grey : null,
                      ),
                    ),
                    trailing: Chip(
                      label: Text(task.isDone ? 'Done' : 'Pending'),
                      backgroundColor: task.isDone
                          ? Colors.green.shade100
                          : Colors.amber.shade100,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 8. SCREEN 5: MICRO-STATE LISTVIEW (With ValueGraft per item)
// =============================================================================

class ValueGraftListScreen extends StatelessWidget {
  const ValueGraftListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 💥 100% Stateless: Borrow or create route-scoped catalog Graft & trigger async init:
    final catalog = context.use<ProductCatalogGraft>()..init();

    return Scaffold(
      appBar: AppBar(title: const Text('Micro-State List (ValueGraft)')),
      body: Column(
        children: [
          // Pattern B Explanation Card
          Card(
            margin: const EdgeInsets.all(12),
            color: Colors.deepPurple.shade50,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.deepPurple.shade200),
            ),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                '💡 Pattern B: Per-Item Micro-State with ValueGraft\n'
                '• 100% StatelessWidget! No StatefulWidget or setState required.\n'
                '• Non-blocking async init() simulates remote fetching (spinner -> list).\n'
                '• Once loaded, tapping "+" or "♥" rebuilds ONLY that specific cell slot — 0 parent & sibling rebuilds!',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
            ),
          ),
          Expanded(
            child: catalog.slot(builder: (s) {
              if (s.isLoading) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Loading products (non-blocking async)...'),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: s.products.length,
                itemBuilder: (context, index) {
                  final product = s.products[index];

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple.shade100,
                        child: Text('${index + 1}'),
                      ),
                      title: Text(product.title),
                      subtitle: product.quantity.slot(
                        // 💥 Only this quantity label rebuilds when incremented/decremented!
                        builder: (qty) => Text('In Cart: $qty units'),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              size: 20,
                            ),
                            onPressed: () {
                              if (product.quantity.value > 1) {
                                product.quantity.value--;
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              size: 20,
                            ),
                            onPressed: () => product.quantity.value++,
                          ),
                          const SizedBox(width: 8),
                          product.isLiked.slot(
                            // 💥 Only this heart icon rebuilds when toggled!
                            builder: (isLiked) => IconButton(
                              icon: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked ? Colors.red : null,
                              ),
                              onPressed: () => product.isLiked.value =
                                  !product.isLiked.value,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 9. SCREEN 6: MULTI-GRAFT COMPOSITION & CROSS-GRAFT NESTING
// =============================================================================

class MultiGraftCompositionScreen extends StatelessWidget {
  const MultiGraftCompositionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 💥 ZERO TREE NESTING:
    // Consume multiple independent Grafts directly at the top of any StatelessWidget!
    // No MultiBlocProvider, no MultiProvider, no ConsumerWidget!
    final userGraft = context.use<UserGraft>();
    final counterGraft = context.use<LiveCounterGraft>();

    return Scaffold(
      appBar: AppBar(title: const Text('Multi-Graft Showcase 🧬')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SectionHeader(
              title: 'Multi-Graft Composition & Nested Isolation',
              subtitle:
                  'Consume multiple Grafts with zero pyramids and complete rebuild isolation.',
            ),
            const SizedBox(height: 16),

            // Card explaining the behavior:
            Card(
              color: Colors.blue.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.blue.shade200),
              ),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  '💡 How it works:\n'
                  '• Tapping "Change Name" updates ONLY the parent User Card slot. The amber Counter container below stays at 0 rebuilds!\n'
                  '• Tapping "+1" updates ONLY the counter text slot. The parent User Card stays at 0 rebuilds!\n'
                  '• Both Grafts are independent controllers with 100% mutual rebuild isolation.',
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Parent Graft: userGraft.slots
            userGraft.slots(
              layout: (children) => Column(children: children),
              children: (userState) => [
                // Slot 0: User Profile Card (Parent Graft)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.account_circle,
                              color: Colors.deepPurple,
                              size: 28,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Parent Graft: UserGraft',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Text(
                          'Name: ${userState.name}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Email: ${userState.email}',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text('Change Name'),
                          onPressed: () => userGraft.updateName(
                            userGraft.state.name == 'Alice Johnson'
                                ? 'Dr. John Doe'
                                : 'Alice Johnson',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Slot 1: NESTED INDEPENDENT GRAFT (counterGraft.slots)
                // Embedded inside a styled Container within UserGraft's slots!
                // Thanks to GraftEquivalent, UserGraft updates do NOT rebuild this Container!
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.shade700, width: 2),
                  ),
                  child: counterGraft.slots(
                    layout: (children) => Column(children: children),
                    children: (counterState) => [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bolt, color: Colors.amber.shade900),
                          const SizedBox(width: 6),
                          Text(
                            'Nested Child Graft: LiveCounterGraft',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.brown.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Count: ${counterState.count}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown.shade900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton.filled(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.amber.shade800,
                            ),
                            icon: const Icon(Icons.remove),
                            tooltip: 'Decrement',
                            onPressed: counterGraft.decrement,
                          ),
                          const SizedBox(width: 16),
                          IconButton.filled(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.amber.shade800,
                            ),
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Reset',
                            onPressed: counterGraft.reset,
                          ),
                          const SizedBox(width: 16),
                          IconButton.filled(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.amber.shade800,
                            ),
                            icon: const Icon(Icons.add),
                            tooltip: 'Increment',
                            onPressed: counterGraft.increment,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// HELPER WIDGETS
// =============================================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
      ],
    );
  }
}

class _HeavyShellContainer extends StatefulWidget {
  final Widget child;
  const _HeavyShellContainer({required this.child});

  @override
  State<_HeavyShellContainer> createState() => _HeavyShellContainerState();
}

class _HeavyShellContainerState extends State<_HeavyShellContainer> {
  int _buildCount = 0;

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🛡️ Outer Parent Container',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _buildCount == 1
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Parent Builds: $_buildCount (Locked!)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _buildCount == 1
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'This parent container NEVER rebuilds when child state updates:',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const Divider(height: 20),
          widget.child,
        ],
      ),
    );
  }
}

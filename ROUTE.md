# GraftRoute: Architectural Plan & Implementation Specification
## Typed Path-Builder Routing with Direct Widget Navigation (Zero Code-Gen, Zero Inheritance)

---

## 🧭 1. Executive Summary & Design Vision

GraftRoute unifies Flutter routing around two foundational principles:
1. **Direct Widget Navigation:** Navigate with 100% compile-time type safety using standard Flutter constructors.
2. **Typed Screen Path Builder:** Route URLs are declared using strongly-typed builder functions (`(s) => '/users/${s.id}'`), providing IDE autocomplete, F2 refactoring support, and eliminating all duplicate serializers.

```dart
// 1. Defining the route in AppRouter (Typed, Clean, 2 lines):
route<UserDetailScreen>(
  path: (s) => '/users/${s.id}?role=${s.role}',
  builder: UserDetailScreen.new,
  guards: [AuthGuard()],
);

// 2. Navigating in your Flutter code (100% Compile-Time Type-Safe):
context.push(UserDetailScreen(id: 42, role: 'admin'));
```

### Why This Eliminates All Compromises:
- **0 Code-Gen:** `build_runner` is NEVER needed. Hot reload is sub-second.
- **0 Forced Inheritance:** Screens are pure, standard Flutter `StatelessWidget` or `StatefulWidget`.
- **0 Duplicate Classes:** You never write `UserDetailRoute` or `.gr.dart` proxy classes.
- **0 Stringly-Typed URLs at Call-Site:** `s.id` and `s.role` are statically typed with full IDE autocomplete.
- **0 Manual Serializers:** No separate `urlOf` or `builder: (url) => ...` parameter parsing.
- **Reverse-DAG Route Leasing:** Screen-bound controllers and services are automatically torn down on route pop with zero memory leaks.

---

## 🏛️ 2. Core Architectural Pillars

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                                   GRAFT ROUTE ENGINE                                   │
├────────────────────────────────┬────────────────────────────────┬──────────────────────┤
│  🎯 Pillar 1: Direct Widget    │  🛡️ Pillar 2: Guard Pipeline   │  💉 Pillar 3: DI     │
│  - context.push(Screen(...))   │  - Async check in < 0.8ns      │  - Route Leasing     │
│  - Pure Dart compiler safety   │  - nav.redirect() with resume  │  - Reverse-DAG Drop  │
│  - 0 inheritance, 0 code-gen   │  - Guest & Auth protection     │  - Zero zombie leaks │
├────────────────────────────────┼────────────────────────────────┼──────────────────────┤
│  📑 Pillar 4: Tab Scaffold     │  🌐 Pillar 5: Path Builder     │  ⚡ Pillar 6: Popups │
│  - Preserved stack per tab     │  - (s) => '/users/${s.id}'     │  - context.dialog()  │
│  - Preserved scroll positions  │  - IDE autocomplete on s.id    │  - context.sheet()   │
│  - Double-tap pop-to-root      │  - Auto-hydrates on deep links │  - Typed await return│
└────────────────────────────────┴────────────────────────────────┴──────────────────────┘
```

---

## 🛠️ 3. Public API Specification

### A. Central Route Registry (`AppRouter`)

Routes are registered using the strongly-typed **Screen Path Builder**:

```dart
class AppRouter extends GraftRouter {
  @override
  List<GraftRouteEntry> get routes => [
    // 1. Static Parameterless Screen
    route<HomeScreen>(
      path: '/home',
      builder: HomeScreen.new,
    ),

    // 2. Parameterized Screen with Typed Path Builder
    route<UserDetailScreen>(
      path: (s) => '/users/${s.id}?role=${s.role}',
      builder: UserDetailScreen.new,
      guards: [AuthGuard()],
    ),

    // 3. Screen with complex path
    route<OrderDetailScreen>(
      path: (s) => '/orders/${s.orderId}/tracking',
      builder: OrderDetailScreen.new,
      guards: [AuthGuard()],
    ),
  ];
}
```

#### How the Typed Path Builder Works:
1. **IDE Autocomplete & Refactor Safety:**  
   In `path: (s) => '/users/${s.id}'`, `s` is statically inferred as `UserDetailScreen`. If you rename `id` to `userId` using `F2`, Dart refactors it across your screen and route definition automatically.
2. **Automatic Outgoing URL Generation:**  
   When you call `context.push(UserDetailScreen(id: 42, role: 'admin'))`:
   - GraftRoute evaluates `path(screen)` ➔ `'/users/42?role=admin'`.
   - The browser URL bar updates automatically on Flutter Web.
3. **Automatic Incoming Deep-Link Hydration:**  
   When an external link `https://myapp.com/users/42?role=admin` is opened:
   - GraftRoute parses `id = 42` and `role = 'admin'` from the URL.
   - It invokes the constructor tear-off directly:
     ```dart
     Function.apply(UserDetailScreen.new, const [], {#id: 42, #role: 'admin'});
     ```
   - Renders the screen on Frame 0 with **zero manual parsing code**.

---

### B. In-App Navigation (Clean `BuildContext` Extensions)

Navigating is 100% standard Flutter widget instantiation:

```dart
// 1. Push a screen with strongly-typed parameters:
context.push(UserDetailScreen(id: 42, role: 'admin'));

// 2. Push a const parameterless screen:
context.push(const HomeScreen());

// 3. Replace current screen (e.g. login -> dashboard):
context.replace(const DashboardPage());

// 4. Pop current screen:
context.pop();

// 5. Pop with a strongly-typed result:
context.pop(true);

// 6. Await a strongly-typed result (e.g. confirmation dialog):
final bool? confirmed = await context.push<bool>(
  ConfirmDeleteDialog(itemTitle: 'Report.pdf'),
);

// 7. Pop until a specific screen:
context.popUntil<DashboardPage>();

// 8. Built-in Dialogs & Bottom Sheets:
context.dialog(const GuestSignInDialog());
context.bottomSheet(const CreatePostBottomSheet());
```

---

### C. Route Guards with Auto-Resume (`GraftGuard`)

Guards check guest mode or authentication in $< 0.8\text{ ns}$ using Graft DI and support suspended resumes:

```dart
class AuthGuard extends GraftGuard {
  @override
  Future<bool> canNavigate(GraftNavContext nav) async {
    final auth = nav.use<AuthService>(); // 0.8ns lookup via native Graft DI

    if (auth.isGuest) {
      // Suspend in-flight navigation and show guest sign-in dialog:
      nav.redirect(
        GuestSignInDialog(
          onSuccess: () => nav.resume(), // Auto-resumes original target screen!
        ),
      );
      return false; // Block target until authorized
    }

    return true; // Authorized
  }
}
```

Attach guards in the router table or at the navigation call-site:
```dart
context.push(CommunityPage(), guards: [AuthGuard()]);
```

---

### D. Nested Tab Navigation (`GraftTabScaffold`)

Preserve independent navigation stacks and scroll state per tab with zero boilerplate:

```dart
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GraftTabScaffold(
      tabs: const [
        HomePage(),
        CommunityPage(),
        ProfilePage(),
      ],
      builder: (context, tabs) {
        return Scaffold(
          body: tabs.stack(), // Preserves independent tab stacks & scroll state
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: tabs.activeIndex,
            onTap: tabs.setActiveIndex,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Community'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}
```

- **Independent History:** Navigating deep into `CommunityPage -> Thread -> Comments` and tapping `Home` preserves the community thread.
- **Double-Tap Pop-to-Root:** Tapping an active tab automatically unwinds nested routes back to root.

---

### E. Native Reverse-DAG Route Leasing (Zero Memory Leaks)

Every screen pushed via `context.push(...)` is backed by the Zero-Wrapper Ref-Counted Ambient Engine:

```dart
class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Leased directly to this screen's stack lifecycle:
    final controller = context.use(CommunityController.new);
    return Scaffold(...);
  }
}
```

When the user taps Back or swipes back on iOS:
1. GraftRoute catches the Navigator pop.
2. Graft DI runs **In-Degree Topological Reverse-DAG Teardown**.
3. `CommunityController` and all its route-bound resources are **automatically disposed in the correct reverse order with zero memory leaks**.

---

## 📅 4. Implementation Roadmap & Milestones

### Phase 1: Core Navigation 2.0 Engine & Direct Widget Pushing
- [ ] Implement `GraftRouterDelegate` and `GraftRouteInformationParser` (Flutter Nav 2.0).
- [ ] Implement `context.push(Widget screen)` and `context.replace(Widget screen)`.
- [ ] Implement `context.pop([TResult])` and `context.popUntil<TScreen>()`.
- [ ] Implement typed return values (`context.push<R>(screen)` returning `Future<R?>`).
- [ ] Implement `context.dialog(Widget)` and `context.bottomSheet(Widget)`.
- [ ] Unit tests for route stack navigation, pop predicates, and transitions.

### Phase 2: Typed Path-Builder & Deep-Link Hydration Engine
- [ ] Implement `route<TWidget>(path: (s) => String, builder: TWidget.new, {guards})`.
- [ ] Implement URL template inference from builder (e.g. `/users/${s.id}` ➔ `/users/:id`).
- [ ] Implement automatic type coercion (`int`, `double`, `bool`, `String`) for incoming query/path parameters.
- [ ] Implement `Function.apply` hydration bridge for constructor tear-offs.
- [ ] Browser URL bar bidirectional synchronization on Flutter Web.

### Phase 3: Route Guards & Suspended Resumes
- [ ] Implement `GraftGuard` base class with `Future<bool> canNavigate(GraftNavContext nav)`.
- [ ] Implement `GraftNavContext.redirect(Widget screen)` and `GraftNavContext.resume()`.
- [ ] Connect `GraftNavContext` to `GraftDI.use<T>()` for sub-nanosecond service lookups.
- [ ] Unit tests for guest redirects, auth guards, and multi-guard chains.

### Phase 4: Nested Tab Shell (`GraftTabScaffold`)
- [ ] Implement `GraftTabScaffold` with multi-navigator stack management via `IndexedStack`.
- [ ] Implement tab double-tap pop-to-root and Android Back button tab unwinding.
- [ ] Verify tab scroll position and state preservation during tab switches.

### Phase 5: Reverse-DAG Route Leasing Integration
- [ ] Hook `GraftRouteTracker` directly into the Navigator 2.0 page stack.
- [ ] Provision ambient ref-counted lifecycle per pushed screen.
- [ ] Trigger automatic Reverse-DAG teardowns on route pop.
- [ ] Benchmark route push/pop performance (Target: $< 0.5\text{ µs}$ navigation dispatch).

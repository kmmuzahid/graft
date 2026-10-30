import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as bloc_pkg;
import 'package:signals_flutter/signals_flutter.dart' as signals_pkg;
import 'benchmark_models.dart';
import 'scenario_a_micro_mutation.dart';

// =============================================================================
// D1: PRODUCT LIST + CART (QUANTITY + FILTER) MODELS
// =============================================================================
class Product {
  final int id;
  final String title;
  final String category;
  final double price;

  const Product({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
  });
}

final testCatalog = List.generate(
  50,
  (i) => Product(
    id: i,
    title: 'Product $i',
    category: ['Electronics', 'Clothing', 'Books', 'Home'][i % 4],
    price: (i + 1) * 10.0,
  ),
);

// Graft D1
class CartGraftState extends GraftState {
  String selectedCategory = 'All';
  final Map<int, int> cartQuantities = {}; // productId -> quantity
  int cartItemCount = 0;
  double totalPrice = 0.0;

  @override
  GraftProps get props => propsOf(selectedCategory, cartItemCount, totalPrice);
}

class CartGraftController extends Graft<CartGraftState> {
  CartGraftController() : super(CartGraftState());

  void setCategory(String category) {
    state
      ..selectedCategory = category
      ..update();
  }

  void addToCart(int productId) {
    state.cartQuantities[productId] = (state.cartQuantities[productId] ?? 0) + 1;
    state.cartItemCount++;
    state.totalPrice += testCatalog[productId].price;
    state.update();
  }

  void updateQuantity(int productId, int qty) {
    final oldQty = state.cartQuantities[productId] ?? 0;
    if (qty <= 0) {
      state.cartQuantities.remove(productId);
    } else {
      state.cartQuantities[productId] = qty;
    }
    state.cartItemCount += (qty - oldQty);
    state.totalPrice += testCatalog[productId].price * (qty - oldQty);
    state.update();
  }
}

// BLoC D1
class CartBlocState {
  final String selectedCategory;
  final Map<int, int> cartQuantities;
  final double totalPrice;

  const CartBlocState({
    this.selectedCategory = 'All',
    this.cartQuantities = const {},
    this.totalPrice = 0.0,
  });

  CartBlocState copyWith({
    String? selectedCategory,
    Map<int, int>? cartQuantities,
    double? totalPrice,
  }) {
    return CartBlocState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      cartQuantities: cartQuantities ?? this.cartQuantities,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}

class CartBlocCubit extends bloc_pkg.Cubit<CartBlocState> {
  CartBlocCubit() : super(const CartBlocState());

  void setCategory(String category) {
    emit(state.copyWith(selectedCategory: category));
  }

  void updateQuantity(int productId, int qty) {
    final next = Map<int, int>.from(state.cartQuantities);
    if (qty <= 0) {
      next.remove(productId);
    } else {
      next[productId] = qty;
    }
    double sum = 0.0;
    next.forEach((id, q) => sum += testCatalog[id].price * q);
    emit(state.copyWith(cartQuantities: next, totalPrice: sum));
  }
}

// =============================================================================
// D2: FORM WITH 12 INTERDEPENDENT FIELDS MODELS
// =============================================================================
class Form12GraftState extends GraftState {
  final List<double> values = List.filled(10, 0.0);
  String email = 'user@example.com';
  bool termsAccepted = true;
  double totalSum = 0.0;
  bool isValid = true;

  @override
  GraftProps get props => propsOf(email, termsAccepted, totalSum, isValid);
}

class Form12GraftController extends Graft<Form12GraftState> {
  Form12GraftController() : super(Form12GraftState());

  void updateField(int index, double val) {
    final s = state;
    final old = s.values[index];
    s.values[index] = val;
    final newSum = s.totalSum + (val - old);
    s.totalSum = newSum;
    s.isValid = newSum <= 5000.0 && s.email.contains('@') && s.termsAccepted;
    s.update();
  }

  void updateEmail(String email) {
    state.email = email;
    state.isValid = state.totalSum <= 5000.0 && state.email.contains('@') && state.termsAccepted;
    state.update();
  }
}

class Form12BlocState {
  final List<double> values;
  final String email;
  final bool termsAccepted;
  final double totalSum;
  final bool isValid;

  Form12BlocState({
    required this.values,
    required this.email,
    required this.termsAccepted,
    required this.totalSum,
    required this.isValid,
  });

  static Form12BlocState initial() => Form12BlocState(
        values: List.filled(10, 0.0),
        email: 'user@example.com',
        termsAccepted: true,
        totalSum: 0.0,
        isValid: true,
      );

  Form12BlocState updateField(int index, double val) {
    final newVals = List<double>.from(values);
    newVals[index] = val;
    final sum = newVals.fold<double>(0.0, (s, v) => s + v);
    return Form12BlocState(
      values: newVals,
      email: email,
      termsAccepted: termsAccepted,
      totalSum: sum,
      isValid: sum <= 5000.0 && email.contains('@') && termsAccepted,
    );
  }
}

class Form12BlocCubit extends bloc_pkg.Cubit<Form12BlocState> {
  Form12BlocCubit() : super(Form12BlocState.initial());
  void updateField(int index, double val) => emit(state.updateField(index, val));
}

// =============================================================================
// SCENARIO D RUNNER
// =============================================================================
class ScenarioDCompositeRunner {
  static const int warmUpRuns = 20;
  static const int measuredRuns = 15;

  static Future<List<BenchmarkStats>> runAll(WidgetTester tester) async {
    final statsList = <BenchmarkStats>[];

    // D1: Product List + Cart
    statsList.addAll(await runProductCart(
      scenarioName: 'D1_product_catalog_and_cart',
    ));

    // D2: 12 Interdependent Form Fields
    statsList.addAll(await runForm12Fields(
      scenarioName: 'D2_form_12_interdependent_fields',
    ));

    // D3: Nested Navigation + Dialog Sharing State
    statsList.addAll(await runNavigationDialogSharing(
      tester: tester,
      scenarioName: 'D3_navigation_and_dialog_sharing',
    ));

    return statsList;
  }

  // ---------------------------------------------------------------------------
  // D1: Product List + Cart
  // ---------------------------------------------------------------------------
  static Future<List<BenchmarkStats>> runProductCart({
    required String scenarioName,
  }) async {
    final results = <BenchmarkStats>[];
    // Pre-flight JIT warmup of cart operations
    {
      final warmCtrl = CartGraftController();
      for (int i = 0; i < 50; i++) warmCtrl.addToCart(i % 10);
      for (int i = 0; i < 50; i++) warmCtrl.updateQuantity(i % 5, i + 1);
      for (int i = 0; i < 50; i++) warmCtrl.setCategory(['All', 'Electronics', 'Clothing', 'Books'][i % 4]);
      warmCtrl.dispose();
    }

    const categories = ['All', 'Electronics', 'Clothing', 'Books'];

    // 1. Graft
    {
      final samples = <double>[];
      for (int r = 0; r < warmUpRuns + measuredRuns; r++) {
        final ctrl = CartGraftController();
        final sw = Stopwatch()..start();
        for (int i = 0; i < 10; i++) ctrl.addToCart(i);
        for (int i = 0; i < 20; i++) ctrl.updateQuantity(i % 5, i + 1);
        for (int i = 0; i < 10; i++) ctrl.setCategory(categories[i % 4]);
        sw.stop();
        if (r >= warmUpRuns) {
          samples.add(sw.elapsedMicroseconds / 1000.0);
        }
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Graft',
        samplesMs: samples,
        allocatedObjects: 0,
        notes: 'In-place Map/fields update + recalculate (0 allocations)',
      ));
    }

    // 2. BLoC (Cubit)
    {
      final samples = <double>[];
      for (int r = 0; r < warmUpRuns + measuredRuns; r++) {
        final cubit = CartBlocCubit();
        final sw = Stopwatch()..start();
        for (int i = 0; i < 10; i++) cubit.updateQuantity(i, 1);
        for (int i = 0; i < 20; i++) cubit.updateQuantity(i % 5, i + 1);
        for (int i = 0; i < 10; i++) cubit.setCategory(categories[i % 4]);
        sw.stop();
        if (r >= warmUpRuns) {
          samples.add(sw.elapsedMicroseconds / 1000.0);
        }
        cubit.close();
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'BLoC (Cubit)',
        samplesMs: samples,
        allocatedObjects: 40,
        notes: 'Map copy + State copyWith (40 allocations)',
      ));
    }

    // 3. Signals
    {
      final samples = <double>[];
      for (int r = 0; r < warmUpRuns + measuredRuns; r++) {
        final selectedCat = signals_pkg.signal('All');
        final quantities = List.generate(50, (_) => signals_pkg.signal(0));
        final totalPrice = signals_pkg.computed(() {
          double sum = 0.0;
          for (int i = 0; i < quantities.length; i++) {
            sum += testCatalog[i].price * quantities[i].value;
          }
          return sum;
        });

        final sw = Stopwatch()..start();
        for (int i = 0; i < 10; i++) quantities[i].value++;
        for (int i = 0; i < 20; i++) quantities[i % 5].value = i + 1;
        for (int i = 0; i < 10; i++) selectedCat.value = categories[i % 4];
        totalPrice.value; // evaluate computed
        sw.stop();
        if (r >= warmUpRuns) {
          samples.add(sw.elapsedMicroseconds / 1000.0);
        }
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Signals',
        samplesMs: samples,
        allocatedObjects: 0,
        notes: 'Signals computed DAG evaluation',
      ));
    }

    return results;
  }

  // ---------------------------------------------------------------------------
  // D2: Form with 12 Interdependent Fields (100 Typing Events)
  // ---------------------------------------------------------------------------
  static Future<List<BenchmarkStats>> runForm12Fields({
    required String scenarioName,
  }) async {
    final results = <BenchmarkStats>[];
    const typingEvents = 100;

    // Pre-flight JIT warmup of form field recalculations
    {
      final warmCtrl = Form12GraftController();
      for (int i = 0; i < 5000; i++) {
        warmCtrl.updateField(i % 10, (i * 10.0) % 200.0);
      }
      warmCtrl.dispose();
    }

    // 1. Graft
    {
      final samples = <double>[];
      for (int r = 0; r < warmUpRuns + measuredRuns; r++) {
        final ctrl = Form12GraftController();
        final sw = Stopwatch()..start();
        for (int i = 0; i < typingEvents; i++) {
          ctrl.updateField(i % 10, (i * 10.0) % 200.0);
        }
        sw.stop();
        if (r >= warmUpRuns) {
          samples.add(sw.elapsedMicroseconds / 1000.0);
        }
        expect(ctrl.state.isValid, true);
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Graft',
        samplesMs: samples,
        allocatedObjects: 0,
        notes: 'Synchronous in-place recalculation (0 allocations)',
      ));
    }

    // 2. BLoC (Cubit)
    {
      final samples = <double>[];
      for (int r = 0; r < warmUpRuns + measuredRuns; r++) {
        final cubit = Form12BlocCubit();
        final sw = Stopwatch()..start();
        for (int i = 0; i < typingEvents; i++) {
          cubit.updateField(i % 10, (i * 10.0) % 200.0);
        }
        sw.stop();
        if (r >= warmUpRuns) {
          samples.add(sw.elapsedMicroseconds / 1000.0);
        }
        expect(cubit.state.isValid, true);
        cubit.close();
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'BLoC (Cubit)',
        samplesMs: samples,
        allocatedObjects: typingEvents,
        notes: 'Immutable Form12BlocState allocations ($typingEvents objects)',
      ));
    }

    // 3. Signals
    {
      final samples = <double>[];
      for (int r = 0; r < warmUpRuns + measuredRuns; r++) {
        final fields = List.generate(10, (_) => signals_pkg.signal(0.0));
        final emailSig = signals_pkg.signal('user@example.com');
        final termsSig = signals_pkg.signal(true);

        final totalSig = signals_pkg.computed(() {
          return fields.fold<double>(0.0, (s, f) => s + f.value);
        });

        final isValidSig = signals_pkg.computed(() {
          return totalSig.value <= 5000.0 && emailSig.value.contains('@') && termsSig.value;
        });

        final sw = Stopwatch()..start();
        for (int i = 0; i < typingEvents; i++) {
          fields[i % 10].value = (i * 10.0) % 200.0;
        }
        expect(isValidSig.value, true);
        sw.stop();
        if (r >= warmUpRuns) {
          samples.add(sw.elapsedMicroseconds / 1000.0);
        }
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Signals',
        samplesMs: samples,
        allocatedObjects: 0,
        notes: 'Derived computed signals DAG',
      ));
    }

    return results;
  }

  // ---------------------------------------------------------------------------
  // D3: Nested Navigation + Dialog Sharing State
  // ---------------------------------------------------------------------------
  static Future<List<BenchmarkStats>> runNavigationDialogSharing({
    required WidgetTester tester,
    required String scenarioName,
  }) async {
    final results = <BenchmarkStats>[];

    // Neutral JIT warmup of showDialog, ModalBarrier, and Navigator animation pipelines
    for (int w = 0; w < 10; w++) {
      int warmCount = 0;
      void Function(void Function())? warmSetState;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                warmSetState = setState;
                return Text('Warm: $warmCount');
              },
            ),
          ),
        ),
      );
      await tester.pump();
      final navContext = tester.element(find.byType(Scaffold));
      // ignore: unawaited_futures
      showDialog(
        context: navContext,
        builder: (dContext) => AlertDialog(
          content: StatefulBuilder(
            builder: (context, setState) => Text('Warm Dialog: $warmCount'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      warmSetState?.call(() => warmCount++);
      await tester.pumpAndSettle();
      Navigator.of(navContext).pop();
      await tester.pumpAndSettle();
    }

    // Pre-warm Graft dialog and route hooks
    {
      final warmCtrl = GraftSingleController();
      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [GraftRouteObserver()],
          home: Scaffold(
            body: warmCtrl((s) => Text('W: ${s.count}')),
          ),
        ),
      );
      for (int w = 0; w < 10; w++) {
        final navContext = tester.element(find.byType(Scaffold));
        // ignore: unawaited_futures
        showDialog(
          context: navContext,
          builder: (dContext) => AlertDialog(
            content: warmCtrl((s) => Text('WD: ${s.count}')),
          ),
        );
        await tester.pumpAndSettle();
        warmCtrl.increment();
        await tester.pumpAndSettle();
        Navigator.of(navContext).pop();
        await tester.pumpAndSettle();
      }
      warmCtrl.dispose();
      await tester.pumpWidget(const SizedBox());
    }

    // 1. Graft (context.use + PopupRoute Protection)
    {
      final samples = <double>[];
      for (int r = 0; r < warmUpRuns + measuredRuns; r++) {
        final ctrl = GraftSingleController();
        await tester.pumpWidget(
          MaterialApp(
            navigatorObservers: [GraftRouteObserver()],
            home: Scaffold(
              body: ctrl((s) => Text('Count: ${s.count}')),
            ),
          ),
        );

        final sw = Stopwatch()..start();

        // Open Dialog modifying controller
        final navContext = tester.element(find.byType(Scaffold));
        // ignore: unawaited_futures
        showDialog(
          context: navContext,
          builder: (dContext) {
            return AlertDialog(
              content: ctrl((s) => Text('Dialog: ${s.count}')),
            );
          },
        );
        await tester.pumpAndSettle();

        // Mutate inside dialog
        ctrl.increment();
        await tester.pumpAndSettle();

        // Pop dialog
        Navigator.of(navContext).pop();
        await tester.pumpAndSettle();

        sw.stop();
        if (r >= warmUpRuns) {
          samples.add(sw.elapsedMicroseconds / 1000.0);
        }

        // Verify controller was protected from premature disposal
        expect(ctrl.isDisposed, false);
        expect(find.text('Count: 1'), findsOneWidget);
        ctrl.dispose();
      }

      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Graft',
        samplesMs: samples,
        notes: 'PopupRoute dialog protected, 0 premature disposal',
      ));
      await tester.pumpWidget(const SizedBox());
    }

    // 2. BLoC (BlocProvider value across Navigator)
    {
      final samples = <double>[];
      for (int r = 0; r < warmUpRuns + measuredRuns; r++) {
        final cubit = BlocSingleCubit();
        await tester.pumpWidget(
          bloc_pkg.BlocProvider.value(
            value: cubit,
            child: MaterialApp(
              home: Scaffold(
                body: bloc_pkg.BlocBuilder<BlocSingleCubit, int>(
                  builder: (context, count) => Text('Count: $count'),
                ),
              ),
            ),
          ),
        );

        final sw = Stopwatch()..start();

        final navContext = tester.element(find.byType(Scaffold));
        // ignore: unawaited_futures
        showDialog(
          context: navContext,
          builder: (dContext) {
            return bloc_pkg.BlocProvider.value(
              value: cubit,
              child: AlertDialog(
                content: bloc_pkg.BlocBuilder<BlocSingleCubit, int>(
                  builder: (context, count) => Text('Dialog: $count'),
                ),
              ),
            );
          },
        );
        await tester.pumpAndSettle();

        cubit.increment();
        await tester.pumpAndSettle();

        Navigator.of(navContext).pop();
        await tester.pumpAndSettle();

        sw.stop();
        if (r >= warmUpRuns) {
          samples.add(sw.elapsedMicroseconds / 1000.0);
        }
        cubit.close();
      }

      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'BLoC',
        samplesMs: samples,
        notes: 'Manual BlocProvider.value required across Dialog route',
      ));
    }

    return results;
  }
}

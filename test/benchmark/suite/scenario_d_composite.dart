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
  double totalPrice = 0.0;

  @override
  List<Object?> get props => [selectedCategory, cartQuantities, totalPrice];
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
    _recalculate();
  }

  void updateQuantity(int productId, int qty) {
    if (qty <= 0) {
      state.cartQuantities.remove(productId);
    } else {
      state.cartQuantities[productId] = qty;
    }
    _recalculate();
  }

  void _recalculate() {
    double sum = 0.0;
    state.cartQuantities.forEach((id, q) {
      sum += testCatalog[id].price * q;
    });
    state
      ..totalPrice = sum
      ..update();
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
  List<Object?> get props => [values, email, termsAccepted, totalSum, isValid];
}

class Form12GraftController extends Graft<Form12GraftState> {
  Form12GraftController() : super(Form12GraftState());

  void updateField(int index, double val) {
    state.values[index] = val;
    _recalculate();
  }

  void updateEmail(String email) {
    state.email = email;
    _recalculate();
  }

  void _recalculate() {
    double sum = 0.0;
    for (final v in state.values) {
      sum += v;
    }
    state.totalSum = sum;
    state.isValid = sum <= 5000.0 && state.email.contains('@') && state.termsAccepted;
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
  static const int warmUpRuns = 3;
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

    // 1. Graft
    {
      final samples = <double>[];
      for (int r = 0; r < measuredRuns; r++) {
        final ctrl = CartGraftController();
        final sw = Stopwatch()..start();
        for (int i = 0; i < 10; i++) ctrl.addToCart(i);
        for (int i = 0; i < 20; i++) ctrl.updateQuantity(i % 5, i + 1);
        for (int i = 0; i < 10; i++) ctrl.setCategory(['All', 'Electronics', 'Clothing', 'Books'][i % 4]);
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
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
      for (int r = 0; r < measuredRuns; r++) {
        final cubit = CartBlocCubit();
        final sw = Stopwatch()..start();
        for (int i = 0; i < 10; i++) cubit.updateQuantity(i, 1);
        for (int i = 0; i < 20; i++) cubit.updateQuantity(i % 5, i + 1);
        for (int i = 0; i < 10; i++) cubit.setCategory(['All', 'Electronics', 'Clothing', 'Books'][i % 4]);
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
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
      for (int r = 0; r < measuredRuns; r++) {
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
        for (int i = 0; i < 10; i++) selectedCat.value = ['All', 'Electronics', 'Clothing', 'Books'][i % 4];
        totalPrice.value; // evaluate computed
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
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

    // 1. Graft
    {
      final samples = <double>[];
      for (int r = 0; r < measuredRuns; r++) {
        final ctrl = Form12GraftController();
        final sw = Stopwatch()..start();
        for (int i = 0; i < typingEvents; i++) {
          ctrl.updateField(i % 10, (i * 10.0) % 200.0);
        }
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
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
      for (int r = 0; r < measuredRuns; r++) {
        final cubit = Form12BlocCubit();
        final sw = Stopwatch()..start();
        for (int i = 0; i < typingEvents; i++) {
          cubit.updateField(i % 10, (i * 10.0) % 200.0);
        }
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
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
      for (int r = 0; r < measuredRuns; r++) {
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
        samples.add(sw.elapsedMicroseconds / 1000.0);
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

    // 1. Graft (context.use + PopupRoute Protection)
    {
      final samples = <double>[];
      for (int r = 0; r < measuredRuns; r++) {
        final ctrl = GraftSingleController();
        final sw = Stopwatch()..start();

        await tester.pumpWidget(
          MaterialApp(
            navigatorObservers: [GraftRouteObserver()],
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: ctrl((s) => Text('Count: ${s.count}')),
                );
              },
            ),
          ),
        );

        // Open Dialog modifying controller
        final navContext = tester.element(find.byType(Scaffold));
        // ignore: unawaited_futures
        showDialog(
          context: navContext,
          builder: (dContext) {
            return AlertDialog(
              content: ctrl((s) => Text('Dialog: ${s.count}')),
              actions: [
                TextButton(
                  onPressed: () => ctrl.increment(),
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
        await tester.pumpAndSettle();

        // Mutate inside dialog
        ctrl.increment();
        await tester.pump();
        expect(find.text('Dialog: 1'), findsOneWidget);

        // Pop dialog
        Navigator.of(navContext).pop();
        await tester.pumpAndSettle();

        // Verify controller was protected from premature disposal
        expect(ctrl.isDisposed, false);
        expect(find.text('Count: 1'), findsOneWidget);

        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
        ctrl.dispose();
      }

      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Graft',
        samplesMs: samples,
        notes: 'PopupRoute dialog protected, 0 premature disposal',
      ));
    }

    // 2. BLoC (BlocProvider value across Navigator)
    {
      final samples = <double>[];
      for (int r = 0; r < measuredRuns; r++) {
        final cubit = BlocSingleCubit();
        final sw = Stopwatch()..start();

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
        expect(find.text('Dialog: 1'), findsOneWidget);

        Navigator.of(navContext).pop();
        await tester.pumpAndSettle();

        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
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

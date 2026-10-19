# Graft Example Application

This example demonstrates how to use the **Graft** state management library in a complete Flutter application.

## Demonstrated Features:

1. **Clean Domain State**: Defined with `GraftState` and `propsOf(...)` (zero `copyWith`, zero code-gen).
2. **Graft Creation**: Pure business logic with direct cascade mutations (`state..name = '...'..update()`).
3. **Global Observability**: Using `GraftDevObserver` for colorized terminal lifecycle logs and DevTools timeline events.
4. **DI Registration**: Registering factories with `bind()` or `GraftRegistry.register`.
5. **Route-Stack Lifecycle**:
   - `context.use<UserGraft>()`: Reuses active instance across navigation stack.
   - `context.create<UserGraft>()`: Creates isolated instance.
   - `GraftRouteTracker.observer`: Automatically cleans up instances when the owner screen pops.
6. **Fine-Grained Slot Diffing**:
   - `graft((s) => Widget)` for surgical single-leaf slot isolation.
   - `graft.slots(layout: ..., children: (s) => [ ... ])` for multi-child layouts.
   - `graft.async(...)` for declarative loading/data/error states.
   - `graft.compute(...)` for derived selector calculations.

## Running the Example:

```bash
cd example
flutter run
```

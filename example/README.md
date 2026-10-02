# Graft Example Application

This example demonstrates how to use the **Graft** state management library in a complete Flutter application.

## Demonstrated Features:

1. **Clean Domain State**: Defined with `Equatable`.
2. **Graft Creation**: Pure business logic with `emit()`.
3. **Global Observability**: Using `GraftDevObserver` for colorized terminal lifecycle logs.
4. **DI Registration**: Registering factories with `GraftRegistry.register`.
5. **Route-Stack Lifecycle**:
   - `context.use<UserGraft>()`: Reuses active instance across navigation stack.
   - `context.create<UserGraft>()`: Creates isolated instance.
   - `GraftRouteObserver`: Automatically cleans up instances when the owner screen pops.
6. **Fine-Grained Slot Diffing**:
   - `graft.column((s) => [ ... ])` with const widgets and dynamic slots.
   - `graft.listTile(...)` with independent slot rebuilds.
   - `graft.card(...)` and `graft.padding(...)`.
   - `graft.select(...)` for granular sub-property listeners.

## Running the Example:

```bash
cd example
flutter run
```

# LiveView JavaScript Interop (Extracted)

## LiveView JavaScript interop

- Remember anytime you use `phx-hook="MyHook"` and that JS hook manages its own DOM, you **must** also set the `phx-update="ignore"` attribute.
- **Always** provide an unique DOM id alongside `phx-hook` otherwise a compiler error will be raised.

LiveView hooks come in two flavors, 1) colocated js hooks for "inline" scripts defined inside HEEx,
and 2) external `phx-hook` annotations where JavaScript object literals are defined and passed to the `LiveSocket` constructor.

## Inline colocated js hooks

**Never** write raw embedded `<script>` tags in heex as they are incompatible with LiveView.
Instead, **always use a colocated js hook script tag (`:type={Phoenix.LiveView.ColocatedHook}`)
when writing scripts inside the template**:

```heex
<input type="text" name="user[phone_number]" id="user-phone-number" phx-hook=".PhoneNumber" />
<script :type={Phoenix.LiveView.ColocatedHook} name=".PhoneNumber">
  export default {
    mounted() {
      this.el.addEventListener("input", e => {
        let match = this.el.value.replace(/\D/g, "").match(/^(\d{3})(\d{3})(\d{4})$/)
        if(match) {
          this.el.value = `${match[1]}-${match[2]}-${match[3]}`
        }
      })
    }
  }
</script>
```

- colocated hooks are automatically integrated into the app.js bundle.
- colocated hooks names **MUST ALWAYS** start with a `.` prefix, i.e. `.PhoneNumber`.

## External phx-hook

External JS hooks (`<div id="myhook" phx-hook="MyHook">`) must be placed in `assets/js/` and passed to the
LiveSocket constructor:

```javascript
const MyHook = {
  mounted() { ... }
}
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { MyHook }
});
```

## Pushing events between client and server

Use LiveView's `push_event/3` when you need to push events/data to the client for a phx-hook to handle.
**Always** return or rebind the socket on `push_event/3` when pushing events:

```elixir
# re-bind socket so we maintain event state to be pushed
socket = push_event(socket, "my_event", %{...})

# or return the modified socket directly:
def handle_event("some_event", _, socket) do
  {:noreply, push_event(socket, "my_event", %{...})}
end
```

Pushed events can then be picked up in a JS hook with `this.handleEvent`:

```javascript
mounted() {
  this.handleEvent("my_event", data => console.log("from server:", data));
}
```

Clients can also push an event to the server and receive a reply with `this.pushEvent`:

```javascript
mounted() {
  this.el.addEventListener("click", e => {
    this.pushEvent("my_event", { one: 1 }, reply => console.log("got reply from server:", reply));
  })
}
```

Where the server handled it via:

```elixir
def handle_event("my_event", %{"one" => 1}, socket) do
  {:reply, %{two: 2}, socket}
end
```

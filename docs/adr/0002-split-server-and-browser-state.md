---
status: accepted
---

# Split state ownership between LiveView and browser hooks

PUI keeps submitted values, validation, and application-visible decisions in LiveView while hooks own ephemeral browser interaction such as focus, positioning, keyboard navigation, measurement, and transient visibility. This avoids turning every interaction into a server round trip while preserving server authority where a value affects forms or application behavior; the consequence is a deliberate synchronization contract through rendered attributes, native events, LiveView events, and custom PUI events.

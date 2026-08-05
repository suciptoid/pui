defmodule PUI.FlashTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest

  test "flash groups expose position, stack, timeout, and close contracts" do
    assigns = %{flash: %{success: "Saved"}}

    html =
      rendered_to_string(~H"""
      <PUI.Flash.flash_group
        flash={@flash}
        id="notifications"
        position="bottom-right"
        stacked={false}
        auto_dismiss={3000}
      />
      """)

    assert html =~ ~s(id="notifications")
    assert html =~ ~s(data-position="bottom-right")
    assert html =~ ~s(data-stacked="false")
    assert html =~ ~s(data-flash-timeout="3000")
    assert html =~ ~s(data-timeout="3000")
    assert html =~ ~s(type="button")
    assert html =~ ~s(aria-label="Dismiss notification")
    assert html =~ "right-[1rem]"
    assert html =~ "left-[1rem]"
  end

  test "a message can override the group position" do
    assigns = %{flash: %{success: {"bottom-left", "Saved in the corner"}}}

    html =
      rendered_to_string(~H"""
      <PUI.Flash.flash_group flash={@flash} position="top-center" />
      """)

    assert html =~ "Saved in the corner"
    assert html =~ ~s(data-position="bottom-left")
  end

  test "flash groups default to expanded messages" do
    assigns = %{flash: %{success: "Saved"}}

    html =
      rendered_to_string(~H"""
      <PUI.Flash.flash_group flash={@flash} />
      """)

    assert html =~ ~s(data-stacked="false")
  end

  test "primitive flash containers default to expanded messages" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <PUI.Flash.Primitive.container id="primitive-flashes">
        <PUI.Flash.Primitive.toast id="primitive-toast">
          Primitive message
        </PUI.Flash.Primitive.toast>
      </PUI.Flash.Primitive.container>
      """)

    assert html =~ ~s(data-stacked="false")
  end

  test "send_flash accepts a trigger-level position override" do
    assert {:ok, %PUI.Flash.Message{position: "bottom-right"}} =
             PUI.Flash.send_flash(self(), "Copied!", position: "bottom-right")
  end

  test "individual flashes accept an explicit position and timeout" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <PUI.Flash.flash
        id="manual-flash"
        position="top-left"
        timeout={1500}
        show_close={false}
      >
        Manual message
      </PUI.Flash.flash>
      """)

    assert html =~ ~s(id="manual-flash")
    assert html =~ ~s(data-position="top-left")
    assert html =~ ~s(data-timeout="1500")
    refute html =~ ~s(data-close)
  end

  test "preset flashes use a constrained card layout for multiline messages" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <PUI.Flash.flash id="preset-flash" preset type={:success}>
        A message that can wrap onto more than one line.
      </PUI.Flash.flash>
      """)

    assert html =~ "w-fit"
    assert html =~ "min-w-[200px]"
    assert html =~ "max-w-md"
    assert html =~ "rounded-xl"
    assert html =~ "shrink-0"
    assert html =~ "min-w-0"
    assert html =~ "flex-1"
    refute html =~ "bg-black"
    refute html =~ "rounded-full"
    refute html =~ "truncate"
  end

  test "stacked indicators keep only behind message bodies hidden" do
    assigns = %{flash: %{success: "Saved", info: "Synced"}}

    html =
      rendered_to_string(~H"""
      <PUI.Flash.flash_group flash={@flash} stacked />
      """)

    assert html =~ "Saved"
    assert html =~ "Synced"
    assert html =~ "data-[behind=true]:opacity-0"
  end

  test "collapsed stacks expose one flash and expand on hover" do
    hook = File.read!(Path.join([File.cwd!(), "assets", "js", "flash.js"]))

    assert hook =~ "flash.dataset.visible = String(visible);"
    assert hook =~ "content.dataset.behind = String(behind)"
    assert hook =~ "this.#expandedPositions.add(position);"
  end

  test "collapsed stack cards use a peek offset from the front card" do
    hook = File.read!(Path.join([File.cwd!(), "assets", "js", "flash.js"]))

    assert hook =~ "const translation = expanded"
    assert hook =~ "index * STACK_PEEK"
    assert hook =~ "if (expanded)"
  end

  test "expanded stack gaps keep pointer hover inside the notification" do
    hook = File.read!(Path.join([File.cwd!(), "assets", "js", "flash.js"]))

    assert hook =~ "flash.dataset.expanded = String(expanded);"
    assert hook =~ "\"data-expanded\""

    assigns = %{flash: %{success: "Saved", info: "Synced"}}

    html =
      rendered_to_string(~H"""
      <PUI.Flash.flash_group flash={@flash} stacked />
      """)

    assert html =~ "after:pointer-events-none"
    assert html =~ "data-[expanded=true]:after:pointer-events-auto"
    assert html =~ "data-[position^=&#39;top-&#39;]:after:-bottom-[10px]"
    assert html =~ "data-[position^=&#39;bottom-&#39;]:after:-top-[10px]"
  end

  test "hovering a flash pauses every timer in its position group" do
    hook = File.read!(Path.join([File.cwd!(), "assets", "js", "flash.js"]))

    assert hook =~ "const position = this._positionFor(flash);"
    assert hook =~ "this._pausePositionTimers(position);"
    assert hook =~ "this._resumePositionTimers(position);"
    assert hook =~ "this._positionIsActive(position)"
  end

  test "collapsed stacks cap visible indicators and allow indicator hover" do
    hook = File.read!(Path.join([File.cwd!(), "assets", "js", "flash.js"]))

    assert hook =~ "const MAX_STACK_INDICATORS = 3;"
    assert hook =~ "const visible = expanded || index <= MAX_STACK_INDICATORS;"
    assert hook =~ "flash.dataset.visible = String(visible);"
    assert hook =~ "flash.inert = !visible;"

    assigns = %{flash: %{success: "Saved", info: "Synced"}}

    html =
      rendered_to_string(~H"""
      <PUI.Flash.flash_group flash={@flash} stacked />
      """)

    assert html =~ "data-[visible=true]:pointer-events-auto"
    assert html =~ "data-[visible=false]:pointer-events-none"
  end

  test "the primitive shares the flash hook data contract" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <PUI.Flash.Primitive.container
        id="primitive-flashes"
        position="bottom-center"
        stacked={false}
        timeout={2000}
      >
        <PUI.Flash.Primitive.toast id="primitive-toast" timeout={1200}>
          Primitive message
        </PUI.Flash.Primitive.toast>
      </PUI.Flash.Primitive.container>
      """)

    assert html =~ ~s(phx-hook="PUI.FlashGroup")
    assert html =~ ~s(data-position="bottom-center")
    assert html =~ ~s(data-stacked="false")
    assert html =~ ~s(data-flash-timeout="2000")
    assert html =~ ~s(data-timeout="1200")
  end
end

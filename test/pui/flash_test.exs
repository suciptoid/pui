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

  test "flash groups default to three messages" do
    assigns = %{
      flash: %{
        success: "Saved",
        info: "Synced",
        warning: "Soon",
        error: "Failed"
      }
    }

    html =
      rendered_to_string(~H"""
      <PUI.Flash.flash_group flash={@flash} />
      """)

    assert html |> String.split(~s(data-preset="true")) |> length() == 4
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

  test "message defaults are stable except for the generated id" do
    message = PUI.Flash.Message.new("Saved")
    empty_message = PUI.Flash.Message.new()

    assert message.message == "Saved"
    assert empty_message.message == ""
    assert message.type == nil
    assert message.position == nil
    assert message.preset == false
    assert String.starts_with?(message.id, "fl")
  end

  test "preset flash icons cover every semantic type and fall back to info" do
    for type <- [:success, :error, :warning, :info, :custom] do
      html =
        render_component(&PUI.Flash.flash/1,
          id: "flash-#{type}",
          type: type,
          preset: true,
          show_close: false,
          inner_block: [%{inner_block: fn _, _ -> "Message" end}]
        )

      expected_icon =
        %{
          success: "hero-check-circle",
          error: "hero-x-circle",
          warning: "hero-exclamation-triangle",
          info: "hero-information-circle",
          custom: "hero-information-circle"
        }[type]

      assert html =~ expected_icon
      refute html =~ ~s(data-close)
    end
  end

  test "flash groups map message structs and string keys with overrides" do
    message = %PUI.Flash.Message{
      message: "Updated",
      position: "bottom-left",
      duration: 2_000,
      auto_dismiss: false,
      dismissable: false,
      show_close: false
    }

    assigns = %{flash: %{"success" => message, warning: {"top-right", "Soon"}}}

    html =
      rendered_to_string(~H"""
      <PUI.Flash.flash_group flash={@flash} position="top-center" show_close />
      """)

    assert html =~ "Updated"
    assert html =~ "Soon"
    assert html =~ ~s(data-position="bottom-left")
    assert html =~ ~s(data-timeout="0")
    assert html =~ ~s(data-position="top-right")
    assert html =~ ~s(data-preset="true")
  end

  test "flash groups honor limits and disabled auto dismissal" do
    assigns = %{
      flash: %{success: "Saved", info: "Synced", warning: "Soon"},
      limit: 2,
      auto_dismiss: false
    }

    html =
      rendered_to_string(~H"""
      <PUI.Flash.flash_group flash={@flash} limit={@limit} auto_dismiss={@auto_dismiss} />
      """)

    assert html =~ ~s(data-flash-timeout="0")
    assert html |> String.split(~s(role="alert")) |> length() == 3
    assert Enum.count(["Saved", "Synced", "Soon"], &String.contains?(html, &1)) == 2
  end

  test "flash update helpers prepare positions and preset messages" do
    assert {:ok, flash} =
             PUI.Flash.send_flash(
               self(),
               %PUI.Flash.Message{message: "Saved", type: :success},
               position: "bottom-center"
             )

    assert flash.position == "bottom-center"
    assert flash.preset
    assert_receive {:phoenix, :send_update, _message}

    update = %PUI.Flash.Message{message: "Updated", type: :success}
    assert {:ok, updated} = PUI.Flash.update_flash(self(), update)
    assert updated.preset
    assert is_binary(updated.id)
    assert_receive {:phoenix, :send_update, _message}
  end

  test "flash groups handle indefinite and custom message durations" do
    assigns = %{
      flash: %{
        info: %PUI.Flash.Message{message: "Open", duration: -1},
        success: %PUI.Flash.Message{message: "Short", duration: 3}
      }
    }

    html =
      rendered_to_string(~H"""
      <PUI.Flash.flash_group flash={@flash} auto_dismiss={2500} />
      """)

    assert html =~ "Open"
    assert html =~ "Short"
    assert html =~ ~s(data-timeout="0")
    assert html =~ ~s(data-timeout="3000")
  end

  test "flash helpers support shorthand overloads and reject invalid positions" do
    assert {:ok, sent} = PUI.Flash.send_flash("Copied!", position: "top-left")
    assert sent.position == "top-left"
    assert_receive {:phoenix, :send_update, _message}

    assert {:ok, simple} = PUI.Flash.send_flash("Simple")
    assert simple.message == "Simple"
    assert_receive {:phoenix, :send_update, _message}

    assert {:ok, direct} =
             PUI.Flash.send_flash(%PUI.Flash.Message{message: "Direct", type: :info})

    assert direct.preset
    assert_receive {:phoenix, :send_update, _message}

    assert {:ok, pid_direct} =
             PUI.Flash.send_flash(self(), %PUI.Flash.Message{message: "PID direct"})

    assert pid_direct.message == "PID direct"
    assert_receive {:phoenix, :send_update, _message}

    flash = %PUI.Flash.Message{id: "existing", message: "Updated"}
    assert {:ok, updated} = PUI.Flash.update_flash(flash)
    assert updated.id == "existing"
    assert_receive {:phoenix, :send_update, _message}

    assert {:ok, pid_updated} = PUI.Flash.update_flash(self(), flash)
    assert pid_updated.id == "existing"
    assert_receive {:phoenix, :send_update, _message}

    assert_raise ArgumentError, ~r/invalid flash position/, fn ->
      PUI.Flash.send_flash("Broken", position: "middle")
    end
  end

  test "live component lifecycle mounts, updates, renders, and dismisses streams" do
    {:ok, socket} = PUI.Flash.mount(flash_socket())

    assert {:ok, socket} =
             PUI.Flash.update(
               %{
                 id: "notifications",
                 flash: %{success: "Saved"},
                 limit: 2,
                 position: "top-right",
                 stacked: true,
                 auto_dismiss: 1000,
                 show_close: true
               },
               socket
             )

    assert socket.assigns.id == "notifications"
    assert socket.assigns.limit == 2
    assert socket.assigns.position == "top-right"
    assert socket.assigns.stacked
    assert socket.assigns.auto_dismiss == 1000
    assert %Phoenix.LiveView.Rendered{} = PUI.Flash.render(socket.assigns)

    flash = %PUI.Flash.Message{id: "existing", message: "First", type: :info}
    assert {:ok, socket} = PUI.Flash.update(%{from: :send_flash, flash: flash}, socket)

    updated = %{flash | message: "Updated"}
    assert {:ok, socket} = PUI.Flash.update(%{from: :update_flash, flash: updated}, socket)

    assert {:noreply, _socket} =
             PUI.Flash.handle_event("dismiss_flash", %{"id" => "flash-existing"}, socket)
  end

  test "flash groups support the live component branch" do
    rendered =
      PUI.Flash.flash_group(%{
        id: "live-flashes",
        flash: %{},
        live: true,
        limit: 2,
        position: "top-right",
        stacked: true,
        auto_dismiss: 1000,
        show_close: false
      })

    assert %Phoenix.LiveView.Rendered{} = rendered
  end

  test "flash mapping ignores unsupported keys and preserves non-position tuples" do
    assigns = %{
      flash: %{
        "flash.custom" => "Custom",
        :ignored => "Ignored",
        123 => "Skipped",
        :success => {"invalid-position", "Fallback"}
      },
      auto_dismiss: "invalid"
    }

    html =
      rendered_to_string(~H"""
      <PUI.Flash.flash_group flash={@flash} auto_dismiss={@auto_dismiss} />
      """)

    assert html =~ "Custom"
    assert html =~ "Fallback"
    refute html =~ "Ignored"
    refute html =~ "Skipped"
    assert html =~ ~s(data-flash-timeout="5000")
  end

  defp flash_socket do
    lifecycle = %{
      after_render: [],
      handle_async: [],
      handle_event: [],
      handle_info: [],
      handle_params: [],
      mount: []
    }

    %Phoenix.LiveView.Socket{
      private: %{live_temp: %{}, lifecycle: lifecycle}
    }
  end
end

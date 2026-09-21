set -l tide_configure_args \
    --auto \
    --style=Lean \
    --prompt_colors='16 colors' \
    --show_time='24-hour format' \
    --lean_prompt_height='Two lines' \
    --prompt_connection=Dotted \
    --prompt_connection_andor_frame_color=Lightest \
    --prompt_spacing=Sparse \
    --icons='Few icons' \
    --transient=No

if status is-interactive; and type -q tide
    set -l expected (string join ' ' -- $tide_configure_args)
    if test "$expected" != "$tide_config_applied_args"
        tide configure $tide_configure_args
        and set -U tide_config_applied_args $expected
    end
end

set -g tide_left_prompt_items context pwd git newline nix_shell character
set -g tide_right_prompt_items status cmd_duration jobs direnv bun node python rustc java php pulumi ruby go gcloud kubectl distrobox toolbox terraform aws crystal elixir zig time
set -g tide_left_prompt_suffix ' '

function _tide_item_character
    test $_tide_status = 0 && set_color $tide_character_color || set_color $tide_character_color_failure

    set -q add_prefix || echo -ns ' '

    test "$fish_key_bindings" = fish_default_key_bindings && echo -ns $tide_character_icon ||
        switch $fish_bind_mode
            case insert
                echo -ns $tide_character_icon
            case default
                echo -ns $tide_character_vi_icon_default
            case replace replace_one
                echo -ns $tide_character_vi_icon_replace
            case visual
                echo -ns $tide_character_vi_icon_visual
        end

    set -g add_prefix
end

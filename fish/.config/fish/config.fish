# =============================================================================
#  LOAD SENSITIVE ENVIRONMENT VARIABLES (e.g., API Keys)
# =============================================================================
# This block checks for a 'secrets.fish' file and sources it if it exists.
# This file is intended for API keys and other secrets and should be in .gitignore.
# =============================================================================
if test -f ~/.config/fish/secrets.fish
    source ~/.config/fish/secrets.fish
end

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# --- Aliases & Environment Variables ---
alias cat 'bat --paging=never'
set -gx VISUAL nvim

# --- Tool Initializations ---
zoxide init fish | source

# =============================================================================
#  CUSTOM FUNCTION: wl-copy with a specific terminal notification
# =============================================================================
# This function wraps 'wl-copy' for terminal-specific pipe operations.
# It uses a backwards-compatible method to check for success.
#
# Usage: echo "some text" | copy
# =============================================================================
function copy --wraps wl-copy --description "Pipe content to wl-copy and send a terminal-specific notification"
    # Execute the original wl-copy command
    command wl-copy $argv

    # Check the exit status in a universally compatible way.
    # If the exit code ($status) is 0, the command was successful.
    if test $status -eq 0
        # Send a notification that clearly indicates the source is the terminal.
        notify-send -a "Terminal" -i "utilities-terminal" "复制成功 (来自终端)" "内容已通过管道命令保存"
    end
end

starship init fish | source

fish_add_path $HOME/.local/bin

# 设置 Android SDK 的根目录
set -x ANDROID_SDK_ROOT "/opt/android-sdk"
set -x ANDROID_AVD_HOME "$HOME/.android/avd"
fish_add_path $ANDROID_SDK_ROOT/cmdline-tools/latest/bin
fish_add_path $ANDROID_SDK_ROOT/platform-tools
fish_add_path $ANDROID_SDK_ROOT/emulator
fish_add_path ~/.npm-global/bin
set -gx ANTHROPIC_API_KEY 'sk-IRxC3rkZofNlJPMuJ22CqD3FTQcAagCtX74UTOvGISso0LWm'
set -gx ANTHROPIC_AUTH_TOKEN 'sk-IRxC3rkZofNlJPMuJ22CqD3FTQcAagCtX74UTOvGISso0LWm'
set -gx ANTHROPIC_BASE_URL 'https://code.ppchat.vip'

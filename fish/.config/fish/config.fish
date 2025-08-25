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



# Android SDK
set -x ANDROID_HOME /opt/android-sdk
set -x ANDROID_SDK_ROOT $ANDROID_HOME

set -x PATH $PATH $ANDROID_HOME/cmdline-tools/latest/bin
set -x PATH $PATH $ANDROID_HOME/emulator
set -x PATH $PATH $ANDROID_HOME/platform-tools

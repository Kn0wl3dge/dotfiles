. ~/.config/bash/config.bash

# Screen configuration
if [ "$(tty)" = "/dev/tty1" ]; then
        exec sway
fi


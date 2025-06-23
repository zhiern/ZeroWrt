# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/bin

export PATH

# Automatically execute ZeroWrt every time you connect to ssh
if [ -x /bin/ZeroWrt ]; then
    /bin/ZeroWrt
fi

#!/bin/bash

# First check the hostname
IP_ADDRESS=$(ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')
DNS_HOSTNAME=$(dig +noall +answer -x $IP_ADDRESS | cut -f4 | cut -d \. -f 1)
CUR_HOSTNAME=$(hostname)

if [ "$DNS_HOSTNAME" != "$CUR_HOSTNAME" ]; then
	echo "Hostname incorrect got $DNS_HOSTNAME from DNS, but current is $CUR_HOSTNAME"
	hostname $DNS_HOSTNAME
	sed -i "s/$CUR_HOSTNAME/$DNS_HOSTNAME/g" /etc/hosts
	echo "Changed hostname"
else
	echo "Hostname $CUR_HOSTNAME is correct"
fi

# Then start the autojudge
/opt/domjudge/judgehost/bin/create_cgroups
killall tmux agetty || true
sleep 1
openvt -c1 -f -- su domjudge -c "tmux new-session -d '/opt/domjudge/judgehost/bin/judgedaemon; killall tmux' \; split-window -d 'htop' \; attach; tail /opt/domjudge/judgehost/log/judge.`hostname`.log; echo; echo -e \"\033[1;31mJUDGE DAEMON TERMINATED!\"; tput sgr0"

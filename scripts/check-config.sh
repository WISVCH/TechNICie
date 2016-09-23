#!/bin/bash

PKG_WINDOW_MANAGERS="gnome-shell xfce4 plasma-desktop"
PKG_COMPILERS="gcc g++ openjdk-8-jdk scala python2.7 python3 mono-devel haskell-platform libghc-*-dev"
PKG_EDITORS="emacs vim netbeans monodevelop nano kate gedit geany kwrite kdevelop codeblocks joe"
PKG_OTHERS="cups-bsd konsole make cmake kdbg gdb valgrind kcachegrind perl git screen galculator sdb"
OPT_PROGS_NAMES="Sublime Text 3:IntelliJ IDEA:Eclipse"
OPT_PROGS_BINARY="subl:intellij:eclipse"
OPT_PROGS_COMMAND="subl:bin/idea.sh:eclipse"
OPT_PROGS_VERSION_COMMANDS="subl --version | grep -oP 'Build \d+$':cat /opt/intellij/build.txt:grep -oP '(?<=version=)[\d.]+' /opt/eclipse/.eclipseproduct"


# CONTEST_HOSTS are hosts that should be in /etc/hosts
CONTEST_HOSTS="chipcie.ch.tudelft.nl"

JAVA_VERSION="1\.8.*"
SSH_KEY_JORAI="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAr4Z4mZu7Xi4rfZvPsLbeGUtZC8eqLxgTNjR38zFB539diSS1WliQ/ipSjAdNhUkI5mFZVOPMpVOMDFR8H+0cKEBkFZ3qyBvRjMMOhA7QPFT3HfS1V9JJSeddvejOeuNNK8DrLE9OY4ppBewi0DdVFaZVEe3DRqvh12NTXnGQ9VSMkwPtaHworhVnpPIx/jq/ioQaQQn4pJ6OQZXiFEFjKHNvGJXeJXG4dtr7mF+nJ1sscPBNB0pDiaMWqukmnUyGxEXtPazJBilw+sXPQKziPLa8sBG6rBDOGG0I3qbdw+xE7lWJ5sa1wuSWSYuEMnyYV5JahshDn9l6PqKVV7t/pw== Jorai@JORAI-PC"
SSH_KEY_WIM="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCsi3m+Ssu6zWoSceAsUe/zJF0EvUsNh/7QpQ8bCIyCHPz5ocmOn2qVOy10iV3bVVFAoW6nSUwmxdtVtuu/Z3JEztMzLmQIqQfJARBoVRsgaiYezP2PaFGH+XIU7d5ISFMFA2XlHcCTDhArMb551yag/suwFFXle9+3Myal2W4/iIe0nPBelnQ3GeDIzZYETxIQYrsjxxB5FGAfqzzPMVLW+p6AKFDriL/nrfNcMoXi+KqfsluuSq8YHhq+dkqPuFronToLAWyyHFr5krhLepkxFyuRuUYSkUaqDrsLxqm9dMRvQdSCDJQIMyPMPfK3GdoHMhN+sq/mkpbQC1iPvGd1XHxyQ+OJGobBc4H74oethqh8GHABuli3pa8kO/NikJQ4EhkO4XeGp179bj+ZKJ3Z1lshGzpdk18dGqv2MMbWGprUV3QlS1yWVhiVY6yFLzQyO/EoZFOBp8RDCnBckZGMEyZbMZaMPUwEOGD5xQI1Z1hdB8gdTLOnw5e9tb2W+N1DtKj9oCg08+I8z/apODopdcmFS6cIF+z7NSg9me3yT7uJIyhs6w9d0nUvbc7hxvOH0ebBYTrlDYujhqq556aDjRCneSyVI0aLkZrdtHVWBr6d4LZMr487pLsNV/nXhKF7CqvrYlFDrhewntnLyHmaUrNkmvrSCFisPxtcUCxjfw== wimw@ch.tudelft.nl"

# HIER BEGINT HET SCRIPT
PKG_MISSING=""
EXECUTE_CMD=""
PACKAGE_SEARCH=""
clear
echo "████████╗███████╗ ██████╗██╗  ██╗███╗   ██╗██╗ ██████╗██╗███████╗
╚══██╔══╝██╔════╝██╔════╝██║  ██║████╗  ██║██║██╔════╝██║██╔════╝
   ██║   █████╗  ██║     ███████║██╔██╗ ██║██║██║     ██║█████╗
   ██║   ██╔══╝  ██║     ██╔══██║██║╚██╗██║██║██║     ██║██╔══╝
   ██║   ███████╗╚██████╗██║  ██║██║ ╚████║██║╚██████╗██║███████╗
   ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝ ╚═════╝╚═╝╚══════╝"
echo "Supergaafe auto checking script"

if [ -z "$1" ]; then
	COMP="team"
else
	COMP=$1
fi
echo "Check a $COMP computer"
echo

# Check if package (wildward allowd) is installed
function check_pkg {
	PKG_QUERY=$(dpkg-query -W $1 2>/dev/null)
	PKG_LINES=$(echo "$PKG_QUERY" | wc -l)

	# If we got no lines say we are missing the package
	if [[ $PKG_LINES -lt 2 ]]; then
		PKG_VERSION=$(echo "$PKG_QUERY" | cut -f2)
		if [[ $PKG_VERSION != "" ]]; then
			echo "$1: $PKG_VERSION"
		else
			PKG_MISSING+=" $1"
			echo "[ERROR] $1 is not installed!"
		fi
	else
		# Go trough all packages returned
		PKG_LIST_MISS=0
		for line in $PKG_QUERY; do
			PKG_NAME=$(echo "$line" | cut -f1)
			PKG_VERSION=$(echo "$line" | cut -f2)
			if [[ $PKG_VERSION == "" ]]; then
				PKG_LIST_MISS=1
			fi
		done

		if [[ $PKG_LIST_MISS -lt 1 ]]; then
			echo "$1: ALL installed"
		else
			PKG_MISSING+=" $1"
			echo "[ERROR] $1 is not installed!"
		fi
	fi
}

# Check if a package list is installed
function check_pkg_list {
	for p in $@
	do
		check_pkg $p
	done
}

# Check if hosts rule for contest server is defined in /etc/hosts
function check_contest_hosts {
	for host in $@
	do
		expected=$(dig +time=1 +short $host)
		search_res=($(grep -P "^\s*[^#\s]+\s+$host\s*$" /etc/hosts))
		offline=false

		if [ -n $(grep "connection timed out" <<< "${search_res[*]}") ]; then
			offline=true
			expected="<insert ip>"
		fi
		if [[ $search_res ]]; then
			if [ "${search_res[0]}" == "$expected" ] || [ "$offline" == true ]; then
				echo "$host present in /etc/hosts as mapping to ${search_res[0]}"
			else
				echo "[ERROR] $host present in /etc/hosts, but as ${search_res[0]} instead of detected $expected"
				search_format=$(echo "${search_res[*]}" | sed 's/\./\\./g' | sed 's/ /\\\\t/g')
				EXECUTE_CMD+="sudo sed -i 's/$search_format/$expected\\\\t$host/g' /etc/hosts"

			fi
		else
			echo "[ERROR] $host missing from /etc/hosts"
			[[ -z "$expected" ]] && expected="<insert ip>"
			EXECUTE_CMD+="echo -e \"\\\\n${expected}\\\\t${host}\" | sudo tee -a /etc/hosts\n"
		fi		
	done
}

# Check if udev rules for internet aren't available and aren't generated anymore
function check_udev {
	# Check if persistent rules exist before next boot
	if [ -f /etc/udev/rules.d/70-persistent-net.rules ]; then
		EXECUTE_CMD+="sudo rm /etc/udev/rules.d/70-persistent-net.rules\n"
		echo "[ERROR] UDEV rules not cleared!"
	else
		echo "No udev rule found for next startup"
	fi

	# Check if regeneration of persistent rules is blocked
	if [ -f /etc/udev/rules.d/75-persistent-net-generator.rules ]; then
		if [ -s /etc/udev/rules.d/75-persistent-net-generator.rules ]; then
			EXECUTE_CMD+="sudo cat /dev/null > /etc/udev/rules.d/75-persistent-net-generator.rules\n"
			echo "[ERROR] The persistent net genrator is not cleared! (needs to be empty)"
		else
			echo "The udev rules aren't generated anymore"
		fi
	else
		EXECUTE_CMD+="sudo cat /dev/null > /etc/udev/rules.d/75-persistent-net-generator.rules\n"
		echo "[ERROR] The persistent net generator doesn't exist!"
	fi
}

# Check if eht0 is set to either auto or allow-hotplug
function check_network {
	if [[ $(grep -E "(auto|allow-hotplug) eth0" /etc/network/interfaces) ]]; then
		echo "Network device eth0 is correctly installed"
	else
		EXECUTE_CMD+="echo -e \"\\\nauto eth0\\\niface eth0 inet dhcp\\\n\" >> /etc/network/interfaces"
		echo "[ERROR] Network device eth0 is missing"
	fi
}

# Check if cups is setup corectly (printing)
function check_cups {
	if [ -f /etc/cups/client.conf ]; then
		echo "CUPS server address: `cat /etc/cups/client.conf | cut -f2`"
	else
		EXECUTE_CMD+="echo \"ServerName $SERVER_IP\" > /etc/cups/client.conf\n"
		echo "[ERROR] CUPS server address not defined!"
	fi
}

# Check if java is the correct version
function check_java {
	# Check current java and javac versions
	CUR_JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d\" -f2)
	CUR_JAVAC_VERSION=$(javac -version 2>&1 | cut -d' ' -f2)
	if [[ "$CUR_JAVA_VERSION" =~ ${JAVA_VERSION} ]]; then
		echo "Currrent java version is correct: $CUR_JAVA_VERSION"
	else
		echo "[ERROR] Incorrect version of java is selected as default! (current $CUR_JAVA_VERSION, correct $JAVA_VERSION)"
		EXECUTE_CMD+="update-alternatives --config java\n"
	fi
	if [[ "$CUR_JAVAC_VERSION" =~ ${JAVA_VERSION} ]]; then
		echo "Currrent javac version is correct: $CUR_JAVAC_VERSION"
	else
		echo "[ERROR] Incorrect version of javac is selected as default! (current $CUR_JAVAC_VERSION, correct $JAVA_VERSION)"
		EXECUTE_CMD+="update-alternatives --config javac\n"
	fi
}

# Check if SSH keys are authorized
function check_ssh {
	# Check if SSH key is installed
	if [ -f /root/.ssh/authorized_keys ]; then
		if [ -s $(grep "$@" /root/.ssh/authorized_keys 2>&1 > /dev/null) ]; then
			SSH_KEY_NAME=$(echo "$@" | cut -d' ' -f3)
			echo "Successfully set $SSH_KEY_NAME SSH key"
		else
			echo "[ERROR] No SSH key set!"
			EXECUTE_CMD+="echo \"$@\" >> /root/.ssh/authorized_keys\n"
		fi
	else
		echo "[ERROR] No SSH key set!"
		EXECUTE_CMD+="echo \"$@\" >> /root/.ssh/authorized_keys\n"
	fi
}

# Check custom installed programs in the opt dir
# $1: packages names
# $2: package symlink names
# $3: package executable names
# $4: version check commands
function check_custom_opt_programs {
	# Set delimiter to : and backup previous delimiter
	OIFS="$IFS"; IFS=":"

	names=($1)
	symlinks=($2)
	executables=($3)
	version_cmds=($4)
	amount=${#names[@]}
	for ((i=0; i<amount; i++)); do
		check_custom_opt_program "${names[$i]}" "${symlinks[$i]}" "${executables[$i]}" "${version_cmds[$i]}"	
	done

	# Restore previous delimiter
	IFS="$OIFS"
}

# Check custom installed package (/opt/<package-name>)
# $1: package name
# $2: package symlink name: /usr/local/bin/$2
# $3: package executable name: /opt/$1/$3
# $4: version check command
function check_custom_opt_program {
	if [ -f "$(which $2)" ]; then
		PACKAGE_VERSION=$(eval $4)
		echo "$1: $PACKAGE_VERSION"
	else
		if [ -f /opt/$1/$3 ]; then
			echo "[ERROR] $1 not linked to /usr/local/bin/$2"
			EXECUTE_CMD+="ln -s /opt/$1/$3 /usr/local/bin/$2"
		else
			echo "[ERROR] $1 is not installed"
			PACKAGE_SEARCH+="$1\n"
		fi
	fi
}

# Check a team pc
function check_team {
	echo "= CHECKING ="
	echo "=== Window managers ==="
	check_pkg_list $PKG_WINDOW_MANAGERS

	echo
	echo "=== Compilers ==="
	check_pkg_list $PKG_COMPILERS

	echo
	echo "=== Editors ==="
	check_pkg_list $PKG_EDITORS

	echo
	echo "=== Others ==="
	check_pkg_list $PKG_OTHERS

	echo
	echo "=== Opt Programs ==="
	check_custom_opt_programs "$OPT_PROGS_NAMES" "$OPT_PROGS_BINARY" "$OPT_PROGS_COMMAND" "$OPT_PROGS_VERSION_COMMANDS"

	echo
	echo "== Check internet =="
	check_udev
	check_network
	check_contest_hosts $CONTEST_HOSTS

	#echo
	#echo "== CUPS (printer) =="
	#check_cups

	echo
	echo "== Java check =="
	check_java

	echo
	echo "== SSH check =="
	check_ssh "$SSH_KEY_JORAI"
	check_ssh "$SSH_KEY_WIM"
}

# Check an autojudge
function check_aj {
	echo "= CHECKING ="
	echo "=== Compilers ==="
	check_pkg_list $PKG_COMPILERS

	echo
	echo "== Check internet =="
	check_udev
	check_network

	echo
	echo "== Java check =="
	check_java $JAVA_VERSION

	echo
	echo "== SSH check =="
	check_ssh "$SSH_KEY_JORAI"
	check_ssh "$SSH_KEY_WIM"
}

if [ "$COMP" == "team" ]; then
	check_team
fi
if [ "$COMP" == "aj" ]; then
	check_aj
fi

echo
echo
echo "= TODO ="
if [[ $PKG_MISSING != "" ]]; then
	echo "sudo apt-get install$PKG_MISSING"
fi

if [[ $EXECUTE_CMD != "" ]]; then
	echo -e $EXECUTE_CMD
fi

if [[ $PACKAGE_SEARCH != "" ]]; then
	echo "== Download and install the following programs =="
	echo -e $PACKAGE_SEARCH
fi

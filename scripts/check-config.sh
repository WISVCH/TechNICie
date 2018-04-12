#!/bin/bash

PKG_WINDOW_MANAGERS="gnome-shell xfce4 plasma-desktop"
PKG_COMPILERS="gcc g++ openjdk-8-jdk scala python2.7 python3 mono-devel haskell-platform libghc-*-dev"
PKG_EDITORS="emacs vim netbeans nano kate gedit geany kwrite kdevelop codeblocks joe sublime-text"
PKG_OTHERS="flatpak dnsutils cups-bsd konsole make cmake kdbg gdb valgrind kcachegrind perl git screen galculator sdb openssh-server chipcie-hostname chipcie-printer"
OPT_PROGS_DISPLAY_NAMES="IntelliJ IDEA:Eclipse"
OPT_PROGS_NAMES="intellij:eclipse"
OPT_PROGS_BINARY="intellij:eclipse"
OPT_PROGS_COMMAND="bin/idea.sh:eclipse"
OPT_PROGS_VERSION_COMMANDS="cat /opt/intellij/build.txt:grep -oP '(?<=version=)[\d.]+' /opt/eclipse/.eclipseproduct"
DEBIAN_REPOS="https://download.sublimetext.com/ https://download.docker.com/linux/debian"
PKG_FLATPAK="com.xamarin.MonoDevelop"
PKG_FLATPAK_REF="https://download.mono-project.com/repo/monodevelop.flatpakref"
PKG_FLATPAK_DISPLAY_NAMES="MonoDevelop"

# CONTEST_HOSTS are hosts that should be in /etc/hosts
CONTEST_HOSTS="chipcie.ch.tudelft.nl"

JAVA_VERSION="1\.8.*"
SSH_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDbdMwSEsgyHJkcaGQuqbUDskZ8KW5IcVBY1ALZ+X8WDhPX2b8ZW2rukxaKoRtLETzmFFuSkmxoHjYTQ2HsrADZ4e9ZPikww+7vgRZmd6fbyZw5QHJRKJ4dSBSgS6E6qniLqxJR9ymFjcXLfVC6UwCKTzpTRUmszKFvClU3d6yDJjWDEYrGCQUorGzcm1cwvamfGsrF16bym9BicZiSzBgHQUYesxksH9pGc4E5XCo3DogrslIRMrId3g4VJM2dz3yz6lN3T5bSTGNfnKl5bZx24zNHmcBt4G93Kn+RB5SRUkZJXPItCr/5hr1uM79m8+mdkLJIq2nYrTUMejgWWSQL TechNICie"

# HIER BEGINT HET SCRIPT
REPOS_MISSING=""
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

echo "Check a team computer"
echo

# Check if custom debian repo is installed
function check_debian_repo {
	REPO_QUERY=$(cat /etc/apt/sources.list /etc/apt/sources.list.d/*.list 2>/dev/null | grep '^deb ' | grep "$1")
	if [ -z "$REPO_QUERY" ]; then 
		REPOS_MISSING+="$1 "
		echo "[ERROR] Repo '$1' missing!"
	else
		echo "Repo '$1' installed"
	fi
}

# Check if a list of custom debian repos is installed
function check_debian_repos {
	for r in $@
	do
		check_debian_repo $r
	done
}

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
		([[ "$?" -eq 0 ]] && offline=false) || offline=true
		search_res=($(grep -P "^\s*[^#\s]+\s+$host\s*$" /etc/hosts))

		if [[ $search_res ]]; then
			if [ "${search_res[0]}" == "$expected" ] || [ "$offline" == true ]; then
				echo "$host present in /etc/hosts as mapping to ${search_res[0]}"
			else
				echo "[ERROR] $host present in /etc/hosts, but as ${search_res[0]} instead of detected $expected"
				search_format=$(echo "${search_res[*]}" | sed 's/\./\\./g' | sed 's/ /\\\\t/g')
				EXECUTE_CMD+="sed -i 's/$search_format/$expected\\\\t$host/g' /etc/hosts\n"

			fi
		else
			echo "[ERROR] $host missing from /etc/hosts"
			[ "$offline" == true ] && expected="<insert ip>"
			EXECUTE_CMD+="echo -e \"\\\\n${expected}\\\\t${host}\" >> /etc/hosts\n"
		fi		
	done
}

# Check if udev rules for internet aren't available and aren't generated anymore
function check_udev {
	# Check if persistent rules exist before next boot
	if [ -f /etc/udev/rules.d/70-persistent-net.rules ]; then
		EXECUTE_CMD+="rm /etc/udev/rules.d/70-persistent-net.rules\n"
		echo "[ERROR] UDEV rules not cleared!"
	else
		echo "No udev rule found for next startup"
	fi

	# Check if regeneration of persistent rules is blocked
	if [ -f /etc/udev/rules.d/75-persistent-net-generator.rules ]; then
		if [ -s /etc/udev/rules.d/75-persistent-net-generator.rules ]; then
			EXECUTE_CMD+="cat /dev/null > /etc/udev/rules.d/75-persistent-net-generator.rules\n"
			echo "[ERROR] The persistent net genrator is not cleared! (needs to be empty)"
		else
			echo "The udev rules aren't generated anymore"
		fi
	else
		EXECUTE_CMD+="cat /dev/null > /etc/udev/rules.d/75-persistent-net-generator.rules\n"
		echo "[ERROR] The persistent net generator doesn't exist!"
	fi
}

# Check if eno1 is set to either auto or allow-hotplug
function check_network {
	if [[ $(grep -E "(auto|allow-hotplug) eno1" /etc/network/interfaces 2>/dev/null) ]]; then
		echo "Network device eno1 is correctly installed"
	else
		EXECUTE_CMD+="echo -e \"\\\nauto eno1\\\niface eno1 inet dhcp\\\n\" >> /etc/network/interfaces\n"
		echo "[ERROR] Network device eno1 is missing"
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
		EXECUTE_CMD+="mkdir /root/.ssh/\ntouch /root/.ssh/authorized_keys\necho \"$@\" >> /root/.ssh/authorized_keys\n"
	fi
}

# Check custom installed programs in the opt dir
# $1: packages names
# $2: package symlink names
# $3: package executable names
# $4: version check commands
# $5: package display names
function check_custom_opt_programs {
	# Set delimiter to : and backup previous delimiter
	OIFS="$IFS"; IFS=":"

	names=($1)
	symlinks=($2)
	executables=($3)
	version_cmds=($4)
	display_names=($5)
	amount=${#names[@]}
	for ((i=0; i<amount; i++)); do
		check_custom_opt_program "${names[$i]}" "${symlinks[$i]}" "${executables[$i]}" "${version_cmds[$i]}" "${display_names[$i]}"
	done

	# Restore previous delimiter
	IFS="$OIFS"
}

# Check custom installed package (/opt/<package-name>)
# $1: package name
# $2: package symlink name: /usr/local/bin/$2
# $3: package executable name: /opt/$1/$3
# $4: version check command
# $5: package display name
function check_custom_opt_program {
	if [ -f "$(which $2 2>/dev/null)" ]; then
		PACKAGE_VERSION=$(eval $4)
		echo "$5: $PACKAGE_VERSION"
	else
		if [ -f /opt/$1/$3 ]; then
			echo "[ERROR] $5 not linked to /usr/local/bin/$2"
			EXECUTE_CMD+="ln -s /opt/$1/$3 /usr/local/bin/$2\n"
		else
			echo "[ERROR] $1 is not installed"
			PACKAGE_SEARCH+="$5 into /opt/$1/\n"
		fi
	fi
}

# Check programs installed using flatpak 
# $1: flatpak package names
# $2: flatpakref urls
# $3: package display names
function check_flatpak_list {
	if [ ! -f "$(which flatpak 2>/dev/null)" ]; then
		echo "[ERROR] flatpak is not installed, checking for flatpack programs skipped"
		return
	fi

	pkgs=($1)
	urls=($2)
	display=($3)
	amount=${#pkgs[@]}
	for ((i=0; i<amount; i++)); do
		check_flatpak_program "${pkgs[$i]}" "${urls[$i]}" "${display[$i]}"
	done
}

# Check program installed using flatpak 
# $1: flatpak package name
# $2: flatpakref url
# $3: package display name
function check_flatpak_program {
	if flatpak info "$1" >/dev/null 2>&1; then
		echo "$3: $(flatpak info "$1" -r)"
	else
		echo "[ERROR] flatpack package '$3' is not installed"
		EXECUTE_CMD+="flatpak install --from $2\n"
	fi
}

# Check a team pc
function check_team {
	echo "= CHECKING ="
	echo "=== Custom Debian Repositories ==="
	check_debian_repos $DEBIAN_REPOS

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
	check_custom_opt_programs "$OPT_PROGS_NAMES" "$OPT_PROGS_BINARY" "$OPT_PROGS_COMMAND" "$OPT_PROGS_VERSION_COMMANDS" "$OPT_PROGS_DISPLAY_NAMES"

	echo
	echo "=== Flatpak Programs =="
	check_flatpak_list "$PKG_FLATPAK" "$PKG_FLATPAK_REF" "$PKG_FLATPAK_DISPLAY_NAMES"

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
	check_ssh "$SSH_KEY"
}

check_team

echo
echo
echo "= TODO ="
if [[ $REPOS_MISSING != "" ]]; then
	for r in $REPOS_MISSING; do
		echo "Add repo '$r' to apt sources"
	done
fi
if [[ $PKG_MISSING != "" ]]; then
	echo "apt install$PKG_MISSING"
fi

if [[ $EXECUTE_CMD != "" ]]; then
	echo -e $EXECUTE_CMD
fi

if [[ $PACKAGE_SEARCH != "" ]]; then
	echo "== Download and install the following programs =="
	echo -e $PACKAGE_SEARCH
fi

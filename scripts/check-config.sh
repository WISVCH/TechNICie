#!/bin/bash

PKG_WINDOW_MANAGERS="gnome-shell xfce4 kde-plasma-desktop"
PKG_COMPILERS="gcc g++ oracle-java8-installer scala python2.7 python3 mono-devel haskell-platform libghc-*-dev"
PKG_EDITORS="emacs vim eclipse netbeans nano kate gedit geany kwrite kdevelop codeblocks joe"
PKG_OTHERS="cups-bsd konsole make cmake gdb valgrind kcachegrind perl git screen galculator"

# CONTEST_HOSTS are hosts that should be in /etc/hosts
CONTEST_HOSTS="chipcie.ch.tudelft.nl"

JAVA_VERSION="1\.8.*"
SSH_KEY_PETER="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDbWqYxep0Z4BUuEnkYbfbrduBncK7xqwh1PzR4p/kiBGFFbuj0Q8hFf4nDPS6aFdkjSnkiuvEsgP3Q+4+XxLFq00B/nb74C9he8UaVhOwLfLSBkP6ZC7OHHyQXDPj+tLlSmwtax2lLOo/W13ZoOJDl0U5eWUQ/3+oVmqpc0CmPCEVuceXAinM9VNgczdgLiDstOEkhHCKN3BFDy142MT+tkMp+2Qi8tkN7Z5RaihED4gK0iKffPrvQzIQcEP2tyRzf/BpqjPPsCOiIbvBAyqe18byI9+BTEoiLKmCclnVCxLfedDjAk/AOK86Tl5MTz15tIcZ6tV7seV9uIvSPIwNUb5xS4SKIFM9pv3CYMcFycKw923XFta1tbcGJMhv5P8XnQDnpMQpWrgoyH194QlVLOEGsJ1jfsfslcmoywhqgZSO2CTxcLOy9Lf995h4dw5MbZDj1BcPIrJV8RtJUsMjmLtV8EBMJa5Vx3i1v9JfIiT1O9yMaF2SQUEiSokTmyIASEqBkPu8Jtdps1x/qotx6fbj+YKp6itDt6ElmIiv5k6vck7a2Mehd7eEQIEI4rY3n+nO18VnoH+AO+DtKmjq2n1LhD7KqGtNg+nPbXH/e2ibKHZ4Z+0dvNjz/1F2Zbh8S/VigemVr4BCvjSrffoiwLx9jB3OYuZYcOASLSoaaVw== root@peter"
SSK_KEY_FREEK="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4/lobUfwS80++GxSvO2eRBRRa8W6p5tkelpmDaA39OksDAkBo3mBNfdDuVglF0psU0dS6wrOvg7zua23k1/PnSNehf0AQEFVl2bSj/9Lo72yLy6fMWP2yy0RyBws8Co9q26BPmcKoflsURfRRguLZgHAIFFdnevObvbSt/pkRGVBiHs9XC4fAJwAX/eVwhyaWrHHdablIQ1S3T/mtsBY5gI/j/HsuFBm0zQrOgSxgHIogn62rwgT0zhI/ShEh0FzDxnFayV3P0GEef7PmRPAeXSQcoZYFVs6hkzby9dBjsu9sR3oPRvTAShLpvi6ZeZUPJNl26KLRtjwJogxysSfzWD6icCeAwJQ2w07Wkqd74sz+Omm+Y6PbbRJZGk3ruLYOqGELhG0vtL4ReBlVEJtLED3L0DI/RBF73ShEAqEAadJGvC4AtcVnx+eYRF3aGT1kVAUJ6Aj+HGACuGA8ET01MePNfIpzbS9ay+s2rbdH549mgOnSv3HwFu9G0qWZE3SmYR1TJFH/3IoAakD3g61B7KgyDcDcLCXlvSP/1kDmebYzXHPmFdFC/Zv6n8Z7MFl1vJPP6DFiDWM79ie874ZR7z8JTWi6XpGlwURV7/sLtZHWCU5gKHSjDrmSG2YtAAwBlfJe+2pm0xvS8dLkQLlRPt9kG/uBo/N2mbOxCY+1BQ== freaky@ubuntu"


# HIER BEGINT HET SCRIPT
PKG_MISSING=""
EXECUTE_CMD=""
clear
echo "████████╗███████╗ ██████╗██╗  ██╗███╗   ██╗██╗ ██████╗██╗███████╗
╚══██╔══╝██╔════╝██╔════╝██║  ██║████╗  ██║██║██╔════╝██║██╔════╝
   ██║   █████╗  ██║     ███████║██╔██╗ ██║██║██║     ██║█████╗
   ██║   ██╔══╝  ██║     ██╔══██║██║╚██╗██║██║██║     ██║██╔══╝
   ██║   ███████╗╚██████╗██║  ██║██║ ╚████║██║╚██████╗██║███████╗
   ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝ ╚═════╝╚═╝╚══════╝"
echo "Supergaafe auto checking script"

#if [ -z "$SERVER_IP" ]; then
#	SERVER_IP=`getent hosts chipcie.ch.tudelft.nl | cut -d' ' -f1`
#fi

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
			echo "Succesfully set $SSH_KEY_NAME SSH key"
		else
			echo "[ERROR] No SSH key set!"
			EXECUTE_CMD+="echo \"$@\" >> /root/.ssh/authorized_keys\n"
		fi
	else
		echo "[ERROR] No SSH key set!"
		EXECUTE_CMD+="echo \"$@\" >> /root/.ssh/authorized_keys\n"
	fi
}

# Check if sublime 3 is installed
function check_sublime_3 {
	if [ -f $(which subl) ]; then
		SUBLIME_VERSION=$(subl --version | cut -d' ' -f4)
		echo "sublime 3: $SUBLIME_VERSION"
	else
		if [ -f /opt/sublime_text_3/sublime_text ]; then
			echo "[ERROR] sublime 3 not linked to /usr/bin/subl"
			EXECUTE_CMD+="ln -s /opt/sublime_text_3/sublime_text /usr/bin/subl\n"
		else
			echo "[ERROR] sublime 3 is not installed"
			EXECUTE_CMD+="wget http://c758482.r82.cf2.rackcdn.com/sublime_text_3_build_3065_x64.tar.bz2 && tar -xjvf sublime_text_3_build_3065_x64.tar.bz2 && mv sublime_text_3 /opt/ && ln -s /opt/sublime_text_3/sublime_text /bin/subl && rm -rf sublime_text_3_build_3065_x64.tar.bz2\n"
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
	check_sublime_3

	echo
	echo "=== Others ==="
	check_pkg_list $PKG_OTHERS

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
	check_ssh "$SSH_KEY_PETER"
	check_ssh "$SSK_KEY_FREEK"
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
	check_contest_hosts $CONTEST_HOSTS

	echo
	echo "== Java check =="
	check_java $JAVA_VERSION

	echo
	echo "== SSH check =="
	check_ssh "$SSH_KEY_PETER"
	check_ssh "$SSK_KEY_FREEK"
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

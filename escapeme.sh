#!/bin/bash

escapeme_out=""
escapeme_arg1=""
escapeme_arg2=""
escapeme_arg3=""
escapeme_arg1_sf=""
escapeme_arg1_df=""
escapeme_arg2_df=""
escapeme_twoArgs=0
escapeme_threeArgs=0
usage_error=$(echo "Usage: escapeme [-edh] (OPTIONS) Your-String-Here-And-Beyond..."; echo "Usage: escapeme -h for help";)

function BashShellDecode {
	#decode
	#transform="$escapeme_decode"; echo "$transform" | sed 's@\\\ @\ @g' | sed 's@\\\\@\\\/@g' | sed 's@\\\\@\\@g' | sed 's@\\\/@\\@g'  #testfunction

	#escapeme_decode='test\\\\ test2\\\ test3\ test4 '   #testvalue1
	#should produce "test\\ test2\ test3 test4"	
		
	#escapeme_decode='test\\\\\\ test2\\\\\ test3\\\ test4\ '   #testvalue2
	#should produce "test\\\ test2\\ test3\ test4 "
	
	#escapeme_decode='test\\\\\\ test2\\\\\ test3\\\ test4\ \n'   #testvalue3
	#should produce "test\\\ test2\\ test3\ test4 \n"
	
	#escapeme_decode='test\\\\\ test2\\\ test3\ test4\n'   #testvalue3
	#should produce 'test\\ test2\ test3 test4\n'
	
	echo "${@}" | sed 's@\\\ @\ @g' | sed 's@\\\\@\\\/@g' | sed 's@\\\\@\\@g' | sed 's@\\\/@\\@g'
}

function BashShellEncode {
	#transform="$escapeme_encode"; echo "$transform" | sed 's@\ @\\\ @g' | sed 's@\\n@\\\/n@g' | sed 's@\\@\\\\@g' | sed 's@\\\\/@\\@g' | sed 's@\\\\\ @\\ @g'  #testfunction

	#escapeme_encode='test\\ test2\ test3 test4'   #testvalue
	#should produce "test\\\\\ test2\\\ test3\ test4"

	#escapeme_encode='test\\\ test2\\ test3\ test4 \n'   #testvalue2
	#should produce "test\\\\\\\ test2\\\\\ test3\\\ test4\ \n"
	
	#escapeme_encode='test\\ test2\ test3 test4\n'   #testvalue3
	#should produce "test\\\\\ test2\\\ test3\ test4\n"

	#escape escaped spaces, then escaped backslashes, then non-escaped spaces 
	echo "${@}" | sed 's@\ @\\\ @g' | sed 's@\\n@\\\/n@g' | sed 's@\\@\\\\@g' | sed 's@\\\\/@\\@g' | sed 's@\\\\\ @\\ @g'


}

function EscapemeDecode {
	#decode
	#should produce "test\\ test2\ test3 test4"
	#escapeme_decode='test\\\\ test2\\\ test3\ test4 '   #testvalue1
	#should produce "test\\ test2\ test3 test4"
	#escapeme_decode='test\\\\ test2\\\ test3\ test4 '   #testvalue2
	#transform="$escapeme_decode"; echo "$transform" | sed 's@\\\\@\\\/@g' | sed 's@\\\ @\ @g' | sed 's@\\\/@\\@g'  #testfunction
	echo "${@}" | sed 's@\\\ @\ @g' | sed 's@\\\\@\\\/@g' | sed 's@\\\\@\\@g' | sed 's@\\\/@\\@g'
}

function EscapemeEncode {
	#escape escaped spaces, then escaped backslashes, then non-escaped spaces 
	echo "${@}" | sed 's@\ @\\\ @g' | sed 's@\\n@\\\/n@g' | sed 's@\\@\\\\@g' | sed 's@\\\\/@\\@g' | sed 's@\\\\\ @\\ @g'
	#escapeme_encode='test\\ test2\ test3 test4 '   #testvalue
	#transform="$escapeme_encode"; echo "$transform" | sed sed 's@\\\ @\\\\\\\ @g' | sed 's@\\\\@\\\/\\\/@g' | sed 's@\ @\\\ @g'  #testfunction
}

if [ ! -z "${1}" ];
then
	

	escapeme_arg1="${1}";
	#Comment regarding NESC_OUT_DIR and NESC_FILE
	#These variables exist for convenience in circumstances where an escaped system path is ...
	#not necessary or in fact counter-productive
	#The sed pattern will preserve
	NESC_OUT_DIR="$(echo $filename | sed 's@\\@\\/\\/@g' | sed 's@\\\\@\\@g' | sed 's@\\/\\/@\\@g')"
	NESC_FILE="$(echo $FILE | sed 's@\\@\\/\\/@g' | sed 's@\\\\@\\@g' | sed 's@\\/\\/@\\@g')"
	shift;
	if [ ! -z "$@" ];
	then
	  	escapeme_twoArgs=1;
		escapeme_arg2="${1}";
		shift;
	fi
	if [ ! -z "$@" ];
	then
		escapeme_threeArgs=1;
		escapeme_arg3="${@}"
	fi
	
	escapeme_arg1_sf="${escapeme_arg1%-*}";
	escapeme_arg1_df="${escapeme_arg1%--*}";
	
	if [ -z "$escapeme_arg1_sf" ] || [ -z "$escapeme_arg1_df" ];
	then
		if [ "$escapeme_arg1" == "-h" ] || [ "$escapeme_arg1" == "--help" ];
		then
			echo "Usage: escapeme [-edh] (OPTIONS) Your-String-Here-And-Beyond...";
			echo "Version 0.1 NOTE: TODO implement the functionality beyond dealing with backslashes";
			echo "escapme is a utility function for handling escape characters";
			echo "Its core use cases revolve around systems that Interpret text input (typically, string data)";
			echo "It uses the common single-backslash convention to 'escape' Special Characters found in its input";
			echo "escapeme will preserve character structures that encode or decode as valid escape sequences";
			echo "    Example: escapme \"my string data\" returns \"my\ string\ data\"";
			echo "    Example: escapme -d \"my\ string\ data\" returns \"my string data\"";
			echo "    Example: escapme -e --BashShell \"my\ string\ data\" returns \"my\ string\ data\"";
			echo "    Example: escapme -d --BashShell \"my\\\ string\\\ data\" returns \"my\ string\ data\"";
			echo "escapeme uses a default operational mode that escapes an input string, provided that the input does not match a command flag (all options listed below)";
			echo "Flags:";
			echo "  -h |  --help :    Produces this output";
			echo "  -e | --encode:    sets mode to 'encode'; adds escape characters (default)";
			echo "  -d | --decode:    sets mode to 'decode'; removes escape characters";
			echo "OPTIONS:";
			echo "     -BashShell:    encodes and decodes using a ruleset designed for the GNU Bash shell's Special Characters";
		elif [ "$escapeme_arg1" == "-e" ] || [ "$escapeme_arg1" == "--encode" ] || \
			[ "$escapeme_arg1" == "-d" ] || [ "$escapeme_arg1" == "--decode" ];
		then
				escapeme_arg2_df="${escapeme_arg2%--*}";
			if [ -z "$escapeme_arg2_df" ]; #only takes double hyphen arguments, like --BashShell
			then
				if [ "$escapeme_arg2" == "-BashShell" ];
				then
					if [ "$escapeme_arg1" == "-d" ] || [ "$escapeme_arg1" == "--decode" ];
					then					
						
					fi
				fi
			fi
			else
				if [ "$escapeme_arg1" == "-d" ] || [ "$escapeme_arg1" == "--decode" ];
				then
				
				
				
				fi
			fi
		else
			$usage_error
		fi
	else
		#escape escaped spaces, then escaped backslashes, then non-escaped spaces 
		escapeme_out=$(echo $escapeme_arg1 | sed sed 's@\\\ @\\\\\\\ @g' | sed 's@\\\\@\\\/\\\/@g' | sed 's@\ @\\\ @g')
		#escapeme_arg1="test\\ test2\ test3 test4"   #testvalue
		#transform="$escapeme_arg1"; echo "$transform" | sed sed 's@\\\ @\\\\\\\ @g' | sed 's@\\\\@\\\/\\\/@g' | sed 's@\ @\\\ @g'  #testfunction
	fi
else
	$usage_error
fi
unset escapeme_out
unset usage_error
unset escapeme_arg1
unset escapeme_arg2
unset escapeme_arg3
unset escapeme_arg1_sf
unset escapeme_arg1_df
unset escapeme_arg2_df
unset escapeme_twoArgs
unset escapeme_threeArgs

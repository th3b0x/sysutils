#!/bin/bash


#echo "start"

#if [ -z $(command -v unzip) ]; 7zip just works better.
#then
#	echo "unzip not found (remove unzip options from script or install zip)"
#	exit 1
if [ -z $(command -v gunzip) ];
then
	echo "gunzip not found (remove gunzip options from script or install gzip)"
	exit 1
elif [ -z $(command -v bunzip2) ];
then
	echo "bunzip2 not found (remove bunzip options from script or install bzip2)"
	exit 1
elif [ -z $(command -v tar) ];
then
	echo "tar not found (remove tar options from script or install tar)"
	exit 1
elif [ -z $(command -v 7za) ];
then
	echo "7zip not found (remove 7zip options from script or install p7zip)"
	exit 1
elif [ -z $(command -v sed) ];
then
	echo "sed not found (That's the seddest lack of functionality I've ever seen)"
	exit 1
else

	timestamp=$(date --utc --iso-8601=seconds)
	TARGET_DIR="$(basename "${1}")_extracted_${timestamp}"
	if [ -d "$TARGET_DIR" ];
	then
		echo "Directory $TARGET_DIR already exists (timestamp invalid, non-unique path)"
		unset timestamp
		unset TARGET_DIR
		exit 1
	fi
	mkdir $TARGET_DIR
	SOURCE_DIR="${1}"
	if [ ! -z "${2}" ] 
	then
		sau_DEBUG="DEBUG"
		echo "DEBUG ENABLED"
		if [ ! -z "TEST" ] 
		then
			TARGET_DIR="test"
			echo "TEST ENABLED"
		fi
	fi
	oIFS="$IFS"
	IFS=$'\n'
	eDIR="$(ls -1xb "$SOURCE_DIR")"
	files=("$eDIR")
	
	if [ "$sau_DEBUG" == "DEBUG" ]
	then
		echo "DEBUG: TARGET: $TARGET_DIR files: $files"
	fi
	pushd $TARGET_DIR
	for FILEPATH in ${files[@]};
	do
		#echo "Filepath: $FILEPATH"
		#FILE=$(basename -- "$FILEPATH")
		FILE="$(basename -- "$FILEPATH" |  sed 's@\\\ @\ @g' | sed 's@\\\\@\\\/@g' | sed 's@\\\\@\\@g' | sed 's@\\\/@\\@g')"
		extension="${FILE##*.}"
		filename_temp="${FILE%.*}"
		tarCheck="${filename_temp##*.}"
		if [ "$tarCheck" == "tar" ]
		then
			filename="${filename_temp%.*}"
		else
			filename="$filename_temp"
		fi
		cmd=""
		#OUT_DIR=$filename
		OUT_DIR="$(transform="$filename"; echo "$transform" | sed 's@\\\ @\ @g' | sed 's@\\\\@\\\/@g' | sed 's@\\\\@\\@g' | sed 's@\\\/@\\@g')"
		archive=0
		
		if [ "$extension" == "7z" ]
		then
			archive=1
			cmd="7za e \"../$SOURCE_DIR/$FILE\" -y -o\"$OUT_DIR\""
			#cmd="7za e \"$FILE\" -y -o\"$OUT_DIR\""
		elif [ "$extension" == "zip" ]
		then
			archive=1
			#cmd="unzip ../$SOURCE_DIR/$FILE -d $OUT_DIR"
			cmd="7za e \"../$SOURCE_DIR/$FILE\" -y -o\"$OUT_DIR\""
			#cmd="7za e \"$FILE\" -y -o\"$OUT_DIR\""
		elif [ "$extension" == "tar" ]
		then
			archive=1
			cmd="tar -xvf \"../$SOURCE_DIR/$FILE\" -C \"$OUT_DIR\""
			#cmd="tar -xvf \"$FILE\" -C \"$OUT_DIR\""
		elif [ "$extension" == "gz" ]
		then
			archive=1
			if [ "$tarCheck" == "tar" ] #.tar.gz != .gz
			then
				cmd="tar -zxvf \"../$SOURCE_DIR/$FILE\" -C \"$OUT_DIR\""
				#cmd="tar -zxvf \"$FILE\" -C \"$OUT_DIR\""
			else
				cmd="gzip -d -S \"$OUT_DIR\" \"../$SOURCE_DIR/$FILE\""
				#cmd="gzip -d -S \"$OUT_DIR\" \"$FILE\""
			fi
		elif [ "$extension" == "bz2" ]
		then
			archive=1
			if [ "$tarCheck" == "tar" ] #(.tar.bz2) != .gz
			then
				cmd="tar -jxvf \"../$SOURCE_DIR/$FILE\" -C \"$OUT_DIR\""
				#cmd="tar -jxvf \"$FILE\" -C \"$OUT_DIR\""
			else
				cmd="cp \"../$SOURCE_DIR/$FILE\" \"$OUT_DIR\" && bzip2 -d -v \"$OUT_DIR/$FILE\""
				#cmd="cp \"$FILE\" \"$OUT_DIR\" && bzip2 -d -v \"$OUT_DIR/$FILE\""
		fi
		elif [ "$extension" == "bz" ]
		then
			archive=3
			echo "\n!!!!!!!!\nWOW THAT'S OLD\nEXTENSION .bz NOT SUPPORTED\n!!!!!!!!\n"
		else
			archive=0
		fi
		
		if [ $archive == 0 ]
		then
			echo "cp ../$SOURCE_DIR/$FILE $TARGET_DIR"
			cp "../$SOURCE_DIR/$FILE" -r "." 
			#echo "cp $FILE $TARGET_DIR"
			#cp "$FILE" -r "." 
		elif [ $archive == 1 ]
		then
			#echo "$OUT_DIR"
			mkdir -p "$OUT_DIR"
			#"$cmd"
			eval "$cmd"
			#ProcessSubFolder "$OUT_DIR"
		else
			echo "Unsupported format detect"
			"../$SOURCE_DIR/$FILE\n" >> _UnhandledFiles.txt
			#"$FILE\n" >> _UnhandledFiles.txt
		fi
	done
	#echo "$TARGET_DIR" | sed 's@\ @\\\ @g' | sed 's@\\n@\\\/n@g' | sed 's@\\@\\\\@g' | sed 's@\\\\/@\\@g' | sed 's@\\\\\ @\\ @g'
	IFS=$'\n'
	cDIR="$(ls -R1xb "$(pwd)/" | sed 's@\ @\\\ @g' | sed 's@\\n@\\\/n@g' | sed 's@\\@\\\\@g' | sed 's@\\\\/@\\@g' | sed 's@\\\\\ @\\ @g')"
	cfiles=("$cDIR")
	if [ "$sau_DEBUG" == "DEBUG" ]
	then
		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		echo "Starting extract of export directory"
		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		#echo "$TARGET_DIR" | sed 's@\ @\\\ @g' | sed 's@\\n@\\\/n@g' | sed 's@\\@\\\\@g' | sed 's@\\\\/@\\@g' | sed 's@\\\\\ @\\ @g'
		echo "DEBUG: TARGET_DIR: $(pwd)"
		echo "DEBUG: files:$cfiles"
	fi
	#readarray -d \n -t files <<< "$eDIR"
	FOLDER_HEADING=""
	FOLDER_SIZE=0
	for FP in ${cfiles[@]};
	do
		fhCheck="${FP##*:}"
		FOLDERPATH="$(realpath "$FOLDER_HEADING""$FP")"
		if [ -z "$fhCheck" ];
		then
			FOLDER_HEADING="${FP%*:}/"
		elif [ ! -d "$FOLDERPATH" ]
		then
			if [ "$sau_DEBUG" == "DEBUG" ] 
			then
				printf "\n\n"
				echo "DEBUG: FP          =$FP"
				echo "DEBUG: Current File= $FOLDERPATH"
			fi
			REL_DIR="$(transform="$FOLDERPATH"; echo "$transform" |  sed 's@\\\ @\ @g' | sed 's@\\\\@\\\/@g' | sed 's@\\\\@\\@g' | sed 's@\\\/@\\@g')"
			FILE="$(basename -- "$FOLDERPATH" |  sed 's@\\\ @\ @g' | sed 's@\\\\@\\\/@g' | sed 's@\\\\@\\@g' | sed 's@\\\/@\\@g')"
			extension="${FILE##*.}"
			filename="${FILE%.*}"
			tarCheck="${filename##*.}"
			cmd=""
			#REL_SRC="${REL_DIR%/*}"
			OUT_DIR="${REL_DIR%/*}/$filename"
			#OUT_DIR=$filename
			#OUT_DIR="$(transform="$filename"; echo "$transform" | sed 's@\\\ @\ @g' | sed 's@\\\\@\\\/@g' | sed 's@\\\\@\\@g' | sed 's@\\\/@\\@g')"
			archive=0
			if [ "$sau_DEBUG" == "DEBUG" ]
			then
				echo "DEBUG: FolderHead  =$FOLDER_HEADING "
				echo "DEBUG: FOLDERPATH  =$FOLDERPATH"
				echo "DEBUG: Extension   =$extension "
				#printf "\n"
				echo "DEBUG: filename    =$filename "
				#printf "\n"
				echo "DEBUG: tarCheck    =$tarCheck "
				#printf "\n"
				echo "DEBUG: OUT_DIR     =$OUT_DIR"
			fi
			#printf "\n"
			
			if [ "$extension" == "7z" ]
			then
				archive=1
				cmd="7za x \"$FILE\" -y -o\"$OUT_DIR\""
			elif [ "$extension" == "zip" ]
			then
				archive=1
				#cmd="unzip $SOURCE_DIR/$FILE -d $OUT_DIR"
				cmd="7za x \"$FILE\" -y -o\"$OUT_DIR\""
			elif [ "$extension" == "tar" ]
			then
				archive=1
				cmd="tar -xvf \"$FILE\" --ignore-failed-read -C \"$OUT_DIR\""
			elif [ "$extension" == "gz" ]
			then
				archive=1
				if [ "$tarCheck" == "tar" ] #.tar.gz != .gz
				then
					cmd="tar -zxvf \"$FILE\" --ignore-failed-read -C \"$OUT_DIR\""
				else
					cmd="gzip -d -S \"$OUT_DIR\" \"$FILE\""
				fi
			elif [ "$extension" == "bz2" ]
			then
				archive=1
				if [ "$tarCheck" == "tar" ] #(.tar.bz2) != .gz
				then
					cmd="tar -jxvf \"$FILE\" --ignore-failed-read -C \"$OUT_DIR\""
				else
					cmd="cp \"$FILE\" \"$OUT_DIR\" && bzip2 -d -v \"$OUT_DIR/$FILE\""
			fi
			elif [ "$extension" == "bz" ]
			then
				archive=3
				echo "\n!!!!!!!!\nWOW THAT'S OLD\nEXTENSION .bz NOT SUPPORTED\n!!!!!!!!\n"
			else
				archive=0
			fi
			
			if [ $archive == 1 ]
			then
				if [ "$sau_DEBUG" == "DEBUG" ]
				then
					echo "DEBUG: ARCHIVE DETECTED"
					echo "DEBUG: Current File= $FOLDERPATH"
				fi
				#echo "$OUT_DIR"
				#pushd "$REL_DIR"
				mkdir -p "$OUT_DIR"
				#"$cmd"
				eval "$cmd"
				#ProcessSubFolder "$OUT_DIR"
				#popd
			#else
			#	echo "Unsupported format detect"
			#	"$FILE\n" >> _UnhandledFiles.txt
			fi
		else
			if [ "$sau_DEBUG" == "DEBUG" ]
			then
				printf "\n"
				echo "FOLDER DETECTED: $FP"
			fi
		fi
	done
	popd
	
	
	IFS="$oIFS"
	unset oIFS
	unset sau_DEBUG
	unset files
	unset FILE
	unset extension
	unset filename
	unset comm
	unset timestamp
	unset archive
	unset tarCheck
	unset NESC_OUT_DIR
	unset NESC_FILE
	unset SOURCE_DIR
	unset TARGET_DIR
	unset OUT_DIR
fi

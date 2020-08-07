#!/bin/bash


if [ -z $(command -v unzip) ];
then
	echo "unzip not found (remove unzip options from script or install zip)"
	exit 1
elif [ -z $(command -v gunzip) ];
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
	oIFS="$IFS"
	IFS=$'\n'
	eDIR="$(ls -1xb "$SOURCE_DIR")"
	files=("$eDIR")
	#readarray -d \n -t files <<< "$eDIR"
	pushd $TARGET_DIR
	for FILEPATH in ${files[@]};
	do
		#echo "$FILEPATH"
		#FILE=$(basename -- "$FILEPATH")
		FILE="$(basename -- "$FILEPATH" |  sed 's@\\\ @\ @g' | sed 's@\\\\@\\\/@g' | sed 's@\\\\@\\@g' | sed 's@\\\/@\\@g')"
		extension="${FILE##*.}"
		filename="${FILE%.*}"
		tarCheck="${filename##*.}"
		cmd=""
		#OUT_DIR=$filename
		OUT_DIR="$(transform="$filename"; echo "$transform" | sed 's@\\\ @\ @g' | sed 's@\\\\@\\\/@g' | sed 's@\\\\@\\@g' | sed 's@\\\/@\\@g')"
		archive=0
		#Comment regarding NESC_OUT_DIR and NESC_FILE
		#These variables exist for convenience in circumstances where an
		NESC_OUT_DIR="$(echo $filename | sed 's@\\@\\/\\/@g' | sed 's@\\\\@\\@g' | sed 's@\\/\\/@\\@g')"
		NESC_FILE="$(echo $FILE | sed 's@\\@\\/\\/@g' | sed 's@\\\\@\\@g' | sed 's@\\/\\/@\\@g')"
		
		if [ "$extension" == "7z" ]
		then
			archive=1
			cmd="7za e \"../$SOURCE_DIR/$FILE\" -y -o\"$OUT_DIR\""
		elif [ "$extension" == "zip" ]
		then
			archive=1
			#cmd="unzip ../$SOURCE_DIR/$FILE -d $OUT_DIR"
			cmd="7za e \"../$SOURCE_DIR/$FILE\" -y -o\"$OUT_DIR\""
		elif [ "$extension" == "tar" ]
		then
			archive=1
			cmd="tar -xvf \"../$SOURCE_DIR/$FILE\" -C \"$OUT_DIR\""
		elif [ "$extension" == "gz" ]
		then
			archive=1
			if [ "$tarCheck" == "tar" ] #.tar.gz != .gz
			then
				cmd="tar -zxvf \"../$SOURCE_DIR/$FILE\" -C \"$OUT_DIR\""
			else
				cmd="gzip -d -S \"$OUT_DIR\" \"../$SOURCE_DIR/$FILE\""
			fi
		elif [ "$extension" == "bz2" ]
		then
			archive=1
			if [ "$tarCheck" == "tar" ] #(.tar.bz2) != .gz
			then
				cmd="tar -jxvf \"../$SOURCE_DIR/$FILE\" -C \"$OUT_DIR\""
			else
				cmd="cp \"../$SOURCE_DIR/$FILE\" \"$OUT_DIR\" && bzip2 -d -v \"$OUT_DIR/$FILE\""
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
		elif [ $archive == 1 ]
		then
			#echo "$OUT_DIR"
			mkdir -p "$OUT_DIR"
			#"$cmd"
			eval "$cmd"
		else
			echo "Unsupported format detect"
			"../$SOURCE_DIR/$FILE\n" >> _UnhandledFiles.txt
		fi
	done
	popd

	IFS="$oIFS"
	unset oIFS
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

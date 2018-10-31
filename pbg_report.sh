#------------------------------------------------------------------------------------
#   Copyright [2018] [Parkbyunggyu as pbg]
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#------------------------------------------------------------------------------------

stty erase ^H
#------------------------------------------------------------------------------------

GBN(){
DAN=`echo $1|sed 's/^.*[0-9]//g'`
GAB=`echo $1|sed 's/'${DAN}'//g' 2>/dev/null` 
DAN=`echo $DAN | tr '[a-z]' '[A-Z]'`
if [ "$2" == "G" ]; then
	SCAL=1
elif [ "$2" == "M" ]; then
	SCAL=1024
elif [ "$2" == "B" ]; then
	SCAL=1073741824
fi
if [ "$DAN" == "" ] || [ "$DAN" == "B" ] 
then
	DAN=`echo "scale=11;1073741824 / $SCAL" | bc`
	GAB=$1
elif [ "$DAN" == "KB" ];then
	DAN=`echo "scale=11;1048576 / $SCAL" | bc`
elif [ "$DAN" == "MB" ];then
	DAN=`echo "scale=11;1024 / $SCAL" | bc`
elif [ "$DAN" == "GB" ];then
	DAN=`echo "scale=11;1 / $SCAL" | bc`
fi
a=`echo "scale=3;$GAB / $DAN"|bc`
echo $(printf %.3f $a)
}

#------------------------------------------------------------------------------------

GKN(){
DAN=`echo $1|sed 's/^.*[0-9]//g'`
GAB=`echo $1|sed 's/'${DAN}'//g' 2>/dev/null` 
DAN=`echo $DAN | tr '[a-z]' '[A-Z]'`
if [ "$DAN" == "" ] || [ "$DAN" == "KB" ] 
then
	DAN=1048576
	GAB=$1
elif [ "$DAN" == "MB" ];then
	DAN=1024
elif [ "$DAN" == "GB" ];then
	DAN=1
fi
a=`echo "scale=3;$GAB / $DAN"|bc`
echo $(printf %.0f $a)
}

#------------------------------------------------------------------------------------

bkf(){
temp_par=`cat $1/postgresql.auto.conf | grep -v "#" | grep -w $2 | tail -n 1`
if [ "$temp_par" == "" ]; then
	temp_par=`cat $1/postgresql.conf | grep -v "#" | grep -w $2 | tail -n 1`
fi
result_par=`echo ${temp_par#*=}|sed "s/'//g"`
echo "$result_par"
}

#------------------------------------------------------------------------------------

BIGYO(){
		if [ "$1" == "$2" ]; then
			echo "정상    "
		else
			echo "확인필요"
		fi
}

#------------------------------------------------------------------------------------

YON(){
DEF=$2
echo ""
echo -e "$1 \c"
read YN
echo ""
echo ""
if [ "$YN" == "q" ] || [ "$YN" == "Q" ] 
then
	exit 0
elif [ "$YN" == "" ]; then
	YN=$DEF
fi
while [ "$YN" != "Y" ] && [ "$YN" != "y" ] && [ "$YN" != "N" ] && [ "$YN" != "n" ]
do
		echo "You entered wrong. Please enter y or n."
		echo -e "$1 \c"
		read YN
		echo ""
		echo ""
		if [ "$YN" == "q" ] || [ "$YN" == "Q" ] 
		then
			exit 0
		elif [ "$YN" == "" ]; then
			YN=$DEF
		fi
done
echo $YN > ./bkbspark_YN.file
}

#------------------------------------------------------------------------------------

CHGI(){
NUM=1
RW=`$2 2>/dev/null| awk {'print $'${NUM}''} | head -n 1`
while [ "$RW" != "$1" ];
do
	NUM=`expr $NUM + 1`
	RW=`$2 2>/dev/null| awk {'print $'${NUM}''} | head -n 1`
done
echo $NUM
}

#------------------------------------------------------------------------------------

BYHW() {
CHOI=`echo "scale=1; $1 / 1048576" |bc`
if [ 1 -eq `echo "1 > ${CHOI}" | bc` ]; then
	CHOI=`echo "$1 / 1024" |bc`
	P1=1
	if [ 1 -eq `echo "1 > ${CHOI}" | bc` ]; then
		CHOI=`echo "$1" |bc`
		P2=1
	fi
fi
if [ "$P1" == "" ] && [ "$P2" == "" ]
then
	CHOI=`echo $CHOI"GB"`
elif [ "$P1" == "1" ] && [ "$P2" == "" ]
then
	CHOI=`echo $CHOI"MB"`
elif [ "$P1" == "1" ] && [ "$P2" == "1" ]
then
	CHOI=`echo $CHOI"KB"`
fi
echo $CHOI
}

#------------------------------------------------------------------------------------

YON "Is This Server Database Server? [Y/n]  [q is quit]:" Y
NS=`cat bkbspark_YN.file`
if [ "$NS" == "Y" ] || [ "$NS" == "y" ]
then
	echo "" >> ./bkbspark_ser.log
	echo "---------------------------------------------------------------------------" >> ./bkbspark_ser.log
	echo "                                SERVER SPEC" >> ./bkbspark_ser.log
	echo "---------------------------------------------------------------------------" >> ./bkbspark_ser.log
	echo "SEVER ver    :" `cat /etc/redhat-release` >> ./bkbspark_ser.log
	NS=1
	YON "Database Server is running? [Y/n]  [q is quit]:" Y
	NF=`cat bkbspark_YN.file`
	echo -e "Please enter the FULL PATH to the DATA location of DATABASE [q is quit]: \c"
	read DATA_DIR
	echo ""
	echo ""
	if [ "$DATA_DIR" == "q" ] || [ "$DATA_DIR" == "Q" ] 
	then
		exit 0
	fi
	if [ "$NF" == "Y" ] || [ "$NF" == "y" ]
	then
		NS=1
		ls -ld $DATA_DIR/postmaster.pid  &>/dev/null
		WRIT=`echo $?`
		while [ "$WRIT" != "0" ];
		do
			echo "Is the database running?"
			echo "The DATA path of DATABASE was entered incorrectly. Please re-type."
			echo "( You typed this value : $DATA_DIR )"
			echo -e "Please enter the FULL PATH to the DATA location of DATABASE [q is quit]: \c"
			read DATA_DIR
			echo ""
			echo ""
			if [ "$DATA_DIR" == "q" ] || [ "$DATA_DIR" == "Q" ] 
			then
				exit 0
			fi
			ls -ld $DATA_DIR/postmaster.pid &>/dev/null
			WRIT=`echo $?`
		done
		psql -w -c "\! true" &>/dev/null
		WRIT=`echo $?`
		if [ "$WRIT" == "0" ]; then
			NOP=1
			OPT=""
			psql $OPT -t -c "select  'Database ver : ' ||version() limit 1;" |sed 's/^.//g'|sed 's/on.*$//g'|head -n 1 >> ./bkbspark_ser.log
			VER=`psql $OPT -t -c "select version() limit 1;" |sed 's/^.//g'|sed 's/on.*$//g'|head -n 1`
			TVER=`echo ${VER%%.*}|rev|cut -c 1`
			if [ "$TVER" == "9" ];	then
				VER=`echo "9.\`echo ${VER#*.} | cut -c 1\`"`
			else
				VER=`echo ${VER%%.*}|rev|cut -c 1-2|rev`
			fi
			SPATH=""
		elif [ "$WRIT" != "0" ]; then
			NOP=0
		fi
		if [ "$NOP" == "0" ]; then
			LC=0
			ls -ld ~/pg*_env.sh &>/dev/null
			WRIT=`echo $?`
			if [ "$WRIT" == "0" ]; then
				ENV_FILE=`ls ~/pg*_env.sh | head -n 1`
				echo $ENV_FILE
				source $ENV_FILE
				if [ "$PGHOME" == "" ] && [ "$EDBHOME" == "" ]
				then
					CHK1=1
				elif [ "$PGHOME" == "" ]; then
					BINHOME=$EDBHOME
				elif [ "$EDBHOME" == "" ]; then
					BINHOME=$PGHOME
				fi
				if [ "$PGPORT" == "" ]; then
					CHK2=1
				elif [ "$PGPORT" != "" ] ; then
					PORT=$PGPORT
				fi
			elif [ "$WRIT" != "0" ]; then
				CHK1=1
				CHK2=1
			fi
			if [ "$CHK1" == "1" ]; then
				echo -e "Enter the full path to the directory where the psql command is located [q is quit] : \c"
				read BINHOME
				echo ""
				echo ""
				if [ "$BINHOME" == "q" ] || [ "$BINHOME" == "Q" ] 
				then
					exit 0
				fi
				ls -ld $BINHOME/bin/psql &>/dev/null
				WRIT=`echo $?`
				while [ "$WRIT" != "0" ];
				do
					echo "There is No psql in directory."
					echo "( You typed this value : $BINHOME )"
					echo -e "Enter the full path to the directory where the psql command is located [q is quit] : \c"
					read BINHOME
					if [ "$BINHOME" == "q" ] || [ "$BINHOME" == "Q" ] 
					then
						exit 0
					fi
					ls -ld $BINHOME/bin/psql &>/dev/null
					WRIT=`echo $?`
				done
			fi
			if [ "$CHK2" == "1" ]; then
				echo -e "Enter the port number of DATABASE you want to check [q is quit]: \c" 
				read PORT
				echo ""
				echo ""
				if [ "$PORT" == "q" ] || [ "$PORT" == "Q" ] 
				then
					exit 0
				fi
			fi
			echo -e "Enter the name of the DATABASE you want to check [q is quit]: \c" 
			read DB
			echo ""
			echo ""
			echo ""
			if [ "$DB" == "q" ] || [ "$DB" == "Q" ] 
			then
				exit 0
			fi
			echo -e "Please enter the SUPER USER NAME [q is quit]: \c" 
			read USER
			echo ""
			echo ""
			echo ""
			if [ "$USER" == "q" ] || [ "$USER" == "Q" ] 
			then
				exit 0
			fi
			echo -e "Please enter the SUPER USER PASSWORD : \c" 
			read PW
			echo ""
			echo ""
			echo ""
			OPT="-U $USER -d $DB -p $PORT -c"
			chmod 600 ~/.pgpass
			cat >> ~/.pgpass <<EOFF
localhost:$PORT:$DB:$USER:$PW
EOFF
			chmod 400 ~/.pgpass
			$BINHOME/bin/psql $OPT '\! true' &>/dev/null
			IS=`echo "$?"`
			chmod 600 ~/.pgpass
			sed -i '$d' ~/.pgpass
			chmod 400 ~/.pgpass
			while [ "$IS" != "0" ];
			do
				echo "There is can not check DATABASE by the following information you entered."
				echo "psql bin directory : $BINHOME"
				echo "connect Database   : $DB"
				echo "connect DB PORT    : $PORT"
				echo "connect SUPER USER : $USER"
				echo "connect PASSWD     : If all of the above information is correct, you have mistyped the PASSWORD of SUPER USER. "
				echo -e "Enter the full path to the directory where the psql command is located [q is quit] : \c"
				read BINHOME
				if [ "$BINHOME" == "q" ] || [ "$BINHOME" == "Q" ] 
				then
					exit 0
				fi
				echo -e "Enter the name of the DATABASE you want to check [q is quit]: \c" 
				read DB
				echo ""
				echo ""
				echo ""
				if [ "$DB" == "q" ] || [ "$DB" == "Q" ] 
				then
					exit 0
				fi
				echo -e "Enter the port number of DATABASE you want to check [q is quit]: \c" 
				read PORT
				echo ""
				echo ""
				echo ""
				if [ "$PORT" == "q" ] || [ "$PORT" == "Q" ] 
				then
					exit 0
				fi
				echo "Please enter the SUPER USER NAME [q is quit]: \c" 
				read USER
				echo ""
				echo ""
				echo ""
				if [ "$USER" == "q" ] || [ "$USER" == "Q" ] 
				then
					exit 0
				fi
				echo "Please enter the SUPER USER PASSWORD : \c" 
				read PW
				echo ""
				echo ""
				echo ""
				chmod 600 ~/.pgpass
				cat >> ~/.pgpass <<EOFF
localhost:$PORT:$DB:$USER:$PW
EOFF
				chmod 400 ~/.pgpass
				$BINHOME/bin/psql $OPT '\! true' &>/dev/null
				IS=`echo "$?"`
				chmod 600 ~/.pgpass
				sed -i '$d' ~/.pgpass
				chmod 400 ~/.pgpass
			done
			chmod 600 ~/.pgpass
			cat >> ~/.pgpass <<EOFF
localhost:$PORT:$DB:$USER:$PW
EOFF
			$BINHOME/bin/psql $OPT -t -c "select  'Database ver : ' ||version() limit 1;" |sed 's/^.//g'|sed 's/on.*$//g'|head -n 1 >> ./bkbspark_ser.log
			VER=`$BINHOME/bin/psql $OPT -t -c "select version() limit 1;" |sed 's/^.//g'|sed 's/on.*$//g'|head -n 1`
			TVER=`echo ${VER%%.*}|rev|cut -c 1`
			if [ "$TVER" == "9" ];	then
				VER=`echo "9.\`echo ${VER#*.} | cut -c 1\`"`
			else
				VER=`echo ${VER%%.*}|rev|cut -c 1-2|rev`
			fi
			sed -i '$d' ~/.pgpass
			chmod 400 ~/.pgpass
			SPATH="$BINHOME/bin/"
		fi
		YON "Do you want Analyze Database?\n@ ANALYZE REASON\n - INDEX utilization rate\n - DEAD TUPLE(ROW) investigation\n\nIf you don't want Analyze, above inspect will be omit. [y/N]  [q is quit]:" N
		AWS=`cat bkbspark_YN.file`
		if [ "$AWS" == "Y" ] || [ "$AWS" == "y" ]
		then
			AWS=1
		fi
		echo "Core         : "`echo \`cat /proc/cpuinfo | grep "processor" | sed 's/^.*://g'\` + 1 |bc` >> ./bkbspark_ser.log
		echo "Memory       :" `echo "(\`free -m | head -n 2 | tail -n 1 | awk {'print \$2'}\`+1000/2)/1000" |bc`"GB" >> ./bkbspark_ser.log
		echo "" >> ./bkbspark_ser.log
		shared_buffers=`"$SPATH"psql $OPT -t -c "show shared_buffers"`
		work_mem=`"$SPATH"psql $OPT -t -c "show work_mem"`
		maintenance_work_mem=`"$SPATH"psql $OPT -t -c "show maintenance_work_mem"`
		listen_addresses=`"$SPATH"psql $OPT -t -c "show listen_addresses"`
		max_connections=`"$SPATH"psql $OPT -t -c "show max_connections"`
		listen_addresses=`"$SPATH"psql $OPT -t -c "show listen_addresses"`
		connection_count=`"$SPATH"psql $OPT -t -c "select count(*) from pg_stat_activity;"`
		max_wal_size=`"$SPATH"psql $OPT -t -c "show max_wal_size" 2> /dev/null`
		min_wal_size=`"$SPATH"psql $OPT -t -c "show min_wal_size" 2> /dev/null`
		checkpoint_segments=`"$SPATH"psql $OPT -t -c "show checkpoint_segments" 2>/dev/null`
		synchronous_commit=`"$SPATH"psql $OPT -t -c "show synchronous_commit"`
		checkpoint_completion_target=`"$SPATH"psql $OPT -t -c "show checkpoint_completion_target"`
		synchronous_commit=`"$SPATH"psql $OPT -t -c "show synchronous_commit"`
		archive_mode=`"$SPATH"psql $OPT -t -c "show archive_mode"`
		archive_command=`"$SPATH"psql $OPT -t -c "show archive_command"`
		max_wal_senders=`"$SPATH"psql $OPT -t -c "show max_wal_senders"`
		random_page_cost=`"$SPATH"psql $OPT -t -c "show random_page_cost"`
		effective_cache_size=`"$SPATH"psql $OPT -t -c "show effective_cache_size"`
		logging_collector=`"$SPATH"psql $OPT -t -c "show logging_collector"`
		client_min_messages=`"$SPATH"psql $OPT -t -c "show client_min_messages"`
		log_min_messages=`"$SPATH"psql $OPT -t -c "show log_min_messages"`
		log_min_error_statement=`"$SPATH"psql $OPT -t -c "show log_min_error_statement"`
		log_min_duration_statement=`"$SPATH"psql $OPT -t -c "show log_min_duration_statement"`
		log_min_duration_statement=`echo $log_min_duration_statement`
		log_temp_files=`"$SPATH"psql $OPT -t -c "show log_temp_files"`
		log_temp_files=`echo $log_temp_files`
		log_lock_waits=`"$SPATH"psql $OPT -t -c "show log_lock_waits"`
	elif [ "$NF" == "N" ] || [ "$NF" == "n" ]
	then
		NS=0
		ls -ld $DATA_DIR/postgresql.conf &>/dev/null
		WRIT=`echo $?`
		while [ "$WRIT" != "0" ];
		do
			echo "Is the DATA directory of the database correct?"
			echo "The DATA path of DATABASE was entered incorrectly. Please re-type."
			echo "( You typed this value : $DATA_DIR )"
			echo -e "Please enter the FULL PATH to the DATA location of DATABASE [q is quit]: \c"
			read DATA_DIR
			if [ "$DATA_DIR" == "q" ] || [ "$DATA_DIR" == "Q" ] 
			then
				exit 0
			fi
			ls -ld $DATA_DIR/postmaster.pid  &>/dev/null
			WRIT=`echo $?`
		done
		echo "Database ver :" `cat $DATA_DIR/PG_VERSION` >> ./bkbspark_ser.log
		VER=`cat $DATA_DIR/PG_VERSION`
		echo "Core         : "`echo \`cat /proc/cpuinfo | grep "processor" | sed 's/^.*://g'\` + 1 |bc` >> ./bkbspark_ser.log
		echo "Memory       :" `echo "(\`free -m | head -n 2 | tail -n 1 | awk {'print \$2'}\`+1000/2)/1000" |bc`"GB" >> ./bkbspark_ser.log
		echo ""
		archive_command=`cat $DATA_DIR/postgresql.auto.conf | grep -v "#" | grep archive_command | tail -n 1`
		ARCH_DIR=`echo ${archive_command#*cp %p}`
		ARCH_DIR=`echo ${ARCH_DIR%%%f*}`
		if [ "$ARCH_DIR" == "" ]; then
			archive_command=`cat $DATA_DIR/postgresql.auto.conf | grep -v "#" | grep archive_command | tail -n 1`
			if [ "$archive_command" == "" ]; then
				archive_command=`cat $DATA_DIR/postgresql.conf | grep -v "#" | grep archive_command | tail -n 1`
			fi
			ARCH_DIR=`echo ${archive_command#*cp %p}`
			ARCH_DIR=`echo ${ARCH_DIR%%%f*}`
		fi
                shared_buffers=`bkf $DATA_DIR shared_buffers`
                work_mem=`bkf $DATA_DIR work_mem`
                maintenance_work_mem=`bkf $DATA_DIR maintenance_work_mem`
                listen_addresses=`bkf $DATA_DIR listen_addresses`
                max_connections=`bkf $DATA_DIR max_connections`
                listen_addresses=`bkf $DATA_DIR listen_addresses`
                max_wal_size=`bkf $DATA_DIR max_wal_size`
                min_wal_size=`bkf $DATA_DIR min_wal_size`
                checkpoint_segments=`bkf $DATA_DIR checkpoint_segments`
                synchronous_commit=`bkf $DATA_DIR synchronous_commit`
                checkpoint_completion_target=`bkf $DATA_DIR checkpoint_completion_target`
                synchronous_commit=`bkf $DATA_DIR synchronous_commit`
                archive_mode=`bkf $DATA_DIR archive_mode`
                archive_command=`bkf $DATA_DIR archive_command`
                max_wal_senders=`bkf $DATA_DIR max_wal_senders`
                random_page_cost=`bkf $DATA_DIR random_page_cost`
                effective_cache_size=`bkf $DATA_DIR effective_cache_size`
                logging_collector=`bkf $DATA_DIR logging_collector`
                client_min_messages=`bkf $DATA_DIR client_min_messages`
                log_min_messages=`bkf $DATA_DIR log_min_messages`
                log_min_error_statement=`bkf $DATA_DIR log_min_error_statement`
                log_min_duration_statement=`bkf $DATA_DIR log_min_duration_statement`
		log_min_duration_statement=`echo $log_min_duration_statement`
                log_temp_files=`bkf $DATA_DIR log_temp_files`
		log_temp_files=`echo $log_temp_files`
                log_lock_waits=`bkf $DATA_DIR log_lock_waits`
		if [ "$shared_buffers" == "" ]; then
			shared_buffers=128MB
		fi
		if [ "$work_mem" == "" ]; then
			if [ "$VER" == "9.3" ]; then
				work_mem=1MB
			else
				work_mem=4MB
			fi
		fi
		if [ "$maintenance_work_mem" == "" ]; then
			if [ "$VER" == "9.3" ]; then
				maintenance_work_mem=16MB
			else
				maintenance_work_mem=64MB
			fi
		fi
		if [ "$listen_addresses" == "" ]; then
			listen_addresses=localhost
		fi
		if [ "$max_connections" == "" ]; then
			max_connections=100
		fi
		if [ "$checkpoint_completion_target" == "" ]; then
			checkpoint_completion_target=0.5
		fi
		if [ "$synchronous_commit" == "" ]; then
			synchronous_commit=on
		fi
		if [ "$max_wal_size" == "" ]; then
			max_wal_size=1GB
		fi
		if [ "$min_wal_size" == "" ]; then
			min_wal_size=80MB
		fi
		if [ "$check_point_segments" == "" ]; then
			check_point_segments=3
		fi
		if [ "archive_mode" == "" ]; then
			archive_mode=off
		fi
		if [ "max_wal_senders" == "" ]; then
			if [ "$VER" == "9.3" ] || [ "$VER" == "9.4" ] || [ "$VER" == "9.5" ] || [ "$VER" == "9.6" ]
			then
				max_wal_senders=0
			else
				max_wal_senders=10
			fi
		fi
		if [ "$random_page_cost" == "" ]; then
			random_page_cost=4.0
		fi
		if [ "$effective_cache_size" == "" ]; then
			if [ "$VER" == "9.3" ]; then
				effective_cache_size=128MB
			else
				effective_cache_size=4GB
			fi
		fi
		if [ "$logging_collector" == "" ]; then
			logging_collector=on
		fi
		if [ "$client_min_messages" == "" ]; then
			client_min_messages=notice
		fi
		if [ "$log_min_messages" == "" ]; then
			log_min_messages=warning
		fi
		if [ "$log_min_error_statement" == "" ]; then
			log_min_error_statement=error
		fi
		if [ "$log_min_duration_statement" == "" ]; then
			log_min_duration_statement="-1"
		fi
		if [ "$log_lock_waits" == "" ]; then
			log_lock_waits=off
		fi
		if [ "$log_temp_files" == "" ]; then
			log_temp_files="-1"
		fi
	fi	
	AWKN=`CHGI Mounted "df -h"`
	SWKN=`CHGI Size "df -h"`
	FKG=1
	DD=`df $DATA_DIR 2>/dev/null|awk {'print $'${AWKN}''}|tail -n 1`
	DT=`df $DATA_DIR 2>/dev/null|awk {'print $'${SWKN}''}|tail -n 1`
	DS=`du -sk $DATA_DIR 2>/dev/null |awk {'print $1'}|tail -n 1`
	DY=`echo \`echo "$DS * 100 / $DT" | bc\`%`
	TDD=`echo "scale=1;$DT / 1048576" |bc`
	TDD=`echo $(printf %.0f $TDD)GB`
	TDS=`BYHW $DS`
	if [ "$VER" == "10" ] || [ "$VER" == "11" ]
	then
		WAL_NAME=wal
	else
		WAL_NAME=xlog
	fi
	W=`ls -ld $DATA_DIR/pg_${WAL_NAME} | cut -c 1`
	if [ "$W" == "d" ]; then
		WAL_DIR=`ls -d $DATA_DIR/pg_${WAL_NAME}`
	elif [ "$W" == "l" ]; then
		WAL_DIR=`ls -ld $DATA_DIR/pg_${WAL_NAME} |awk -F '>' {'print $2'}`
	fi
	WD=`df $WAL_DIR 2>/dev/null|awk {'print $'${AWKN}''}|tail -n 1`
	WT=`df $WAL_DIR 2>/dev/null|awk {'print $'${SWKN}''}|tail -n 1`
	WS=`du -sk $WAL_DIR 2>/dev/null |awk {'print $1'}|tail -n 1`
	WY=`echo \`echo "$WS * 100 / $WT" | bc\`%`
	TWD=`echo "scale=1;$WT / 1048576" |bc`
	TWD=`echo $(printf %.0f $TWD)GB`
	TWS=`BYHW $WS`
	ARCH_DIR=`echo ${archive_command#*cp %p}`
	ARCH_DIR=`echo ${ARCH_DIR%%%f*}`
	AD=`df $ARCH_DIR 2>/dev/null|awk {'print $'${AWKN}''}|tail -n 1`
	AT=`df $ARCH_DIR 2>/dev/null|awk {'print $'${SWKN}''}|tail -n 1`
	AS=`du -sk $ARCH_DIR 2>/dev/null |awk {'print $1'}|tail -n 1`
	AY=`echo \`echo "$AS * 100 / $AT" |bc\`%`
	TAD=`echo "scale=1;$AT / 1048576" |bc`
	TAD=`echo $(printf %.0f $TAD)GB`
	TAS=`BYHW $AS`
	echo "---------------------------------------------------------------------------" >> ./bkbspark_ser.log
	echo "                                 PARTITION USAGE" >> ./bkbspark_ser.log
	echo "---------------------------------------------------------------------------" >> ./bkbspark_ser.log
	echo "DATA PARTITION : $DD" >> ./bkbspark_ser.log
	echo "총용량 : $TDD" >> ./bkbspark_ser.log
	echo "사용량 : $TDS ($DY)" >> ./bkbspark_ser.log
	echo "" >> ./bkbspark_ser.log
	echo "DATA PARTITION : $WD" >> ./bkbspark_ser.log
	echo "총용량 : $TWD" >> ./bkbspark_ser.log
	echo "사용량 : $TWS ($WY)" >> ./bkbspark_ser.log
	echo "" >> ./bkbspark_ser.log
	echo "DATA PARTITION : $AD" >> ./bkbspark_ser.log
	echo "총용량 : $TAD" >> ./bkbspark_ser.log
	echo "사용량 : $TAS ($AY)" >> ./bkbspark_ser.log
	echo "" >> ./bkbspark_ser.log
	BKB=`ls -l $DATA_DIR/pg_tblspc/ | grep -w '\->'`
	CNT=`ls -l $DATA_DIR/pg_tblspc/ | grep -w '\->' | awk -F '> ' {'print $2'} | xargs du -sk 2>/dev/null| awk '{print $1}' | wc -l`
	if [ "$CNT" != "0" ] && [ "$BKB" != "" ];
	then
		K=1
		#PWKN=`CHIG Mounted "ls -l $DATA_DIR/pg_tblspc/ | awk -F '> ' {'print \$2'} | xargs df "`
		PWKN=1
	        PW=`ls -l $DATA_DIR/pg_tblspc/ | awk -F '> ' {'print $2'} | xargs df 2>/dev/null| awk {'print $'${PWKN}''} | head -n 1`
	        while [ "$PW" != "Mounted" ];
	        do
	                PWKN=`expr $PWKN + 1`
	                PW=`ls -l $DATA_DIR/pg_tblspc/ | awk -F '> ' {'print $2'} | xargs df 2>/dev/null| awk {'print $'${PWKN}''} | head -n 1`
	        done
		PARTITION=`echo \`ls -l $DATA_DIR/pg_tblspc/ | awk -F '> ' {'print $2'} | xargs df -h 2>/dev/null| awk '$'${PWKN}'' | head -n 1\``
		VWKN=`CHGI Size "echo $PARTITION"`
		TOT=0
		for (( i=1 ; i <= $CNT; i++ ))  
		do   
			BPARTITION=$PARTITION
			PARTITION=`echo \`ls -l $DATA_DIR/pg_tblspc/ | awk -F '> ' {'print $2'} | xargs df 2>/dev/null| awk '{print $'${PWKN}'}' | grep -vw "Mounted"| head -n $i | tail -n 1\``
			if [ "$BPARTITION" != "$PARTITION" ]; then
				if [ "$i" != "1" ]; then
					NAMK=`du -sk $BPARTITION 2>/dev/null| awk {'print $1'}`
					PPER=`echo \`echo "$NAMK * 100 / $TT" |bc\`%`
					TYAS=`BYHW $NAMK`
					CHGE=`echo "사용량 : $TYAS ($PPER)"`
					CLIN=`grep -n bkbspark_sayong ./bkbspark_ser.log | cut -d: -f1`
					sed -i "${CLIN}s/.*/$CHGE/g" ./bkbspark_ser.log
					NAM=`echo "$NAMK - $TOT" | bc`
					NPER=`echo \`echo "$NAM * 100 / $TT" |bc\`%`
					NYAS=`BYHW $NAM`
					echo "  -기타: $NYAS ($NPER)" >> ./bkbspark_ser.log
					if [ "$BPARTITION" == "$DD" ]; then
						echo "   기타 용량은 DATA용량을 포함하고 있습니다" >> ./bkbspark_ser.log
					elif [ "$BPARTITION" == "$WD" ]; then
						echo "   기타 용량은 WAL용량을 포함하고 있습니다" >> ./bkbspark_ser.log
					elif [ "$BPARTITION" == "$AD" ]; then 
						echo "   기타 용량은 ARCHIVE용량을 포함하고 있습니다" >> ./bkbspark_ser.log
					fi
					TOT=0
				fi
				echo "" >> ./bkbspark_ser.log
				echo "TABLESPACE PARTITION$K : $PARTITION" >> ./bkbspark_ser.log
				TT=`df -k $PARTITION | awk {'print $'${VWKN}''} | grep -vw "1K-blocks"`
				TTA=`echo "scale=1;$TT / 1048576" |bc`
				TTA=`echo $(printf %.0f $TTA)GB`
				echo "총용량 : $TTA" >> ./bkbspark_ser.log
				echo "bkbspark_sayong" >> ./bkbspark_ser.log
				K=`expr $K + 1`
			fi
			YANG=`ls -l $DATA_DIR/pg_tblspc/ | awk -F '> ' {'print $2'} | xargs du -sk 2>/dev/null| awk '{print $1}' | head -n $i | tail -n 1`
			YAS=`BYHW $YANG`
			YAP=`echo "$YANG * 100 / $TT"|bc`
			echo "  -OID: "`ls -l $DATA_DIR/pg_tblspc/ | awk -F ' ->' {'print $1'} | awk {'print $NF'} | grep -vw "0" | head -n $i | tail -n 1`" ( $YAS $YAP""% )" >> ./bkbspark_ser.log
			echo "  -DIR: "`ls -l $DATA_DIR/pg_tblspc/ | awk -F '-> ' {'print $2'} | awk {'print $NF'}| sed '/^$/d' | head -n $i | tail -n 1` >> ./bkbspark_ser.log
			TOT=`expr $TOT + $YANG`
			echo "" >> ./bkbspark_ser.log
		done
		BPARTITION=$PARTITION
		NAMK=`du -sk $BPARTITION 2>/dev/null| awk {'print $1'}`
		PPER=`echo \`echo "$NAMK * 100 / $TT" |bc\`%`
		TYAS=`BYHW $NAMK`
		CHGE=`echo "사용량 : $TYAS ($PPER)"`
		CLIN=`grep -n bkbspark_sayong ./bkbspark_ser.log | cut -d: -f1`
		sed -i "${CLIN}s/.*/$CHGE/g" ./bkbspark_ser.log
		NAM=`echo "$NAMK - $TOT" | bc`
		NPER=`echo \`echo "$NAM * 100 / $TT" |bc\`%`
		NYAS=`BYHW $NAM`
		echo "  -기타: $NYAS ($NPER)" >> ./bkbspark_ser.log
		if [ "$BPARTITION" == "$DD" ]; then
			echo "   기타 용량은 DATA용량을 포함하고 있습니다" >> ./bkbspark_ser.log
		elif [ "$BPARTITION" == "$WD" ]; then
			echo "   기타 용량은 WAL용량을 포함하고 있습니다" >> ./bkbspark_ser.log
		elif [ "$BPARTITION" == "$AD" ]; then 
			echo "   기타 용량은 ARCHIVE용량을 포함하고 있습니다" >> ./bkbspark_ser.log
		fi
		TOT=0
		echo "" >> ./bkbspark_ser.log
		echo "" >> ./bkbspark_ser.log
	fi
	if [ "$NF" == "Y" ] || [ "$NF" == "y" ]
	then 
		rm -rf ./bkbspark.sql
		cat >> ./bkbspark.sql << EOFF
\! echo ""
\! echo "---------------------------------------------------------------------------"
SELECT '-'||TO_CHAR(NOW(), 'MM')||'월: '||d.datname||' ('||CASE WHEN pg_catalog.has_database_privilege(d.datname, 'CONNECT')
THEN pg_catalog.pg_size_pretty(pg_catalog.pg_database_size(d.datname))
ELSE 'No Access'
END||') ' AS "			     Database Size    		 	   	"
FROM pg_catalog.pg_database d
JOIN pg_catalog.pg_tablespace t on d.dattablespace = t.oid
WHERE d.datname <> 'template0'
AND d.datname <> 'template1'
ORDER BY 1;
\! echo ""
\! echo ""
\! echo "---------------------------------------------------------------------------"
\! echo "                               Database Age"
\! echo "---------------------------------------------------------------------------"
select datname AS "                DB NAEM             ", age(datfrozenxid) as "               AGE                "from pg_database;
\! echo ""
\! echo ""
\! echo "---------------------------------------------------------------------------"
\! echo "                             Tablespace Size"
\! echo "---------------------------------------------------------------------------"
SELECT spcname AS "Name",
pg_catalog.pg_size_pretty(pg_catalog.pg_tablespace_size(oid)) AS "     Size     ",
pg_catalog.pg_tablespace_location(oid) AS "                Location                   "
FROM pg_catalog.pg_tablespace
WHERE spcname <> 'pg_global'
ORDER BY 3;
EOFF
		"$SPATH"psql $OPT -c "\i ./bkbspark.sql" >> ./bkbspark_ser.log
		rm -rf ./bkbspark.sql
	fi
echo "" >> ./bkbspark_ser.log
echo "" >> ./bkbspark_ser.log

memory=`free | head -n 2 | tail -n 1 | awk {'print $2'}`
memory=`GKN $memory`

CC=`echo "scale=3;$memory / 4"|bc`
CR=`echo "scale=0;$memory / 4"|bc`
T=`GBN $shared_buffers G`
j_shared_buffers=`BIGYO $CC $T`
c_shared_buffers=`echo $CR"GB"`
c_shared_buffers=`echo | awk -v temp="$c_shared_buffers" '{printf("%-11s",temp);}'`




T=`GBN $maintenance_work_mem B`
if [ "$memory" -ge "16" ];then
        C=1073741824
elif [ "$memory" -ge "8" ] && [ "16" -gt "$memory" ]
then
        C=536870912
elif [ "8" -gt "$memory" ]; then
        C=268435456
fi
T=`echo $(printf %.0f $T)`
CCC=`echo "$C/1048576"|bc`
TT=`echo "$T/1048576"|bc`
CCC=`echo $(printf %.0f $CCC)`
TT=`echo $(printf %.0f $TT)`
j_maintenance_work_mem=`BIGYO $CCC $TT`
c_maintenance_work_mem=`GBN $C M`
c_maintenance_work_mem=`echo $(printf %.0f $c_maintenance_work_mem)`
c_maintenance_work_mem=`echo ${c_maintenance_work_mem}MB`
c_maintenance_work_mem=`echo | awk -v temp="$c_maintenance_work_mem" '{printf("%-11s",temp);}'`




t_shared_buffers=`GBN $shared_buffers M`
C=`echo "( ( $memory * 1024 ) - ( $CC * 1024 ) - ( $C / 1048576 ) ) / $max_connections"|bc`

if [ "$C" -ge "128" ]
then
        C=134217728
elif [ "128" -gt "$C" ] && [ "$C" -ge "64" ]
then
        C=67108864
elif [ "64" -gt "$C" ] && [ "$C" -ge "32" ]
then
        C=33554432
elif [ "32" -gt "$C" ] && [ "$C" -ge "16" ]
then
        C=16777216
elif [ "16" -gt "$C" ] && [ "$C" -ge "8" ]
then
        C=8338608
elif [ "8" -gt "$C" ] && [ "$C" -ge "4" ]
then
        C=4194304
elif [ "4" -gt "$C" ]
then
        C=2097152
fi
T=`GBN $work_mem B`
T=`echo $(printf %.0f $T)`
CCC=`echo "scale=1;$C/1048576"|bc`
TT=`echo "scale=1;$T/1048576"|bc`
CCC=`echo $(printf %.0f $CCC)`
TT=`echo $(printf %.0f $TT)`
j_work_mem=`BIGYO $CCC $TT`
c_work_mem=`GBN $C M`
c_work_mem=`echo $(printf %.0f $c_work_mem)`
c_work_mem=`echo ${c_work_mem}MB`
c_work_mem=`echo | awk -v temp="$c_work_mem" '{printf("%-11s",temp);}'`





TY=`echo \\\\\\\\"${listen_addresses}"|sed 's/ //g'`
j_listen_addresses=`BIGYO $TY \\\\\\\*`
c_listen_addresses=" *          "
CC=`echo "scale=3;$memory * 3 / 4"|bc`
CR=`echo "scale=0;$memory * 3 / 4"|bc`
T=`GBN $effective_cache_size G`
j_effective_cache_size=`BIGYO $CC $T`
c_effective_cache_size=`echo $CR"GB"`
c_effective_cache_size=`echo | awk -v temp="$c_effective_cache_size" '{printf("%-11s",temp);}'`

if [ "$NF" == "N" ] || [ "$NF" == "n" ]
then
	Y=1	
	j_connection_count="확인필요"
elif [ "$NF" == "Y" ] || [ "$NF" == "y" ]
then
	CC=`echo "$connection_count * 100 / $max_connections"|bc`
	if [ "80" -ge "$CC" ]; then
	        j_connection_count="정상    "
			Y=1
	else
	        j_connection_count="확인필요"
			Y=0
	fi
	CC=`echo ${CC}%`
fi
if [ "$Y" == "1" ]; then
	c_connection_count=" 운영자 재량"
elif [ "$Y" == "0" ]; then
	c_connection_count=" 증가필요   "
fi


j_synchronous_commit=`BIGYO $synchronous_commit on`
c_synchronous_commit=" on         "
j_logging_collector=`BIGYO $logging_collector on`
c_logging_collector=" on         "
j_log_lock_waits=`BIGYO $log_lock_waits on`
c_log_lock_waits=" on         "
j_archive_mode=`BIGYO $archive_mode on`
c_archive_mode=" on         "
j_client_min_messages=`BIGYO $client_min_messages notice`
c_client_min_messages=" notice     "
j_log_min_messages=`BIGYO $log_min_messages warning`
c_log_min_messages=" warning    "
j_log_min_error_statement=`BIGYO $log_min_error_statement error`
c_log_min_error_statement=" error      "


if [ "$max_wal_senders" -ge "2" ]; then
        j_max_wal_senders="정상    "
else
        j_max_wal_senders="확인필요"
fi
c_max_wal_senders=" least 2    "


C=`echo "$random_page_cost * 1"| bc | sed 's/\..*$//g'`
j_random_page_cost=`BIGYO $C 2`
c_random_page_cost=" 2.0        "


if [ 1 -eq `echo "0.9 >= ${checkpoint_completion_target}" | bc` ] && [ 1 -eq `echo "0.5 <= ${checkpoint_completion_target}" | bc` ]
then
        j_checkpoint_completion_target="정상    " 
else
        j_checkpoint_completion_target="확인필요"
fi
c_checkpoint_completion_target=" 0.5 ~ 0.9  "

if [ "$log_temp_files" != "-1" ]; then
        j_log_temp_files="정상    "
elif [ "$log_temp_files" == "-1" ]; then
        j_log_temp_files="확인필요"
fi
c_log_temp_files=" Not -1     "

if [ "$log_min_duration_statement" != "-1" ]; then
        j_log_min_duration_statement="정상    "
elif [ "$log_min_duration_statement" == "-1" ]; then
        j_log_min_duration_statement="확인필요"
fi
c_log_min_duration_statement=" Not -1     "


if [ "$VER" == "9.3" ] || [ "$VER" == "9.4" ] 
then
	U=1
	WVT=`echo "( ( $WT / 3 ) / 1024 ) / 16" | bc`
	MWS=`echo "$checkpoint_segments"`
	if [ "$MWS" -gt "$WVT" ]; then
		j_checkpoint_segments="확인필요"
	else
		j_checkpoint_segments="정상    "
	fi
	c_checkpoint_segments=$WVT
	c_checkpoint_segments=`echo | awk -v temp="$c_checkpoint_segments" '{printf("%-11s",temp);}'`
else
	U=0
	WVT=`echo "( $WT * 0.8 ) / 1024" | bc`
	MWS=`GBN $max_wal_size M`
	MWS=`echo $MWS|sed 's/\..*$//g'`
	if [ "$MWS" -gt "$WVT" ]; then
		j_max_wal_size="확인필요"
	else
		j_max_wal_size="정상    "
	fi
	FKM=0
	if [ 1 -eq `echo "${WVT} > 1024" | bc` ]; then
		WWVT=`echo "scale=1;$WVT / 1024" |bc`
		c_max_wal_size=`echo $(printf %.0f $WWVT)`
		c_max_wal_size=`echo ${c_max_wal_size}GB`
		FKM=1
	else
		c_max_wal_size=`echo ${WVT}MB`
	fi
	MMWS=`GBN $min_wal_size M`
	MMWS=`echo $MMWS|sed 's/\..*$//g'`
	if [ "$MMWS" -gt "80" ] && [ "$MWS" -ge "$WVT" ]
 	then
		j_min_wal_size="확인필요"
	else
		j_min_wal_size="정상    "
	fi
	c_min_wal_size=`echo "80MB~$c_max_wal_size"`
	c_max_wal_size=`echo | awk -v temp="$c_max_wal_size" '{printf("%-11s",temp);}'`
	c_min_wal_size=`echo | awk -v temp="$c_min_wal_size" '{printf("%-11s",temp);}'`
fi

echo "---------------------------------------------------------------------------" >> ./bkbspark_ser.log
echo "                             PARAMETER CHECK" >> ./bkbspark_ser.log
echo "---------------------------------------------------------------------------" >> ./bkbspark_ser.log
echo "NO|            PARAMETER            |   CHECK  |  RECOMMAND |  YOUR_VALUE" >> ./bkbspark_ser.log
echo "---------------------------------------------------------------------------" >> ./bkbspark_ser.log
echo "01| (s)shared_buffers               | ""$j_shared_buffers"  "|"" $c_shared_buffers""|" $shared_buffers >> ./bkbspark_ser.log
echo "02| (l)work_mem                     | ""$j_work_mem"  "|"" $c_work_mem""|" $work_mem >> ./bkbspark_ser.log
echo "03| (l)maintenance_work_mem         | ""$j_maintenance_work_mem"  "|"" $c_maintenance_work_mem""|" $maintenance_work_mem >> ./bkbspark_ser.log
echo "04| (s)listen_addresses             | ""$j_listen_addresses"  "|""$c_listen_addresses""|" `echo \\\"${listen_addresses}"|sed 's/ //g'` | sed 's/\\//g' >> ./bkbspark_ser.log
echo "05| (s)max_connections              | ""$j_connection_count"  "|""$c_connection_count""|" $max_connections >> ./bkbspark_ser.log
if [ "$VER" == "9.3" ] || [ "$VER" == "9.4" ]
then
	echo "06| (s)checkpoint_segments          | ""$j_checkpoint_segments"  "|""$c_checkpoint_segments""|" $checkpoint_segments >> ./bkbspark_ser.log
	echo "07| (l)checkpoint_completion_target | ""$j_checkpoint_completion_target"  "|""$c_checkpoint_completion_target""|" $checkpoint_completion_target >> ./bkbspark_ser.log
	echo "08| (s)synchronous_commit           | ""$j_synchronous_commit"  "|""$c_synchronous_commit""|" $synchronous_commit >> ./bkbspark_ser.log
	echo "09| (s)archive_mode                 | ""$j_archive_mode"  "|""$c_archive_mode""|" $archive_mode >> ./bkbspark_ser.log
	echo "10| (s)max_wal_senders              | ""$j_max_wal_senders"  "|""$c_max_wal_senders""|" $max_wal_senders >> ./bkbspark_ser.log
	echo "11| (l)random_page_cost             | ""$j_random_page_cost"  "|""$c_random_page_cost""|" $random_page_cost >> ./bkbspark_ser.log
	echo "12| (l)effective_cache_size         | ""$j_effective_cache_size"  "|"" $c_effective_cache_size""|" $effective_cache_size >> ./bkbspark_ser.log
	echo "13| (s)logging_collector            | ""$j_logging_collector"  "|""$c_logging_collector""|" $logging_collector >> ./bkbspark_ser.log
	echo "14| (l)client_min_messages          | ""$j_client_min_messages"  "|""$c_client_min_messages""|" $client_min_messages >> ./bkbspark_ser.log
	echo "15| (l)log_min_messages             | ""$j_log_min_messages"  "|""$c_log_min_messages""|" $log_min_messages >> ./bkbspark_ser.log
	echo "16| (l)log_min_error_statement      | ""$j_log_min_error_statement"  "|""$c_log_min_error_statement""|" $log_min_error_statement >> ./bkbspark_ser.log
	echo "17| (l)log_min_duration_statement   | ""$j_log_min_duration_statement"  "|""$c_log_min_duration_statement""|" $log_min_duration_statement >> ./bkbspark_ser.log
	echo "18| (l)log_lock_waits               | ""$j_log_lock_waits"  "|""$c_log_lock_waits""|" $log_lock_waits >> ./bkbspark_ser.log
	echo "19| (l)log_temp_files               | ""$j_log_temp_files"  "|""$c_log_temp_files""|" $log_temp_files >> ./bkbspark_ser.log
else
	echo "06| (s)max_wal_size                 | ""$j_max_wal_size"  "|"" $c_max_wal_size""|" $max_wal_size >> ./bkbspark_ser.log
	echo "07| (s)min_wal_size                 | ""$j_min_wal_size"  "|"" $c_min_wal_size""|" $min_wal_size >> ./bkbspark_ser.log
	echo "08| (l)checkpoint_completion_target | ""$j_checkpoint_completion_target"  "|""$c_checkpoint_completion_target""|" $checkpoint_completion_target >> ./bkbspark_ser.log
	echo "09| (s)synchronous_commit           | ""$j_synchronous_commit"  "|""$c_synchronous_commit""|" $synchronous_commit >> ./bkbspark_ser.log
	echo "10| (s)archive_mode                 | ""$j_archive_mode"  "|""$c_archive_mode""|" $archive_mode >> ./bkbspark_ser.log
	echo "11| (s)max_wal_senders              | ""$j_max_wal_senders"  "|""$c_max_wal_senders""|" $max_wal_senders >> ./bkbspark_ser.log
	echo "12| (l)random_page_cost             | ""$j_random_page_cost"  "|""$c_random_page_cost""|" $random_page_cost >> ./bkbspark_ser.log
	echo "13| (l)effective_cache_size         | ""$j_effective_cache_size"  "|"" $c_effective_cache_size""|" $effective_cache_size >> ./bkbspark_ser.log
	echo "14| (s)logging_collector            | ""$j_logging_collector"  "|""$c_logging_collector""|" $logging_collector >> ./bkbspark_ser.log
	echo "15| (l)client_min_messages          | ""$j_client_min_messages"  "|""$c_client_min_messages""|" $client_min_messages >> ./bkbspark_ser.log
	echo "16| (l)log_min_messages             | ""$j_log_min_messages"  "|""$c_log_min_messages""|" $log_min_messages >> ./bkbspark_ser.log
	echo "17| (l)log_min_error_statement      | ""$j_log_min_error_statement"  "|""$c_log_min_error_statement""|" $log_min_error_statement >> ./bkbspark_ser.log
	echo "18| (l)log_min_duration_statement   | ""$j_log_min_duration_statement"  "|""$c_log_min_duration_statement""|" $log_min_duration_statement >> ./bkbspark_ser.log
	echo "19| (l)log_lock_waits               | ""$j_log_lock_waits"  "|""$c_log_lock_waits""|" $log_lock_waits >> ./bkbspark_ser.log
	echo "20| (l)log_temp_files               | ""$j_log_temp_files"  "|""$c_log_temp_files""|" $log_temp_files >> ./bkbspark_ser.log
fi
echo "---------------------------------------------------------------------------" >> ./bkbspark_ser.log
echo "" >> ./bkbspark_ser.log
echo "" >> ./bkbspark_ser.log
rm -rf ./bkbspark_YN.file
fi
LOG_DIRT=`pwd`
echo "-------------------------------------------------------------------"
echo -e "PLEASE TYPE THE LOG directory FULL PATH( default : $LOG_DIRT ) : \c "
read LOG_DIR
if [ "$LOG_DIR" == "" ]; then
	echo ""
	echo "YOU DID'NT TYPE LOG directory. IT WILL BE INSPECT PostgreSQL LOG in CURRENT directory."
	echo "LOG direcoty : $LOG_DIRT"
	echo ""
	LOG_DIR=`pwd`
else 
	echo ""
	echo "YOU TYPE BELOW LOG directory. IT WILL BE INSPECT PostgreSQL LOG in THIS directory."
	echo "LOG direcoty : $LOG_DIR"
	echo ""
fi
ls -ld $LOG_DIR &> /dev/null
if [ "$?" != "0" ]; then
	echo "-------------------------------------------------------------------"
	echo ""
	echo "THERE IS NO LOG_DIR. Please check LOG directory"
	echo "LOG direcoty : $LOG_DIR"	
	exit 0
fi
LOG_PRE=`ls -rt $LOG_DIR | cut -c 1-2 | uniq -d -c | head -n 1 | awk {'print $2'}`
MAL=`cat $LOG_DIR/$LOG_PRE* | grep LOG: | head -n 1`
if [ "$MAL" == "" ]; then
	echo "-------------------------------------------------------------------"
	echo ""
	echo "THERE IS NO LOG in LOG directory. Please check LOG directory"
	echo "LOG direcoty : $LOG_DIR"	
	exit 0
fi
echo "-------------------------------------------------------------------"
echo ""
echo -e "ENTER THE DATE YOU WANT TO START THE CHECK.(YYYYMMDD): \c "
read START_DATE
CH=`echo $START_DATE | wc -c`
if [ "$CH" == "9" ];then
	r=${START_DATE//[0-9]/}
	if [ -z "$r" ] ; then
	    MON=`echo $START_DATE | cut -c 5-6`
	    DAY=`echo $START_DATE | cut -c 7-8`
	    if [ "12" -ge "$MON" -a "31" -ge "$DAY" ]; then
	    	FAIL=0
	    else
		FAIL=1
	    fi	
	else
	    FAIL=1
	fi	
else
	FAIL=1
fi
while [ "$FAIL" == "1" ]
do
	echo ""
	echo -e "The date you entered is not date format. Please retype DATE (If you want quit Enter the q): \c "
	read START_DATE
	if [ "$START_DATE" == "q" ]; then
		exit 0
	fi
	CH=`echo $START_DATE | wc -c`
	if [ "$CH" == "9" ];then
		r=${START_DATE//[0-9]/}
		if [ -z "$r" ] ; then
	    		MON=`echo $START_DATE | cut -c 5-6`
		   	DAY=`echo $START_DATE | cut -c 7-8`
			if [ "12" -ge "$MON" -a "31" -ge "$DAY" ]; then
				FAIL=0
			else
				FAIL=1
			fi	
		else
		    FAIL=1
		fi	
	else
		FAIL=1
	fi
done
END_DATE=`date +%Y%m%d%H%M`
START_DATE=`echo "$START_DATE"0000`
FD=`echo $START_DATE | cut -c 1-8`
SD=`echo $END_DATE | cut -c 1-8`
FD=`date -d "$FD" "+%s"`
SD=`date -d "$SD" "+%s"`
DD=`echo "($SD - $FD) / 86400" | bc`

while [ "$START_DATE" -gt "$END_DATE" ]
do
	echo ""
	echo -e "The date you entered is later than the current date. Please retype DATE (If you want quit Enter the q): \c "
	read START_DATE
	if [ "$START_DATE" == "q" ]; then
		exit 0
	fi
done
echo "-------------------------------------------------------------------"
echo ""
touch -t $START_DATE $LOG_DIR/bkbsparkstart.txt
touch -t $END_DATE $LOG_DIR/bkbsparkend.txt
NUM=1
FILE=`ls -rt $LOG_DIR/$LOG_PRE* | head -n $NUM | tail -n 1`
R=`cat ./$LOG_PRE* | grep LOG: | head -n 1 | sed -e 's;LOG:.*$;;'|awk '{print NF}'`
E=`expr $R + 2`
T=`expr $E + 1`
W=`expr $R + 9`
Q=`expr $W + 2`
AN=0
RN=0
AFN=`find $LOG_DIR -name "$LOG_PRE*" | wc -l`

while [ ${test} $FILE -ot $LOG_DIR/bkbsparkstart.txt ]
do
	NUM=`expr $NUM + 1`
	FILE=`ls -rt $LOG_DIR/$LOG_PRE* | head -n $NUM | tail -n 1`
done
while [ ${test} $LOG_DIR/bkbsparkstart.txt -ot $FILE -a ${test} $FILE -ot $LOG_DIR/bkbsparkend.txt ]
do
	RN=`expr $RN + 1`
	PN=`expr $RN \* 100 / $AFN`
	NUM=`expr $NUM + 1`
	FILEB=$FILE
	FILE=`ls -rt $LOG_DIR/$LOG_PRE* | head -n $NUM | tail -n 1`
	if [ "$FILE" == "$FILEB" ]; then
		FILE=$LOG_DIR/bkbsparkend.txt
	fi
	while [ ! ${test} -e $LOG_DIR/bkbspark_temp.file -a ! ${test} $FILE -ef $LOG_DIR/bkbsparkend.txt ];
	do
	        printf 'Inspect '${FILE}' LOG files......[─]('${PN}'%%)\r';
		sleep 0.05
	        printf 'Inspect '${FILE}' LOG files......[\\]('${PN}'%%)\r';
		sleep 0.05
	        printf 'Inspect '${FILE}' LOG files......[|]('${PN}'%%)\r';
		sleep 0.05
	        printf 'Inspect '${FILE}' LOG files......[/]('${PN}'%%)\r';
		sleep 0.05
	done &
	cat $FILEB | grep ERROR: >> bkbspark_err.log
	cat $FILEB | sed -e 's;^.*LOG:.statement:;;i' | sed -e 's;^.*LOG:..statement:;;i'| sed -e 's;^.*LOG:...statement:;;i'|sed ':a;N;$!ba;s/\n\t/; /g'|sed ':a;N;$!ba;s/\n /; /g' | grep -A1 duration: | grep 'duration:\|statement:' >> bkbspark_slow.log
	cat $FILEB | grep temporary >> bkbspark_temp.log
	cat $FILEB | grep lock: | awk '{if (($'${W}'!="")&&($'${Q}'==""))print "cat '${FILEB}' \| sed -e \'\''s\;^.*.QUERY:\;\;i\'\''\| sed -e \'\''s\;^.*..QUERY:\;\;i\'\''\| sed -e \'\''s\;^.*...QUERY:\;\;i\'\''\| sed -e \'\''s\;^.*.CONTEXT:\;\;i\'\''\| sed -e \'\''s\;^.*..CONTEXT:\;\;i\'\''\| sed -e \'\''s\;^.*...CONTEXT:\;\;i\'\''\| sed -e \'\''s\;^.*.statement:\;\;i\'\''\| sed -e \'\''s\;^.*..statement:\;\;i\'\''\| sed -e \'\''s\;^.*...statement:\;\;i\'\''\| sed \'\''s/^M//gi\'\''\|sed \'\'':a\;N\;\$\!ba\;s\/\\n\\t\/\ \/g\'\''\|sed \'\'':a\;N\;\$\!ba\;s\/\\n\ \/\ \/g\'\''| grep \"" $0 "\""}' 2>/dev/null 1> ./bkbspark.sh 
	bash bkbspark.sh >> bkbspark_lock.log
	rm -rf ./bkbspark.sh
	cat $FILEB | grep tdow >> bkbspark_sht.log
	cat $FILEB | grep FATAL >> bkbspark_fatl.log
	cat $FILEB | grep PANIC >> bkbspark_panic.log
	cat $FILEB | grep WARNING >> bkbspark_warn.log
	touch $LOG_DIR/bkbspark_temp.file
	sleep 0.3
	rm -rf $LOG_DIR/bkbspark_temp.file
done
rm -rf $LOG_DIR/bkbsparkstart.txt
rm -rf $LOG_DIR/bkbsparkend.txt
echo "                                      # Syntax ERROR REPORT #">> $LOG_DIR/bkbspark_err2.log
echo "-------┬--------------------------------------------------------------------------------------------" >> $LOG_DIR/bkbspark_err2.log
echo " count |                                     ERROR query" >> $LOG_DIR/bkbspark_err2.log
echo "-------┴--------------------------------------------------------------------------------------------" >> $LOG_DIR/bkbspark_err2.log
cat $LOG_DIR/bkbspark_err.log | cut -d\  -f$E- | sort | uniq -c | sort -nr | awk '{if ($1>='${DD}')print}'>> $LOG_DIR/bkbspark_err2.log
#cat $LOG_DIR/bkbspark_err.log | cut -d\  -f$E- | sort | uniq -c | sort -nr >> $LOG_DIR/bkbspark_err2.log
rm -rf $LOG_DIR/bkbspark_err.log
mv $LOG_DIR/bkbspark_err2.log $LOG_DIR/bkbspark_err.log
echo "                                      # Slow QUERY REPORT #">> $LOG_DIR/bkbspark_slow2.log
echo "-------┬-------------------┬----------------------┬-------------------------------------------------" >> $LOG_DIR/bkbspark_slow2.log
echo " count | Time of occurrence| Query execution time |                    SLOW query" >> $LOG_DIR/bkbspark_slow2.log
echo "-------┴-------------------┴----------------------┴-------------------------------------------------" >> $LOG_DIR/bkbspark_slow2.log
cat $LOG_DIR/bkbspark_slow.log | cut -d\  -f$T,1,2,$T- | sort -k5,21 -k3nr -r| uniq -c -f 4 |sort -nr| sed 's/;/ /g'| sed 's/ * statement: *//gi'  | sed 's/ *SELECT */ SELECT /gi' | sed 's/\*\/ */\*\/ /g'| sed 's/ * AS */ AS /gi'  | sed 's/ * FROM */ FROM /gi'| sed 's/ * WHERE */ WHERE /gi' | sed 's/ * AND */ AND /gi'| sed 's/ * ORDER BY */ ORDER BY /gi'| sed 's/ * GROUP BY */ GROUP BY /gi'| sed 's/ *DELETE */ DELETE /gi'| sed 's/ *INSERT */ INSERT /gi'| sed 's/ *UPDATE */ UPDATE /gi'| sed 's/ *COPY */ COPY /gi'| sed 's/ *VACUUM */ VACUUM /gi'| sed 's/ *( */(/gi'| sed 's/ * ) */)/gi'| sed 's/ *, */,/gi'| sed 's/; */;/g'| sed 's/;\t*/;/g' | sed 's/
//gi'| sed 's/\*\/ */\*\/ /g' | awk '{if ($1>='${DD}')print}'>> $LOG_DIR/bkbspark_slow2.log
#cat $LOG_DIR/bkbspark_slow.log | cut -d\  -f$T,1,2,$T- | sort -k5,21 -k3nr -r| uniq -c -f 4 |sort -nr| sed 's/;/ /g'| sed 's/ * statement: *//gi'  | sed 's/ *SELECT */ SELECT /gi' | sed 's/\*\/ */\*\/ /g'| sed 's/ * AS */ AS /gi'  | sed 's/ * FROM */ FROM /gi'| sed 's/ * WHERE */ WHERE /gi' | sed 's/ * AND */ AND /gi'| sed 's/ * ORDER BY */ ORDER BY /gi'| sed 's/ * GROUP BY */ GROUP BY /gi'| sed 's/ *DELETE */ DELETE /gi'| sed 's/ *INSERT */ INSERT /gi'| sed 's/ *UPDATE */ UPDATE /gi'| sed 's/ *COPY */ COPY /gi'| sed 's/ *VACUUM */ VACUUM /gi'| sed 's/ *( */(/gi'| sed 's/ * ) */)/gi'| sed 's/ *, */,/gi'| sed 's/; */;/g'| sed 's/;\t*/;/g' | sed 's/
//gi'| sed 's/\*\/ */\*\/ /g' >> $LOG_DIR/bkbspark_slow2.log
rm -rf $LOG_DIR/bkbspark_slow.log
mv $LOG_DIR/bkbspark_slow2.log $LOG_DIR/bkbspark_slow.log
echo "                                          # LOCK REPORT #">> $LOG_DIR/bkbspark_lock2.log
echo "-------------------┬--------------------------------------------------------------------------------" >> $LOG_DIR/bkbspark_lock2.log
echo " Time of occurrence|                              Wait queue & Query" >> $LOG_DIR/bkbspark_lock2.log
echo "-------------------┴--------------------------------------------------------------------------------" >> $LOG_DIR/bkbspark_lock2.log
cat $LOG_DIR/bkbspark_lock.log | sed 's/;/ /g'| sed 's/ * statement: *//gi'  | sed 's/ *SELECT */ SELECT /gi' | sed 's/\*\/ */\*\/ /g'| sed 's/ * AS */ AS /gi'  | sed 's/ * FROM */ FROM /gi'| sed 's/ * WHERE */ WHERE /gi' | sed 's/ * AND */ AND /gi'| sed 's/ * ORDER BY */ ORDER BY /gi'| sed 's/ * GROUP BY */ GROUP BY /gi'| sed 's/ *DELETE */ DELETE /gi'| sed 's/ *INSERT */ INSERT /gi'| sed 's/ *UPDATE */ UPDATE /gi'| sed 's/ *COPY */ COPY /gi'| sed 's/ *VACUUM */ VACUUM /gi'| sed 's/ *( */(/gi'| sed 's/ * ) */)/gi'| sed 's/ *, */,/gi'| sed 's/; */;/g'| sed 's/;\t*/;/g' | sed 's/
//gi'| sed 's/\*\/ */\*\/ /g'| sort -k12 >> $LOG_DIR/bkbspark_lock2.log
rm -rf $LOG_DIR/bkbspark_lock.log
mv $LOG_DIR/bkbspark_lock2.log $LOG_DIR/bkbspark_lock.log
BKN=4
NQ=START
while [ "$NQ" != "" ];
do
	BQ=$NQ
	BKN=`expr $BKN + 1`
	NQ=`cat $LOG_DIR/bkbspark_lock.log | sed -n ''${BKN}'p' |awk {'print $12'}|awk -F, {'print $1'}| sed -e 's/\.$//'`
	if [ "$BQ" != "START" ]; then
		if [ "$BQ" != "$NQ" ]; then
			sed -i -e ''${BKN}' i\----------------------------------------------------------------------------------------------------' $LOG_DIR/bkbspark_lock.log
			BKN=`expr $BKN + 1`
		fi
	fi
done

echo ""
echo ""
echo "-------------------------------------------------------------------"
echo ""
echo "Inspect is FINISH. Please check RESULT, blow files."
echo "bkbspark_err.log  : Reports the occurrence of Syntax ERR"
echo "bkbspark_slow.log : Reports the frequency of the SLOW QUERY and the longest time."
echo "bkbspark_temp.log : Reports the usage history of TEMP FILE."
echo "bkbspark_lock.log : Reports the occurrence of LOCK."
echo "bkbspark_shut.log : Reports the occurrence of SHUTDOWN"
echo "bkbspark_warn.log : Reports the occurrence of WARNING."
echo "bkbspark_pani.log : Reports the occurrence of PANIC."
echo "bkbspark_fata.log : Reports the occurrence of FATAL."
echo "bkbspark_para.log : Reports whether the parameter value set in the current database is the optimal value."
echo ""
echo "-------------------------------------------------------------------"
exit 0

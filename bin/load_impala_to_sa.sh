#!/bin/bash

function usage {
    echo "usage: $0 [-t table] [-s is split] [-p type] [-d database]"
    echo "  -t    impala table name"
    echo "  -s    split data by elt_date, true or false"
    echo "  -p    run history or periodic"
    echo "  -d    impala database name"
    echo "  -k    start date"
    echo "	-e    end_date"
    echo "  -x    whether to set a time period"
    exit 1
}

while getopts 't:p:s:d:k:e:x:h' OPT; do
    case $OPT in
      t)
          table="$OPTARG";;
      d)
          database="$OPTARG";;    
      p)
          type="$OPTARG";;
      s)
          is_split="$OPTARG";;
      k)
          start_date="$OPTARG";;  
      e)
          end_date="$OPTARG";; 
      x)
      	  is_period="$OPTARG";;           
      h)
          usage;;  
      ?)
          echo "Usage: `basename $0` [options] filename"
    esac
done
source ~/.bash_profile

HOMR_DIR=/data/sa_cluster/custom/etl/tagdata/impala2sa
DATA_DIR=${HOMR_DIR}/${table}
BAK_DIR=${HOMR_DIR}/bak_data/${table}
LOG_DIR=${HOMR_DIR}/logs
BIN_DIR=${HOMR_DIR}/bin

#创建目录，不存在就创建
test -d ${HOMR_DIR} || mkdir -p ${HOMR_DIR}
test -d ${DATA_DIR} || mkdir -p ${DATE_DIR}
test -d ${BAK_DIR} || mkdir -p ${BAK_DIR}
test -d ${LOG_DIR} || mkdir -p ${LOG_DIR}

# 执行 kinit
kinit -kt  /home/sa_cluster/sa/conf/s_sensorimpala.keytab s_sensorimpala/htbdwwnode01.htsec.com@HTSECNEW.COM


function batch_importer() {
	# batch_importer 导入数据
	data_dir=$1
	/home/sa_cluster/sa/tools/batch_importer/bin/sa-importer \
	--path $data_dir \
	--project production \
	--import \
	--session new
}



function get_event_count() {
	# 查询该事件在 SA 中是否已经存在
	table=$1
	query_sql="select count(*) as count from events where event='$table' /*SA(production)*/;"
	event_count=`impala-shell -k -s  s_sensorimpala -d app_sensor -q "$query_sql" -B --output_delimite , | awk '{print int($1)}'`
	return $event_count
}

function get_sa_event_date() {
	# 查询该表在SA中的最新日期
	table=$1
	query_sql="select date, count(*) as count from events where event='$table' group by date order by date desc limit 1 /*SA(production)*/;"
	sa_date=`impala-shell -k -s  s_sensorimpala -d app_sensor -q "$query_sql" -B --output_delimite , | awk -F ' ' '{print $1}'`
	sa_date=`date -d "$sa_date" +%Y%m%d`
    echo $sa_date
	return $sa_date
}

function handle_data_by_peroid() {
	# 指定时间段处理数据
	get_all_etl_date_sql="select etl_date, count(*) as count from $table where etl_date>=$start_date and etl_date<=$end_date group by etl_date order by etl_date asc;"
	for etl_date in `impala-shell -k -i nfbdpdn044.htsec.com -d $database -q "$get_all_etl_date_sql" -B --output_delimite , | awk -F ',' '{print $1}'`;
	do
		query_sql="select * from $table where etl_date=$etl_date;"
		if [ $table == "t_dmn_cust_ofs_fund_purc_jour" ];then
			query_sql="select * from (select * from $table where etl_date = $etl_date and cust_id is not null and event_time is not null)t1 left join (select * from t_dmn_pdc_product_info where etl_date = $etl_date)t2 on t1.fund_id = t2.fund_id;"
		fi
		log_file=$LOG_DIR/${table}_$etl_date.log
		echo "`date "+%Y-%m-%d %H:%M:%S"` start handle table:$table, etl_date:$etl_date, sql:$query_sql" >> $log_file 2>&1
         DATA_DIR_1=$DATA_DIR/$etl_date
        rm -f  $DATA_DIR_1
        mkdir -p $DATA_DIR_1
		impala-shell -k -i nfbdpdn044.htsec.com -d $database -q "$query_sql" -B --output_delimite , --print_header | python3 ${BIN_DIR}/impyla_to_sa.py -t $table -e $etl_date -d False -o $DATA_DIR_1 >> $log_file 2>&1
		if [ $? -eq 0 ]; then
			batch_importer $DATA_DIR_1 >> $log_file 2>&1 
		fi
		mv -f $DATA_DIR_1 $BAK_DIR/
		echo "`date "+%Y-%m-%d %H:%M:%S"` finish handle table:$table, etl_date:$etl_date" >> $log_file 2>&1 
	done

}



function handle_data_by_date() {
	# 根据源表中的所有天数分天处理数据
	get_all_etl_date_sql="select etl_date, count(*) as count from $table group by etl_date order by etl_date asc;"
	for etl_date in `impala-shell -k -i nfbdpdn044.htsec.com -d $database -q "$get_all_etl_date_sql" -B --output_delimite , | awk -F ',' '{print $1}'`;
	do
		query_sql="select * from $table where etl_date=$etl_date;"
		if [ $table == "t_dmn_cust_ofs_fund_purc_jour" ];then
			query_sql="select * from (select * from $table where etl_date=$etl_date and cust_id is not null and event_time is not null)t1 left join (select * from t_dmn_pdc_product_info where etl_date=$etl_date)t2 on t1.fund_id=t2.fund_id;"
		fi
		log_file=$LOG_DIR/${table}_$etl_date.log
		echo "`date "+%Y-%m-%d %H:%M:%S"` start handle table:$table, etl_date:$etl_date, sql:$query_sql" >> $log_file
         # 处理好的文件按天存储
        DATA_DIR_1=$DATA_DIR/$etl_date
        rm -rf $DATA_DIR_1
        mkdir -p $DATA_DIR_1
		impala-shell -k -i nfbdpdn044.htsec.com -d $database -q "$query_sql" -B --output_delimite , --print_header | python3 ${BIN_DIR}/impyla_to_sa.py -t $table -e $etl_date -d False -o $DATA_DIR_1 >> $log_file
		if [ $? -eq 0 ]; then
			batch_importer $DATA_DIR_1 >> $log_file 2>&1 
		fi
		mv -f $DATA_DIR_1 $BAK_DIR/
		echo "`date "+%Y-%m-%d %H:%M:%S"` finish handle table:$table, etl_date:$etl_date" >> $log_file
	done

}

function handle_data() {
	# 直接处理整张表
	query_sql="select * from $table;"
	log_file=$LOG_DIR/$table.log
	echo "`date "+%Y-%m-%d %H:%M:%S"` start handle table:$table, etl_date:$etl_date" >> $log_file
	impala-shell -k -i nfbdpdn044.htsec.com -d $database -q "$query_sql" -B --output_delimite , --print_header | python3 ${BIN_DIR}/impyla_to_sa.py -t $table -e '' -d False -o $DATA_DIR >> $log_file
	if [ $? -eq 0 ]; then
			batch_importer $DATA_DIR >> $log_file
	fi
	mv -f $DATA_DIR/$table.json $BAK_DIR
	echo "`date "+%Y-%m-%d %H:%M:%S"` finish handle table:$table, etl_date:$etl_date, sql:$query_sql" >> $log_file
}

function handle_data_periodic() {
	# 如果是新加进来的表，在 SA 中还没有，那么直接 load 整张表。否则 load 大于 sa 中最新日期的数据。以后定时跑需要执行这个函数
	get_event_count $table
	event_count=$?
	if [ $event_count -eq 0 ];then
		handle_data_by_date
	else
		#get_sa_event_date $table
		#sa_date=$?
        query_sa_date_sql="select date, count(*) as count from events where event='$table' group by date order by date desc limit 1 /*SA(production)*/;"
        sa_date=`impala-shell -k -s  s_sensorimpala -d app_sensor -q "$query_sa_date_sql" -B --output_delimite , | awk -F ' ' '{print $1}'`
        sa_date=`date -d "$sa_date" +%Y%m%d`
		get_load_date_sql="select etl_date, count(*) as count from $table where etl_date>$sa_date group by etl_date order by etl_date desc"	
		for etl_date in `impala-shell -k -i nfbdpdn044.htsec.com -d $database -q "$get_load_date_sql" -B --output_delimite , | awk -F ',' '{print $1}'`;
		do
			query_sql="select * from $table where etl_date=$etl_date;"
			if [ $table == "t_dmn_cust_ofs_fund_purc_jour" ];then
				query_sql="select * from (select * from $table where etl_date>$etl_date and cust_id is not null and event_time is not null)t1 left join (select * from t_dmn_pdc_product_info where etl_date>$etl_date)t2 on t1.fund_id = t2.fund_id;"
			fi	
			log_file=$LOG_DIR/${table}_$etl_date.log
			echo "`date "+%Y-%m-%d %H:%M:%S"` start handle table:$table, etl_date:$etl_date, sql:$query_sql" >> $log_file
			# 按天存储
			DATA_DIR_1=$DATA_DIR/$etl_date
            rm -rf $DATA_DIR_1
			mkdir -p $DATA_DIR_1
			impala-shell -k -i nfbdpdn044.htsec.com -d $database  -q "$query_sql" -B --output_delimite , --print_header | python3 ${BIN_DIR}/impyla_to_sa.py -t $table -e $etl_date -d False -o $DATA_DIR_1 >> $log_file 2>&1 
			if [ $? -eq 0 ]; then
				batch_importer $DATA_DIR_1 >> $log_file 2>&1 
			fi
			mv -f $DATA_DIR_1 $BAK_DIR/
			echo "`date "+%Y-%m-%d %H:%M:%S"` finish handle table:$table, etl_date:$etl_date" >> $log_file
		done	
	fi	

}


function executor() {
	# 处理历史数据，分天的话，是指定时间段还是按所有日期。还是直接load整张表
	if [ $type == "history" ]; then
		if ${is_split}; then
			if ${is_period}; then
				handle_data_by_peroid
			else 
				handle_data_by_date	
			fi	
		else
			handle_data
		fi	
	else 
		handle_data_periodic
	fi 

}

executor
# rm log and bak_data
dt=`date "+%Y%m%d"`
rm_date=`date -d "7 day ago $dt" +%Y%m%d`
rm -rf $BAK_DIR/*/${rm_date}
rm -f $LOG_DIR/*${rm_date}.log


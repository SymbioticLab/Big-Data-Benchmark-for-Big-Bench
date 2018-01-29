log=log_bb_1g
err=err_bb_1g

for i in $(seq -f "%02g" 1 30)
do 
	echo $i
	filename=/users/wentingt/Big-Data-Benchmark-for-Big-Bench/engines/hive/queries/q${i}/query${i}.sql
	#filename=/users/wentingt/Big-Data-Benchmark-for-Big-Bench/engines/hive/queries/q${i}/q${i}.sql
	echo "@@@$filename" >>$log
	echo "@@@$filename" >>$err

	/users/wentingt/Big-Data-Benchmark-for-Big-Bench/bin/bigBench runQuery -U -q $((10#$i)) 1>>$log 2>>$err
done


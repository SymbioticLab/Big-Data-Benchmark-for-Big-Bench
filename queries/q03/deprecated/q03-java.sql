add file ${env:BIG_BENCH_HIVE_LIBS}/hive-contrib.jar;
add file ${env:BIG_BENCH_QUERIES_DIR}/Resources/bigbenchqueriesmr.jar;


set QUERY_NUM=q03;
set resultTableName=${hiveconf:QUERY_NUM}result;
set resultFile=${env:BIG_BENCH_HDFS_ABSOLUTE_QUERY_RESULT_DIR}/${hiveconf:resultTableName};

--CREATE RESULT TABLE. Store query result externaly in output_dir/qXXresult/
DROP TABLE IF EXISTS ${hiveconf:resultTableName};
CREATE TABLE ${hiveconf:resultTableName}
ROW FORMAT
DELIMITED FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION '${hiveconf:resultFile}' 
AS
-- Beginn: the real query part
SELECT lastviewed_item, purchased_item, count(*) FROM (
        FROM 
	(	SELECT 
			wcs_user_sk AS user,
		        wcs_click_date_sk AS lastviewed_date,
		 	wcs_click_time_sk AS lastviewed_time,
			wcs_item_sk AS lastviewed_item,
		        wcs_sales_sk AS lastviewed_sale
		 FROM web_clickstreams
		 CLUSTER BY user
        ) map_output
        REDUCE 
            map_output.user, 
            map_output.lastviewed_date,
	    map_output.lastviewed_time,
            map_output.lastviewed_item,
            map_output.lastviewed_sale
	USING 'java -cp bigbenchqueriesmr.jar:hive-contrib.jar de.bankmark.bigbench.queries.q03.Red'
     
        AS (lastviewed_item BIGINT, purchased_item BIGINT)
) nPath
--WHERE purchased_item = 16891
-- AND purchased_date-lastviewed_date < 11
GROUP BY lastviewed_item, purchased_item;


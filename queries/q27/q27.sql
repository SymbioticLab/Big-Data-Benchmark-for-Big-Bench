ADD JAR ${env:BIG_BENCH_QUERIES_DIR}/Resources/bigbenchqueriesmr.jar;

set QUERY_NUM=q27;
set resultTableName=${hiveconf:QUERY_NUM}result;
set resultFile=${env:BIG_BENCH_HDFS_ABSOLUTE_QUERY_RESULT_DIR}/${hiveconf:resultTableName};


CREATE TEMPORARY FUNCTION find_company AS 'de.bankmark.bigbench.queries.q27.CompanyUDF';


--CREATE RESULT TABLE. Store query result externaly in output_dir/qXXresult/
DROP TABLE IF EXISTS ${hiveconf:resultTableName};
CREATE TABLE ${hiveconf:resultTableName}
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'
STORED AS TEXTFILE LOCATION '${hiveconf:resultFile}' 
AS
-- Beginn: the real query part
SELECT find_company(pr_review_sk, pr_item_sk, pr_review_content)  AS (pr_review_sk, pr_item_sk, company_name, review_sentence) 
FROM (
	SELECT pr_review_sk, pr_item_sk, pr_review_content
	FROM product_reviews
	WHERE pr_item_sk = 10653
     ) subtable;
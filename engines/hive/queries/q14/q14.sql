--"INTEL CONFIDENTIAL"
--Copyright 2016 Intel Corporation All Rights Reserved.
--
--The source code contained or described herein and all documents related to the source code ("Material") are owned by Intel Corporation or its suppliers or licensors. Title to the Material remains with Intel Corporation or its suppliers and licensors. The Material contains trade secrets and proprietary and confidential information of Intel or its suppliers and licensors. The Material is protected by worldwide copyright and trade secret laws and treaty provisions. No part of the Material may be used, copied, reproduced, modified, published, uploaded, posted, transmitted, distributed, or disclosed in any way without Intel's prior express written permission.
--
--No license under any patent, copyright, trade secret or other intellectual property right is granted to or conferred upon you by disclosure or delivery of the Materials, either expressly, by implication, inducement, estoppel or otherwise. Any license under such intellectual property rights must be express and approved by Intel in writing.

-- based on tpc-ds q90
-- What is the ratio between the number of items sold over
-- the internet in the morning (7 to 8am) to the number of items sold in the evening
-- (7 to 8pm) of customers with a specified number of dependents. Consider only
-- websites with a high amount of content.

-- Resources

--Result  --------------------------------------------------------------------
--keep result human readable

set hive.exec.compress.output=false;
set hive.exec.compress.output;



--CREATE RESULT TABLE. Store query result externally in output_dir/qXXresult/
DROP TABLE IF EXISTS ${hiveconf:RESULT_TABLE};
CREATE TABLE ${hiveconf:RESULT_TABLE} (
  am_pm_ratio decimal(15,4)
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'
STORED AS ${env:BIG_BENCH_hive_default_fileformat_result_table} LOCATION '${hiveconf:RESULT_DIR}';

-- Begin: the real query part
explain
INSERT INTO TABLE ${hiveconf:RESULT_TABLE}
SELECT CAST(amc as double) / CAST(pmc as double) am_pm_ratio
FROM (
  SELECT COUNT(*) amc
  FROM web_sales ws
  JOIN household_demographics hd ON hd.hd_demo_sk = ws.ws_ship_hdemo_sk
  AND hd.hd_dep_count = ${hiveconf:q14_dependents}
  JOIN time_dim td ON td.t_time_sk = ws.ws_sold_time_sk
  AND td.t_hour >= ${hiveconf:q14_morning_startHour}
  AND td.t_hour <= ${hiveconf:q14_morning_endHour}
  JOIN web_page wp ON wp.wp_web_page_sk = ws.ws_web_page_sk
  AND wp.wp_char_count >= ${hiveconf:q14_content_len_min}
  AND wp.wp_char_count <= ${hiveconf:q14_content_len_max}
) at
JOIN (
  SELECT COUNT(*) pmc
  FROM web_sales ws
  JOIN household_demographics hd ON ws.ws_ship_hdemo_sk = hd.hd_demo_sk
  AND hd.hd_dep_count = ${hiveconf:q14_dependents}
  JOIN time_dim td ON td.t_time_sk = ws.ws_sold_time_sk
  AND td.t_hour >= ${hiveconf:q14_evening_startHour}
  AND td.t_hour <= ${hiveconf:q14_evening_endHour}
  JOIN web_page wp ON wp.wp_web_page_sk = ws.ws_web_page_sk
  AND wp.wp_char_count >= ${hiveconf:q14_content_len_min}
  AND wp.wp_char_count <= ${hiveconf:q14_content_len_max}
) pt
--result is a single line
;

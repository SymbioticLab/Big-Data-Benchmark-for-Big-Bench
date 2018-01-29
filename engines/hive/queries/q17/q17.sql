--"INTEL CONFIDENTIAL"
--Copyright 2016 Intel Corporation All Rights Reserved.
--
--The source code contained or described herein and all documents related to the source code ("Material") are owned by Intel Corporation or its suppliers or licensors. Title to the Material remains with Intel Corporation or its suppliers and licensors. The Material contains trade secrets and proprietary and confidential information of Intel or its suppliers and licensors. The Material is protected by worldwide copyright and trade secret laws and treaty provisions. No part of the Material may be used, copied, reproduced, modified, published, uploaded, posted, transmitted, distributed, or disclosed in any way without Intel's prior express written permission.
--
--No license under any patent, copyright, trade secret or other intellectual property right is granted to or conferred upon you by disclosure or delivery of the Materials, either expressly, by implication, inducement, estoppel or otherwise. Any license under such intellectual property rights must be express and approved by Intel in writing.

-- based on tpc-ds q61
-- Find the ratio of items sold with and without promotions
-- in a given month and year. Only items in certain categories sold to customers
-- living in a specific time zone are considered.

-- Resources


--Result  --------------------------------------------------------------------
--keep result human readable
set hive.exec.compress.output=false;
set hive.exec.compress.output;
--CREATE RESULT TABLE. Store query result externally in output_dir/qXXresult/
DROP TABLE IF EXISTS ${hiveconf:RESULT_TABLE};
CREATE TABLE ${hiveconf:RESULT_TABLE} (
  promotions decimal(15,2),
  total      decimal(15,2),
  cnt        decimal(15,2)
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'
STORED AS ${env:BIG_BENCH_hive_default_fileformat_result_table} LOCATION '${hiveconf:RESULT_DIR}';

-- the real query part
explain
INSERT INTO TABLE ${hiveconf:RESULT_TABLE}
-- no need to cast promotions or total to double: SUM(COL) already returned a DOUBLE
SELECT promotions, total, promotions / total * 100
FROM (
  SELECT SUM(ss_ext_sales_price) promotions
  FROM store_sales ss
  JOIN date_dim dd ON ss.ss_sold_date_sk = dd.d_date_sk
  JOIN item i ON ss.ss_item_sk = i.i_item_sk
  JOIN store s ON ss.ss_store_sk = s.s_store_sk
  JOIN promotion p ON ss.ss_promo_sk = p.p_promo_sk
  JOIN customer c ON ss.ss_customer_sk = c.c_customer_sk
  JOIN customer_address ca ON c.c_current_addr_sk = ca.ca_address_sk
  WHERE ca_gmt_offset = ${hiveconf:q17_gmt_offset}
  AND s_gmt_offset = ${hiveconf:q17_gmt_offset}
  AND i_category IN (${hiveconf:q17_i_category_IN})
  AND d_year = ${hiveconf:q17_year}
  AND d_moy = ${hiveconf:q17_month}
  AND (p_channel_dmail = 'Y' OR p_channel_email = 'Y' OR p_channel_tv = 'Y')
) promotional_sales
JOIN (
  SELECT SUM(ss_ext_sales_price) total
  FROM store_sales ss
  JOIN date_dim dd ON ss.ss_sold_date_sk = dd.d_date_sk
  JOIN item i ON ss.ss_item_sk = i.i_item_sk 
  JOIN store s ON ss.ss_store_sk = s.s_store_sk
  JOIN promotion p ON ss.ss_promo_sk = p.p_promo_sk
  JOIN customer c ON ss.ss_customer_sk = c.c_customer_sk
  JOIN customer_address ca ON c.c_current_addr_sk = ca.ca_address_sk
  WHERE ca_gmt_offset = ${hiveconf:q17_gmt_offset}
  AND s_gmt_offset = ${hiveconf:q17_gmt_offset}
  AND i_category IN (${hiveconf:q17_i_category_IN})
  AND d_year = ${hiveconf:q17_year}
  AND d_moy = ${hiveconf:q17_month}
) all_sales
-- we don't need a 'ON' join condition. result is just two numbers.
ORDER BY promotions, total
LIMIT 100 -- kinda useless, result is one line with two numbers, but original tpc-ds query has it too.
;

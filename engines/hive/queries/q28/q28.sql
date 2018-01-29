--"INTEL CONFIDENTIAL"
--Copyright 2016 Intel Corporation All Rights Reserved.
--
--The source code contained or described herein and all documents related to the source code ("Material") are owned by Intel Corporation or its suppliers or licensors. Title to the Material remains with Intel Corporation or its suppliers and licensors. The Material contains trade secrets and proprietary and confidential information of Intel or its suppliers and licensors. The Material is protected by worldwide copyright and trade secret laws and treaty provisions. No part of the Material may be used, copied, reproduced, modified, published, uploaded, posted, transmitted, distributed, or disclosed in any way without Intel's prior express written permission.
--
--No license under any patent, copyright, trade secret or other intellectual property right is granted to or conferred upon you by disclosure or delivery of the Materials, either expressly, by implication, inducement, estoppel or otherwise. Any license under such intellectual property rights must be express and approved by Intel in writing.


-- TASK
-- Build text classifier for online review sentiment classification (Positive,
-- Negative, Neutral), using 90% of available reviews for training and the remaining
-- 40% for testing. Display classifier accuracy on testing data 
-- and classification result for the 10% testing data: <reviewSK>,<originalRating>,<classificationResult>



-- This query requires parallel order by for fast and deterministic global ordering of final result
set hive.optimize.sampling.orderby=${hiveconf:bigbench.hive.optimize.sampling.orderby};
set hive.optimize.sampling.orderby.number=${hiveconf:bigbench.hive.optimize.sampling.orderby.number};
set hive.optimize.sampling.orderby.percent=${hiveconf:bigbench.hive.optimize.sampling.orderby.percent};
--debug print
set hive.optimize.sampling.orderby;
set hive.optimize.sampling.orderby.number;
set hive.optimize.sampling.orderby.percent;


--Result 1 Training table for classification
DROP TABLE IF EXISTS ${hiveconf:TEMP_TABLE1};
CREATE TABLE ${hiveconf:TEMP_TABLE1} (
  pr_review_sk      BIGINT,
  pr_rating         INT,
  pr_review_content STRING
);

--Result 2 Testing table for classification
DROP TABLE IF EXISTS ${hiveconf:TEMP_TABLE2};
CREATE TABLE ${hiveconf:TEMP_TABLE2} (
  pr_review_sk      BIGINT,
  pr_rating         INT,
  pr_review_content STRING
);

--Split reviews table into training and testing
explain
FROM (
  SELECT
    pr_review_sk,
    pr_review_rating,
    pr_review_content
  FROM product_reviews
  ORDER BY pr_review_sk
)p
INSERT OVERWRITE TABLE ${hiveconf:TEMP_TABLE1}
  SELECT *
  WHERE pmod(pr_review_sk, 10) IN (1,2,3,4,5,6,7,8,9) -- 90% are training
INSERT OVERWRITE TABLE ${hiveconf:TEMP_TABLE2}
  SELECT *
  WHERE pmod(pr_review_sk, 10) IN (0) -- 10% are testing
;

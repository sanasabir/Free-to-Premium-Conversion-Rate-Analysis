SHOW TABLES;

DESCRIBE student_engagement;
DESCRIBE student_info;
DESCRIBE student_purchases;


SELECT 
    ROUND(COUNT(a.student_id) / COUNT(a.student_id IS NOT NULL),
            2) * 100 AS conversion_rate,
    ROUND(SUM(a.date_diff_reg_watch) / COUNT(a.date_diff_reg_watch),
            2) AS av_reg_watch,
    ROUND(SUM(a.date_diff_watch_purch) / COUNT(a.date_diff_watch_purch),
            2) AS av_watch_purch
FROM


(SELECT
    si.student_id,
    si.date_registered,
    MIN(se.date_watched) AS first_date_watched,
    MIN(sp.date_purchased) AS first_date_purchased,
    DATEDIFF(MIN(se.date_watched), si.date_registered) AS date_diff_reg_watch,
    CASE 
        WHEN MIN(sp.date_purchased) IS NULL THEN NULL
        ELSE DATEDIFF(MIN(sp.date_purchased), MIN(se.date_watched))
    END AS date_diff_watch_purch
FROM
    student_info si
LEFT JOIN
    student_engagement se ON si.student_id = se.student_id
LEFT JOIN
    student_purchases sp ON si.student_id = sp.student_id
GROUP BY
    si.student_id, si.date_registered
HAVING
    MIN(se.date_watched) <= MIN(sp.date_purchased) OR MIN(sp.date_purchased) IS NULL
    
) a
WHERE
    a.first_date_watched IS NOT NULL;
    
    -- SELECT QUERY TO VERIFY

SELECT MIN(date_watched) from student_engagement where student_id = 268727;

SELECT MIN(date_purchased) from student_purchases where student_id = 268727;


-- CORRECTION FOR CONVERSION RATE

-- Subquery to get the necessary information for each student
WITH student_data AS (
    SELECT
        si.student_id,
        si.date_registered,
        MIN(se.date_watched) AS first_date_watched,
        MIN(sp.date_purchased) AS first_date_purchased
    FROM
        student_info si
    LEFT JOIN
        student_engagement se ON si.student_id = se.student_id
    LEFT JOIN
        student_purchases sp ON si.student_id = sp.student_id
    GROUP BY
        si.student_id, si.date_registered
    HAVING
        MIN(se.date_watched) IS NOT NULL
)

-- Main query to calculate conversion rate
SELECT
    ROUND(
        COUNT(CASE 
                  WHEN first_date_purchased IS NOT NULL AND first_date_watched <= first_date_purchased 
                  THEN 1 
              END) / 
        COUNT(student_id) * 100, 2) AS conversion_rate
FROM
    student_data;





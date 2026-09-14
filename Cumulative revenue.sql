-- Calculate the percentage of cumulative revenue achieved relative to cumulative goals (predict) by day.
-- Use the UNION operator to combine the revenue and goal data.

WITH
  revenue_per_date AS (
    SELECT
      s.date AS date,
      sum(p.price) AS revenue
    FROM `DA.order` AS o
    JOIN `DA.product` AS p
      ON o.item_id = p.item_id
    JOIN `DA.session` AS s
      ON s.ga_session_id = o.ga_session_id
    GROUP BY date
  ),
  predict_revenue_per_date AS (
    SELECT date, predict FROM `DA.revenue_predict`
  ),
  united AS (
    (SELECT date, revenue, NULL AS goal FROM revenue_per_date)
    UNION DISTINCT
    (
      SELECT date, NULL AS revenue, predict AS goal
      FROM predict_revenue_per_date
    )
  )
SELECT DISTINCT
  date,
  sum(revenue) OVER (ORDER BY date) AS cumulative_revenue,
  sum(goal) OVER (ORDER BY date) AS cumulative_predicted_revenue,
  sum(revenue)
    OVER (ORDER BY date) / sum(goal) OVER (ORDER BY date) * 100.0
    AS percentage
FROM united

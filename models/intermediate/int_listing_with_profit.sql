select
   listing_id,
   laptop_model,
   cost_price,
   listed_price,
   date_listed,
   date_sold,
   platform,
   listed_price - cost_price as profit,
   
   round((listed_price - cost_price) / cost_price * 100,2) as profit_margin_pct,
   date_sold - date_listed  as days_to_sell,

   sum(case when date_sold is not null then listed_price - cost_price else 0 end) over (order by date_sold) as           	running_cumulative_profit
from {{ ref('stg_listing') }}
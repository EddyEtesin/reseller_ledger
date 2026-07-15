select
   listing_id,
   laptop_model,
   cost_price,
   listed_price,
   date_listed,
   date_sold,
   platform,
   profit,
   profit_margin_pct,
   days_to_sell,
   running_cumulative_profit,
   case when date_sold is null then true else false end as still_unsold
from {{ ref('int_listing_with_profit')}}
order by date_listed

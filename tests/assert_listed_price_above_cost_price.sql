select
   listing_id,
   laptop_model,
   cost_price,
   listed_price,
from {{ ref('stg_listing') }}
where listed_price < cost_price




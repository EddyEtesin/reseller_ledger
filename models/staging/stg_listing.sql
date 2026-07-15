select
   listing_id,
   laptop_model,
   cost_price,
   listed_price,
   date_listed,
   date_sold,
   platform
from {{ ref('raw_listing') }}



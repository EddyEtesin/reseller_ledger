# Reseller Ledger

A small data project that tracks laptop reselling activity — what was bought,
what it sold for, how long it took to sell, and how profit builds up over
time — built on real PC reselling business logic.

---

## In plain terms (you don't need a technical background)

Imagine you're tracking every laptop you buy and resell: what you paid for it,
what you listed it for, when it sold (if it has), and which platform (WhatsApp
or Telegram) the sale came through.

This project answers questions like:
- **How much profit did each sale actually make?**
- **How long did each laptop sit before it sold?**
- **How is total profit building up over time, sale by sale?**
- **Did I ever accidentally list something below what I paid for it?**

That last question matters more than it sounds — it's easy to mistype a price
or misjudge a listing in a busy WhatsApp group, and not notice until you've
already sold at a loss. This project includes an automatic check that flags
exactly that: any listing priced below its cost, before it becomes a habit
you don't notice.

The project also tracks a **running total** of profit — so instead of only
knowing your total profit at the end, you can see how it grew sale by sale,
which sales contributed the most, and which (if any) pulled it backward.

---

## Technical overview

Built with **dbt** and **DuckDB**, following the same layered pipeline
pattern as other projects in this series (Naira Watch, Naija Cart):

```
raw_listings.csv → stg_listing → int_listing_with_profit → listing_summary
                                  (profit, margin, days-to-sell,
                                   running cumulative profit)
```

**Key concepts demonstrated:**

- **Seed** — `raw_listings.csv` holds cost price, listed price, listing/sale
  dates, and platform for 12 laptop listings (some still unsold)
- **Staging model** (`stg_listing`) — light passthrough/cleanup layer
- **Intermediate model** (`int_listing_with_profit`) — calculates:
  - `profit` and `profit_margin_pct` (margin measured against cost price,
    the correct baseline for a % change calculation)
  - `days_to_sell` — date arithmetic that correctly returns `NULL` for
    unsold listings rather than erroring
  - `running_cumulative_profit` — a **running total window function**:
    ```sql
    sum(case when date_sold is not null then listed_price - cost_price else 0 end)
        over (order by date_sold)
    ```
    Unsold listings are forced to contribute `0` rather than `NULL` to the
    running total — summing anything against `NULL` silently produces `NULL`
    and wipes out the entire running total from that point forward, a
    classic SQL gotcha this handles explicitly.
- **Mart model** (`listing_summary`) — final presentation layer, includes a
  derived boolean flag (`still_unsold`) so downstream users don't need to
  remember that a blank `date_sold` means unsold
- **Tests:**
  - Generic: `unique` / `not_null` on `listing_id`, `cost_price`, `listed_price`
  - Singular: `assert_listed_price_above_cost_price.sql` — a custom SQL
    check enforcing a real business rule ("never list below cost"), which
    correctly fails against a deliberately planted below-cost listing in
    the sample data

**Verified with real data:** the running total was checked row-by-row to
confirm it climbs correctly with each sale and dips appropriately after a
below-cost sale, while unsold listings correctly freeze the total rather
than nulling it out.

**Stack:** dbt-core, dbt-duckdb, DuckDB (local file-based database)

**To run locally:**
```
dbt seed
dbt run
dbt test
```

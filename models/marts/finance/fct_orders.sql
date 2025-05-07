with
    stripe_payments as (
        select * from {{ ref('stg_payments') }}
    ),
    stg_order as (
        select * from {{ ref('stg_orders') }}
    ),
    order_payments as (
        select
            order_id,
            sum (case when status = 'success' then amount end) as amount
        from stripe_payments
        group by 1
    ),
    _union as (
        select
            a.order_id,
            a.customer_id,
            a.order_date,
            coalesce(b.amount, 0) as amount
        from stg_order as a
        left join order_payments as b
            using (order_id)
    )
select * from _union
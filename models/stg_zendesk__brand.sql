{{ config(alias='stg_zendesk_brand') }}

with base as (

    select *
    from {{ var('brand') }}

),

fields as (

    select
        /*
        The below macro is used to generate the correct SQL for package staging models. It takes a list of columns
        that are expected/needed (staging_columns from dbt_zendesk_source/models/tmp/) and compares it with columns
        in the source (source_columns from dbt_zendesk_source/macros/).
        For more information refer to our dbt_fivetran_utils documentation (https://github.com/fivetran/dbt_fivetran_utils.git).
        */
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(var('brand')),
                staging_columns=get_brand_columns()
            )
        }}

    from base
),

final as (

    select
        id as brand_id,
        brand_url,
        name,
        subdomain,
        active as is_active
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final

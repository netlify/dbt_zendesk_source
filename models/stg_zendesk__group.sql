{{ config(alias='stg_zendesk_group') }}

with base as (

    select *
    from {{ var('group') }}

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
                source_columns=adapter.get_columns_in_relation(var('group')),
                staging_columns=get_group_columns()
            )
        }}

    from base
),

final as (

    select
        id as group_id,
        name
    from fields

    where not coalesce(_fivetran_deleted, false)
)

select *
from final

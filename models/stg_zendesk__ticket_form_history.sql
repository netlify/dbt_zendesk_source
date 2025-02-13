--To disable this model, set the using_ticket_form_history variable within your dbt_project.yml file to False.
{{ config(
    alias='stg_zendesk_ticket_form_history',
    enabled=var('using_ticket_form_history', True)
) }}

with base as (

    select *
    from {{ var('ticket_form_history') }}

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
                source_columns=adapter.get_columns_in_relation(var('ticket_form_history')),
                staging_columns=get_ticket_form_history_columns()
            )
        }}

    from base
),

final as (

    select
        id as ticket_form_id,
        created_at,
        updated_at,
        display_name,
        active as is_active,
        name
    from fields
    where not coalesce(_fivetran_deleted, false)

)

select *
from final

--To disable this model, set the using_schedules variable within your dbt_project.yml file to False.
{{ config(
    alias='stg_zendesk_schedule',
    enabled=var('using_schedules', True)
) }}

with base as (

    select *
    from {{ var('schedule') }}

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
                source_columns=adapter.get_columns_in_relation(var('schedule')),
                staging_columns=get_schedule_columns()
            )
        }}

    from base
),

final as (

    select
        cast(id as {{ dbt_utils.type_string() }}) as schedule_id, --need to convert from numeric to string for downstream models to work properly
        end_time_utc,
        start_time_utc,
        name as schedule_name,
        created_at
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final

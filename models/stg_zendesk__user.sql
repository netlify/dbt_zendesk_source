{{ config(alias='stg_zendesk_user') }}

with base as (

    select *
    from {{ ref('stg_zendesk__user_tmp') }}

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
                source_columns=adapter.get_columns_in_relation(ref('stg_zendesk__user_tmp')),
                staging_columns=get_user_columns()
            )
        }}

    from base
),

final as (

    select
        id as user_id,
        external_id,
        _fivetran_synced,
        created_at,
        updated_at,
        email,
        name,
        organization_id,
        role,
        ticket_restriction,
        time_zone,
        locale,
        active as is_active,
        suspended as is_suspended,
        last_login_at
    from fields
)

select *
from final

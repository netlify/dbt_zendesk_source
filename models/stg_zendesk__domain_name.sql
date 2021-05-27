--To disable this model, set the using_domain_names variable within your dbt_project.yml file to False.
{{ config(
    alias='stg_zendesk_domain_name',
    enabled=var('using_domain_names', True)
) }}

with base as (

    select *
    from {{ var('domain_name') }}

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
                source_columns=adapter.get_columns_in_relation(var('domain_name')),
                staging_columns=get_domain_name_columns()
            )
        }}

    from base
),

final as (

    select
        organization_id,
        domain_name,
        index
    from fields
)

select *
from final

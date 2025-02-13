--To disable this model, set the using_user_tags variable within your dbt_project.yml file to False.
{{ config(
    alias='stg_zendesk_user_tag',
    enabled=var('using_user_tags', True)
) }}

with base as (

    select *
    from {{ var('user_tag') }}

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
                source_columns=adapter.get_columns_in_relation(var('user_tag')),
                staging_columns=get_user_tag_columns()
            )
        }}

    from base
),

final as (

    select
        user_id,
        {% if target.type == 'redshift' %}
        'tag'
        {% else %}
        tag
        {% endif %}
        as tags
    from fields
)

select *
from final

from datasette import hookimpl


@hookimpl
def extra_template_vars(datasette):
    async def execute_sql(sql, args=None, database=None):
        db = datasette.get_database(database)
        return (await db.execute(sql, args)).rows

    return {"sql": execute_sql}

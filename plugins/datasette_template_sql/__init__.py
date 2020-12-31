from datasette import hookimpl


@hookimpl
def extra_template_vars(datasette, database):
    async def execute_sql(sql, args=None, database=None):
        database = database or database or next(iter(datasette.databases.keys()))
        return (await datasette.execute(database, sql, args)).rows

    return {"sql": execute_sql}

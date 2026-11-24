FROM metabase/metabase:v0.65.5.1

USER root

RUN mkdir -p /app/data /plugins && chmod -R 777 /app/data /plugins /tmp

COPY datahunters_dw.sqlite /app/data/datahunters_dw.sqlite
COPY metabase.db.mv.db /app/data/metabase.db.mv.db
COPY start-metabase.sh /app/start-metabase.sh

RUN chmod -R 777 /app/data

ENV MB_DB_TYPE=h2 \
    MB_DB_FILE=/app/data/metabase.db \
    MB_JETTY_PORT=7860 \
    MB_JETTY_HOST=0.0.0.0 \
    MB_PLUGINS_DIR=/plugins \
    JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=40.0 -XX:+UseSerialGC -XX:+ExitOnOutOfMemoryError"

EXPOSE 7860

USER 1000

ENTRYPOINT ["/bin/sh", "/app/start-metabase.sh"]

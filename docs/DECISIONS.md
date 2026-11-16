# DECISIONS

## TECH STACK

    1. Language: Go and Gin
        Chose go as i am familiar with it and wanted to build and API on that , had python as my second choice which i may use it for MCP integrations
        Gin's parsing and validation leave more time for engineering the product
    2. Database and Migrations:MySQL vs postgres, chose postgres,goose , sqlc
        used it before and i am familiar with it, helps to catch issues early with queries and stuff using sqlc
    3. CI: Github actions
        widely popular and wanted to learn it

## NOTE

    MCP language defered to Phase-5 as i am now sure which language to use right now

## Folder layout

    i went with standard go layout of cmd/ + internal/ with every feature getting it own folder so that its Easy to add or remove a feature later

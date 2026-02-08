# Model-Catalogue Endpoints

## Endpoints Used

Base URL:
- `https://model-catalogue-api.azr.internal.wayve.ai`

Nickname search:
- `GET /v2/models/search`
- Query params:
- `search=<text>`
- `limit=<n>`
- `ingested_only=true`

Author search:
- `POST /v2/models`
- Payload shape:
```json
{
  "page": 0,
  "items_per_page": 25,
  "sort": "ingested_at",
  "sort_direction": "DESC",
  "archived": false,
  "filters": [
    {
      "items": [
        {"id": 0, "columnField": "author", "operatorValue": "contains", "value": "boris"}
      ],
      "linkOperator": "or"
    }
  ]
}
```

Deep model details:
- `GET /v3/model/<model_id>`

## Auth

- Optional bearer header:
- `Authorization: Bearer $MODEL_CATALOGUE_TOKEN`

## Troubleshooting

- `401` or `403`: Token missing/invalid for your environment.
- Empty result set: Expand query text, increase `--limit`, or switch lookup type.
- `5xx`: Retry after a short delay.

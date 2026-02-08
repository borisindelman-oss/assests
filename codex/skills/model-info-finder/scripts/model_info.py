#!/usr/bin/env python3
"""Query model-catalogue by nickname or author and print basic/deep info."""

from __future__ import annotations

import argparse
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
from typing import Any, Dict, List, Optional


DEFAULT_BASE_URL = "https://model-catalogue-api.azr.internal.wayve.ai"


def _request_json(
    method: str,
    url: str,
    token: Optional[str] = None,
    payload: Optional[Dict[str, Any]] = None,
) -> Any:
    data = None
    headers = {"Accept": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
        headers["Content-Type"] = "application/json"

    req = urllib.request.Request(url=url, data=data, method=method, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"HTTP {exc.code} for {url}: {body[:400]}") from exc
    except urllib.error.URLError as exc:
        raise RuntimeError(f"Request failed for {url}: {exc}") from exc


def _extract_models(data: Any) -> List[Dict[str, Any]]:
    if isinstance(data, list):
        return [x for x in data if isinstance(x, dict)]
    if isinstance(data, dict):
        for key in ("rows", "items", "results", "models", "data"):
            value = data.get(key)
            if isinstance(value, list):
                return [x for x in value if isinstance(x, dict)]
    return []


def _search_by_nickname(base_url: str, token: Optional[str], query: str, limit: int) -> List[Dict[str, Any]]:
    params = urllib.parse.urlencode(
        {
            "search": query,
            "limit": str(limit),
            "ingested_only": "true",
        }
    )
    url = f"{base_url}/v2/models/search?{params}"
    response = _request_json("GET", url, token=token)
    return _extract_models(response)


def _search_by_author(base_url: str, token: Optional[str], query: str, limit: int) -> List[Dict[str, Any]]:
    url = f"{base_url}/v2/models"
    payload: Dict[str, Any] = {
        "page": 0,
        "items_per_page": limit,
        "sort": "ingested_at",
        "sort_direction": "DESC",
        "archived": False,
        "filters": [
            {
                "items": [
                    {"id": 0, "columnField": "author", "operatorValue": "contains", "value": query},
                ],
                "linkOperator": "or",
            }
        ],
    }
    response = _request_json("POST", url, token=token, payload=payload)
    return _extract_models(response)


def _model_id(model: Dict[str, Any]) -> Optional[str]:
    for key in ("id", "model_session_id", "session_id"):
        value = model.get(key)
        if isinstance(value, str) and value:
            return value
    return None


def _fetch_details(base_url: str, token: Optional[str], models: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    details = []
    for model in models:
        model_id = _model_id(model)
        if not model_id:
            continue
        url = f"{base_url}/v3/model/{urllib.parse.quote(model_id, safe='')}"
        try:
            details_json = _request_json("GET", url, token=token)
            details.append(
                {
                    "model_id": model_id,
                    "summary": model,
                    "details": details_json,
                }
            )
        except RuntimeError as exc:
            details.append(
                {
                    "model_id": model_id,
                    "summary": model,
                    "details_error": str(exc),
                }
            )
    return details


def _basic_projection(model: Dict[str, Any]) -> Dict[str, Any]:
    return {
        "id": _model_id(model),
        "nickname": model.get("nickname"),
        "author": model.get("author"),
        "ingested_at": model.get("ingested_at"),
        "checkpoint_count": len(model.get("checkpoints", {})) if isinstance(model.get("checkpoints"), dict) else None,
        "raw_keys": sorted(model.keys()),
    }


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Find model info from model-catalogue.")
    parser.add_argument("--query", required=True, help="Nickname text or author text.")
    parser.add_argument(
        "--by",
        choices=("nickname", "author"),
        default="nickname",
        help="Lookup strategy.",
    )
    parser.add_argument(
        "--mode",
        choices=("basic", "deep"),
        default="basic",
        help="basic = summaries only, deep = include per-model /v3/model/<id> details.",
    )
    parser.add_argument("--limit", type=int, default=5, help="Maximum models to return.")
    parser.add_argument(
        "--base-url",
        default=os.environ.get("MODEL_CATALOGUE_API", DEFAULT_BASE_URL),
        help="Model catalogue base URL.",
    )
    parser.add_argument(
        "--token",
        default=os.environ.get("MODEL_CATALOGUE_TOKEN"),
        help="Bearer token. Defaults to MODEL_CATALOGUE_TOKEN.",
    )
    parser.add_argument("--json", action="store_true", help="Print JSON output only.")
    return parser.parse_args()


def main() -> int:
    args = _parse_args()
    if args.limit <= 0:
        print("--limit must be > 0", file=sys.stderr)
        return 2

    base_url = args.base_url.rstrip("/")

    try:
        if args.by == "nickname":
            models = _search_by_nickname(base_url, args.token, args.query, args.limit)
        else:
            models = _search_by_author(base_url, args.token, args.query, args.limit)
    except RuntimeError as exc:
        print(str(exc), file=sys.stderr)
        return 1

    if args.mode == "basic":
        payload: Dict[str, Any] = {
            "query": args.query,
            "by": args.by,
            "mode": args.mode,
            "count": len(models),
            "models": [_basic_projection(model) for model in models],
        }
    else:
        payload = {
            "query": args.query,
            "by": args.by,
            "mode": args.mode,
            "count": len(models),
            "models": _fetch_details(base_url, args.token, models),
        }

    if args.json:
        print(json.dumps(payload, indent=2, sort_keys=True))
        return 0

    print(f"query={args.query} by={args.by} mode={args.mode} results={payload['count']}")
    if args.mode == "basic":
        for i, model in enumerate(payload["models"], start=1):
            print(
                f"{i}. id={model.get('id')} "
                f"nickname={model.get('nickname')} "
                f"author={model.get('author')} "
                f"ingested_at={model.get('ingested_at')}"
            )
    else:
        for i, model in enumerate(payload["models"], start=1):
            detail_state = "ok" if "details" in model else f"error={model.get('details_error')}"
            print(
                f"{i}. model_id={model.get('model_id')} "
                f"nickname={model.get('summary', {}).get('nickname')} "
                f"details={detail_state}"
            )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from src.database import create_example, get_example, list_examples

router = APIRouter(prefix="/api/v1", tags=["examples"])


class CreateExampleRequest(BaseModel):
    name: str


@router.post("/examples")
async def api_create_example(req: CreateExampleRequest):
    result = await create_example(req.name)
    return result


@router.get("/examples/{example_id}")
async def api_get_example(example_id: int):
    result = await get_example(example_id)
    if not result:
        raise HTTPException(status_code=404, detail="Not found")
    return result


@router.get("/examples")
async def api_list_examples(limit: int = 50, offset: int = 0):
    return await list_examples(limit=limit, offset=offset)

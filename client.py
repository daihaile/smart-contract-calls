import asyncio
import logging
import json

from jsonrpcclient import Ok, parse_json, request_json, request
import websockets


async def main():
  #message = '{"method": "debug_traceTransaction", "params": ["0x73c8713a47d03c8d2c47526a4c3f08af8b8feb0f9f68e1f1dfaede10154dee5b", {tracer: "callTracer"}]}'
  #req = request("debug_traceTransaction", id="2412", params=("0x73c8713a47d03c8d2c47526a4c3f08af8b8feb0f9f68e1f1dfaede10154dee5b", {"tracer": "callTracer"}))

  async with websockets.connect("ws://localhost:8549") as ws:
      #params = {"0x73c8713a47d03c8d2c47526a4c3f08af8b8feb0f9f68e1f1dfaede10154dee5b", {"tracer": "callTracer"}}
      req = request_json("debug_traceTransaction", params=("0x73c8713a47d03c8d2c47526a4c3f08af8b8feb0f9f68e1f1dfaede10154dee5b",{'tracer': 'callTracer'}),id=2412)
      print()
      print(req)
      print()
      await ws.send(req)
      response = parse_json(await ws.recv())

  if isinstance(response, Ok):
      print(response.result)
  else:
      logging.error(response.message)


asyncio.get_event_loop().run_until_complete(main())

import asyncio
import json
import logging
import os
import time
import aiohttp
from aiohttp import web

BOT_TOKEN = os.environ.get("BOT_TOKEN")
GUILD_ID = "1510327199608082562"
VERIFY_ROLE_ID = "1559993509530837095"
MIN_ACCOUNT_AGE_DAYS = 3

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger("VYNX_SECURITY")

API_BASE = "https://discord.com/api/v10"
HEADERS = {
    "Authorization": f"Bot {BOT_TOKEN}",
    "Content-Type": "application/json",
    "User-Agent": "VYNX-SecurityBot (v1.0)"
}

async def api_call(session, method, endpoint, data=None):
    url = f"{API_BASE}{endpoint}"
    async with session.request(method, url, headers=HEADERS, json=data) as resp:
        if resp.status in (200, 201):
            return await resp.json()
        elif resp.status == 204:
            return True
        return None

async def handle_interaction(session, data):
    int_id = data["id"]
    int_token = data["token"]
    user_data = data.get("member", {}).get("user", {})
    user_id = user_data.get("id")
    custom_id = data.get("data", {}).get("custom_id", "")

    if custom_id in ("verify_member", "vynx_verify_btn"):
        created_timestamp = ((int(user_id) >> 22) + 1420070400000) / 1000.0
        account_age_days = (time.time() - created_timestamp) / 86400.0

        if account_age_days < MIN_ACCOUNT_AGE_DAYS:
            msg = f"❌ **Verification Failed**: Your Discord account must be at least {MIN_ACCOUNT_AGE_DAYS} days old."
        else:
            endpoint = f"/guilds/{GUILD_ID}/members/{user_id}/roles/{VERIFY_ROLE_ID}"
            res = await api_call(session, "PUT", endpoint)
            if res:
                msg = "✅ **Verified**: Full access to VYNX unlocked."
            else:
                msg = "⚠️ **Missing Permissions**: Move the `VYNX DEV` role above `VYNX User` in server settings."

        resp_payload = {"type": 4, "data": {"content": msg, "flags": 64}}
        await api_call(session, "POST", f"/interactions/{int_id}/{int_token}/callback", resp_payload)

async def run_bot():
    async with aiohttp.ClientSession() as session:
        while True:
            try:
                async with session.ws_connect("wss://gateway.discord.gg/?v=10&encoding=json") as ws:
                    last_sequence = None
                    heartbeat_task = None

                    async def heartbeat(interval):
                        try:
                            while True:
                                await asyncio.sleep(interval / 1000.0)
                                await ws.send_json({"op": 1, "d": last_sequence})
                        except asyncio.CancelledError:
                            pass

                    async for msg in ws:
                        if msg.type == aiohttp.WSMsgType.TEXT:
                            p = json.loads(msg.data)
                            op, d, s, t = p.get("op"), p.get("d"), p.get("s"), p.get("t")
                            if s is not None:
                                last_sequence = s
                            if op == 10:
                                heartbeat_task = asyncio.create_task(heartbeat(d["heartbeat_interval"]))
                                await ws.send_json({
                                    "op": 2,
                                    "d": {
                                        "token": BOT_TOKEN,
                                        "intents": 513,
                                        "properties": {"os": "linux", "browser": "vynx", "device": "vynx"}
                                    }
                                })
                            elif op == 0 and t == "INTERACTION_CREATE":
                                asyncio.create_task(handle_interaction(session, d))
                        elif msg.type in (aiohttp.WSMsgType.CLOSED, aiohttp.WSMsgType.ERROR):
                            break

                    if heartbeat_task:
                        heartbeat_task.cancel()
            except Exception as e:
                logger.error(f"Error: {e}")
                await asyncio.sleep(5)

# Health-check server สำหรับ Render Free Tier
async def start_web_server():
    app = web.Application()
    app.router.add_get("/", lambda r: web.Response(text="VYNX Bot Online 24/7"))
    runner = web.AppRunner(app)
    await runner.setup()
    port = int(os.environ.get("PORT", 8080))
    site = web.TCPSite(runner, "0.0.0.0", port)
    await site.start()

async def main():
    await asyncio.gather(start_web_server(), run_bot())

if __name__ == "__main__":
    asyncio.run(main())

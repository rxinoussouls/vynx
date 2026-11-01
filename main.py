import asyncio
import json
import logging
import os
import random
import time
import aiohttp
from aiohttp import web

BOT_TOKEN = os.environ.get("BOT_TOKEN", "").strip()
GUILD_ID = "1510327199608082562"
VERIFY_ROLE_ID = "1559993509530837095"
MIN_ACCOUNT_AGE_DAYS = 3

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(name)s: %(message)s")
logger = logging.getLogger("VYNX_SECURITY")

API_BASE = "https://discord.com/api/v10"

def get_headers():
    return {
        "Authorization": f"Bot {BOT_TOKEN}",
        "Content-Type": "application/json",
        "User-Agent": "VYNX-SecurityBot (v2.0)"
    }

async def api_request(session, method, endpoint, data=None):
    url = f"{API_BASE}{endpoint}"
    try:
        async with session.request(method, url, headers=get_headers(), json=data) as resp:
            text = await resp.text()
            if resp.status in (200, 201):
                return json.loads(text) if text else {}
            elif resp.status == 204:
                return True
            else:
                logger.error(f"Discord API {method} {endpoint} -> HTTP {resp.status}: {text}")
                return None
    except Exception as e:
        logger.error(f"API Exception ({method} {endpoint}): {e}")
        return None

async def handle_interaction(session, data):
    int_id = data.get("id")
    int_token = data.get("token")
    app_id = data.get("application_id")
    user_data = data.get("member", {}).get("user", {})
    user_id = user_data.get("id")
    custom_id = data.get("data", {}).get("custom_id", "")

    if custom_id not in ("verify_member", "vynx_verify_btn"):
        return

    # 1. Defer Ephemeral ทันทีใน 0.1 วิ ป้องกัน 3s timeout
    defer_payload = {"type": 5, "data": {"flags": 64}}
    await api_request(session, "POST", f"/interactions/{int_id}/{int_token}/callback", defer_payload)

    # 2. ตรวจสอบอายุ Discord Account
    created_ts = ((int(user_id) >> 22) + 1420070400000) / 1000.0
    account_age_days = (time.time() - created_ts) / 86400.0

    if account_age_days < MIN_ACCOUNT_AGE_DAYS:
        msg = f"❌ **Verification Failed**: บัญชี Discord ของคุณต้องมีอายุอย่างน้อย {MIN_ACCOUNT_AGE_DAYS} วัน"
    else:
        # 3. ให้ยศ Verify แก่ Member
        endpoint = f"/guilds/{GUILD_ID}/members/{user_id}/roles/{VERIFY_ROLE_ID}"
        res = await api_request(session, "PUT", endpoint)
        if res:
            msg = "✅ **Verified**: ปลดล็อกการเข้าถึงระบบ VYNX เรียบร้อยแล้ว!"
            logger.info(f"Verified member: {user_data.get('username')} ({user_id})")
        else:
            msg = (
                "⚠️ **Missing Permissions**: บอทไม่สามารถให้ยศได้\n"
                "โปรดตรวจสอบใน Discord Server Settings > Roles ให้ลากยศ **VYNX DEV** ไว้สูงกว่ายศ **VYNX User**"
            )
            logger.error(f"Failed to give role to {user_id}")

    # 4. อัปเดตข้อความหลังประมวลผลเสร็จ
    edit_endpoint = f"/webhooks/{app_id}/{int_token}/messages/@original"
    await api_request(session, "PATCH", edit_endpoint, {"content": msg})

async def run_bot():
    if not BOT_TOKEN:
        logger.critical("BOT_TOKEN is not configured! Please set BOT_TOKEN in Environment Variables.")
        return

    async with aiohttp.ClientSession() as session:
        while True:
            try:
                ws_url = "wss://gateway.discord.gg/?v=10&encoding=json"
                async with session.ws_connect(ws_url, heartbeat=30) as ws:
                    last_seq = None
                    heartbeat_task = None

                    async def heartbeat_loop(interval):
                        try:
                            await asyncio.sleep((interval / 1000.0) * random.random())
                            while True:
                                await ws.send_json({"op": 1, "d": last_seq})
                                await asyncio.sleep(interval / 1000.0)
                        except asyncio.CancelledError:
                            pass

                    logger.info("Connected to Discord Gateway.")
                    async for msg in ws:
                        if msg.type == aiohttp.WSMsgType.TEXT:
                            payload = json.loads(msg.data)
                            op = payload.get("op")
                            d = payload.get("d")
                            s = payload.get("s")
                            t = payload.get("t")

                            if s is not None:
                                last_seq = s

                            if op == 10:  # Hello
                                interval = d["heartbeat_interval"]
                                heartbeat_task = asyncio.create_task(heartbeat_loop(interval))
                                await ws.send_json({
                                    "op": 2,
                                    "d": {
                                        "token": BOT_TOKEN,
                                        "intents": 513,
                                        "properties": {"os": "linux", "browser": "vynx", "device": "vynx"}
                                    }
                                })
                            elif op == 1:
                                await ws.send_json({"op": 1, "d": last_seq})
                            elif op == 7:
                                logger.info("Discord Gateway requested reconnect.")
                                break
                            elif op == 9:
                                logger.warning("Discord Gateway invalid session.")
                                await asyncio.sleep(2)
                                break
                            elif op == 0:
                                if t == "READY":
                                    user = d.get("user", {})
                                    logger.info(f"Bot online as {user.get('username')}")
                                elif t == "INTERACTION_CREATE":
                                    asyncio.create_task(handle_interaction(session, d))

                        elif msg.type in (aiohttp.WSMsgType.CLOSED, aiohttp.WSMsgType.ERROR):
                            logger.warning(f"WebSocket closed: {msg.type} (code={ws.close_code})")
                            break

                    if heartbeat_task:
                        heartbeat_task.cancel()

            except Exception as e:
                logger.error(f"Gateway error: {e}")

            logger.info("Reconnecting in 5 seconds...")
            await asyncio.sleep(5)

# Health-check server สำหรับ Render & UptimeRobot
async def start_web_server():
    app = web.Application()
    app.router.add_get("/", lambda r: web.Response(text="VYNX Security Bot Online 24/7", content_type="text/plain"))
    runner = web.AppRunner(app)
    await runner.setup()
    port = int(os.environ.get("PORT", 8080))
    site = web.TCPSite(runner, "0.0.0.0", port)
    await site.start()
    logger.info(f"Health-check web server running on port {port}")

async def main():
    await asyncio.gather(start_web_server(), run_bot())

if __name__ == "__main__":
    asyncio.run(main())

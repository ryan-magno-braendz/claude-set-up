---
name: CityFleet Server SSH Access
description: SSH credentials and project paths for the CityFleet production server on Digital Ocean
type: project
originSessionId: 5aafc404-d9b0-408f-809d-2abd6bb63a61
---
CityFleet runs on a Digital Ocean server. SSH access:

```
ssh -i ~/.ssh/id_ed25519 root@170.64.148.51
```

**Why:** Server was migrated to Digital Ocean (old AWS IP 13.55.139.88 is dead). Eden added Gabriel's key (`~/.ssh/id_ed25519`) to the new server.

**Key paths on server:**
| Path | Purpose |
|------|---------|
| `/opt/cityfleet-recovery/` | Project root |
| `/opt/cityfleet-recovery/dashboard-api/server.py` | FastAPI backend (port 8090 via Docker) |
| `/var/www/dashboard-cityfleet/index.html` | Dashboard frontend (served by nginx) |
| `/var/www/dashboard-cityfleet/` | All dashboard HTML/JS files |
| `/opt/cityfleet-recovery/nginx/` | Nginx configs |

**Service management:**
```bash
cd /opt/cityfleet-recovery && docker compose ps
docker compose restart dashboard-api   # restart backend
```

**URLs:**
- Dashboard: `https://db-cityfleet.aianswers.store`
- API (proxied): `https://db-cityfleet.aianswers.store/dashboard-api/`
- n8n: `https://n8n-cityfleet.aianswers.store`
- pgAdmin (SSH tunnel only): `ssh -L 5050:localhost:5050 root@170.64.148.51` → `http://localhost:5050`

**How to apply:** Use `scp` + `python3 /tmp/patch.py` pattern for file edits (heredoc fails with HTML/CSS content).

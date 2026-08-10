#!/usr/bin/env python3
import base64, hashlib, json, os, subprocess, tempfile
from pathlib import Path

SCRIPT = Path(__file__).with_name("nix-home")
def binary(name, body):
    data = ("#!/bin/sh\n" + body + "\n").encode()
    return {"name": name, "target": ".local/bin/" + name, "mode": "0755",
            "sha256": hashlib.sha256(data).hexdigest(), "bytesBase64": base64.b64encode(data).decode()}
def dto(action="realize", version="one", files=None):
    return {"schema": 1, "action": action, "binaries": [binary("karsa", "echo "+version), binary("karsa-composition", "echo c"+version)],
            "nixHome": {"realization": {"packages": [], "files": files or {}}}}
def run(home, value, ok=True, env=None):
    e = os.environ | {"HOME": str(home), "PATH": str(home/".local/bin")+os.pathsep+os.environ["PATH"]} | (env or {})
    p = subprocess.run([SCRIPT, value["action"], "--json-stdin"], input=json.dumps(value)+"\n", text=True, capture_output=True, env=e)
    assert (p.returncode == 0) == ok, (p.stdout, p.stderr)
    return p
with tempfile.TemporaryDirectory() as td:
    h=Path(td); (h/".local/bin").mkdir(parents=True)
    run(h, dto("preflight")); proof=json.loads(run(h,dto()).stdout); assert proof["pathPrecedence"]=="proven" # first/PATH
    assert run(h,dto()).returncode==0 # repeat
    run(h,dto(version="two")); assert subprocess.check_output([h/".local/bin/karsa"],text=True).strip()=="two" # update
    run(h,{"schema":1,"action":"rollback"}); assert subprocess.check_output([h/".local/bin/karsa"],text=True).strip()=="one"
    run(h,{"schema":1,"action":"rollback"}); assert subprocess.check_output([h/".local/bin/karsa"],text=True).strip()=="two" # convergent swap
    # malformed/private metadata and hash mismatch
    bad=dto(); bad["privatePayload"]="secret"; run(h,bad,False)
    bad=dto(); bad["binaries"][0]["sha256"]="0"*64; run(h,bad,False)
    before=os.path.realpath(h/".local/bin/karsa"); bad=dto(version="bad",files={"foreign":"/nix/store/missing"}); run(h,bad,False); assert os.path.realpath(h/".local/bin/karsa")==before
    # teardown/reprovision
    import shutil; shutil.rmtree(h/".local"); (h/".local/bin").mkdir(parents=True); run(h,dto()); assert (h/".local/bin/karsa").exists()
with tempfile.TemporaryDirectory() as td:
    h=Path(td); (h/".local/bin").mkdir(parents=True); (h/".local/bin/karsa").write_text("foreign")
    run(h,dto("preflight"),False) # collision
with tempfile.TemporaryDirectory() as td:
    h=Path(td); (h/".local/bin").mkdir(parents=True); other=h/"other"; other.mkdir(); (other/"karsa").write_text("x")
    run(h,dto("preflight"),False,{"PATH":str(other)+os.pathsep+str(h/".local/bin")}) # PATH denial
print("12 deterministic realizer scenarios passed")

#!/usr/bin/env python3
import base64, hashlib, json, os, shutil, subprocess, sys, tempfile
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
    p = subprocess.run([sys.executable, SCRIPT, value["action"], "--json-stdin"], input=json.dumps(value)+"\n", text=True, capture_output=True, env=e)
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
    shutil.rmtree(h/".local"); (h/".local/bin").mkdir(parents=True); run(h,dto()); assert (h/".local/bin/karsa").exists()
with tempfile.TemporaryDirectory() as td:
    h=Path(td); (h/".local/bin").mkdir(parents=True); (h/".local/bin/karsa").write_text("foreign")
    run(h,dto("preflight"),False) # collision
with tempfile.TemporaryDirectory() as td:
    h=Path(td); (h/".local/bin").mkdir(parents=True); other=h/"other"; other.mkdir(); (other/"karsa").write_text("x")
    run(h,dto("preflight"),False,{"PATH":str(other)+os.pathsep+str(h/".local/bin")}) # PATH denial

# Karsa-equivalent parser and complete overlap predicates.
for target in ("/absolute", "../escape", "a/../b", "a//b", "a\\b", "a\x00b", ".local/bin/karsa/child", ".local/bin"):
    with tempfile.TemporaryDirectory() as td:
        h=Path(td); (h/".local/bin").mkdir(parents=True)
        run(h,dto("preflight",files={target:"/nix/store/"+"a"*32+"-valid"}),False)
for source in ("/nix/store/short-x", "/nix/store/"+"e"*32+"-x", "/nix/store/"+"a"*32+"-x/sub"):
    with tempfile.TemporaryDirectory() as td:
        h=Path(td); (h/".local/bin").mkdir(parents=True)
        run(h,dto("preflight",files={"safe":source}),False)

# Selector-first provisioning and durable transaction recovery at each publication boundary.
faults=("stage.before","stage.after","generation.before_flush","generation.after_flush",
        "generation.after_rename","transaction.flush","transaction.rename","current.before_rename",
        "current.after_rename","transaction_commit.flush","transaction_commit.rename","exposure.before",
        "exposure.after","cleanup.before","cleanup.after","proof.read")
for fault in faults:
    with tempfile.TemporaryDirectory() as td:
        h=Path(td); (h/".local/bin").mkdir(parents=True)
        run(h,dto(),False,{"NIX_HOME_TESTING":"1","NIX_HOME_FAULT":fault})
        # A separately locked invocation recovers only its exact journal, then converges.
        run(h,dto())
        assert subprocess.check_output([h/".local/bin/karsa"],text=True).strip()=="one"

# Exact ownership: foreign selector, marker, exposure, hardlink, and special file are never reclaimed.
with tempfile.TemporaryDirectory() as td:
    h=Path(td); (h/".local/bin").mkdir(parents=True); run(h,dto())
    root=h/".local/state/nix-home"; (root/"current").unlink(); (root/"current").symlink_to("../escape")
    run(h,dto("preflight"),False)
with tempfile.TemporaryDirectory() as td:
    h=Path(td); (h/".local/bin").mkdir(parents=True); run(h,dto())
    marker=h/".local/state/nix-home/owner.json"; marker.write_text("{}\n")
    run(h,dto("preflight"),False)
with tempfile.TemporaryDirectory() as td:
    h=Path(td); (h/".local/bin").mkdir(parents=True); run(h,dto())
    visible=h/".local/bin/karsa"; visible.unlink(); visible.write_text("foreign")
    run(h,dto("preflight"),False); assert visible.read_text()=="foreign"

# Proof is observed: terminal byte and mode mutation cannot be forged by the DTO.
with tempfile.TemporaryDirectory() as td:
    h=Path(td); (h/".local/bin").mkdir(parents=True); run(h,dto())
    terminal=(h/".local/bin/karsa").resolve(); terminal.write_bytes(b"forged")
    run(h,dto(),False)

# The single advisory lock serializes competing complete operations.
with tempfile.TemporaryDirectory() as td:
    h=Path(td); (h/".local/bin").mkdir(parents=True)
    value=dto(); environment=os.environ | {"HOME":str(h),"PATH":str(h/".local/bin")+os.pathsep+os.environ["PATH"]}
    processes=[subprocess.Popen([sys.executable,SCRIPT,"realize","--json-stdin"],stdin=subprocess.PIPE,
                               stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,env=environment) for _ in range(4)]
    results=[process.communicate(json.dumps(value)+"\n") for process in processes]
    assert all(process.returncode==0 for process in processes), results

print(f"{12 + len(faults) + 12} deterministic realizer scenarios passed")

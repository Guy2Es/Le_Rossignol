# Surveillance Drone: 1 m Flying Wing

A 1 m span flying wing for surveillance, designed in three versions. The project follows the method of the *Aircraft Design* course (Gudmundsson): TLAR, constraint diagram, go/no-go reviews.

## Three-version strategy

| Version | Goal |
| --- | --- |
| V0 | Learn to fly: simulator, flight instruction, ~900 mm EPP foam wing that carries the V1 electronics |
| V1 | 3D-printed demonstrator, ≤ 800 g, 21700 Li-ion (3S1P then 4S1P), ArduPilot, ELRS 2.4 GHz, Raspberry Pi Zero 2 W + Camera Module 3. Hand launch, belly landing, visual line of sight |
| V2 | New airframe, 4S2P/4S3P Li-ion, pitot tube, H743, 4G + Tailscale + MediaMTX, thermal + IR, takeoff dolly |
| V3 (optional) | In-house flight controller designed in KiCad |

## Project status

| Phase | Content | Status |
| --- | --- | --- |
| 0 | Legal framework | to do |
| 1 | Piloting (in parallel) | in progress |
| 2 | Requirements (TLAR) | done (frozen 2026-10-12) |
| 3 | MATLAB preliminary sizing | done, GO (2026-10-13) |
| 4 | Aerodynamics and stability (xflr5) | **next** |
| 5 | CAD (CATIA) and 3D-printed structure | |
| 6 | Electronics and first KiCad PCB | |
| 7 | ArduPilot and SITL | |
| 8 | Manufacturing | |
| 9 | Ground tests | |
| 10 | V1 flight tests | |
| 11 | V2: 4G and control from the PC | |
| 12 | V2: night vision | |
| 13 | V3: in-house flight controller (optional) | |

## Phase 3 results (V1)

- Wing loading 31.4 N/m², 69 W required, set by the hand launch (T/W ≥ 0.5), stall speed 28.8 km/h.
- Powertrain: SunnySky X2212 V3 980 KV, rigid pusher APC 8×6EP, THR_MAX 100 % in 3S1P and 84 % in 4S1P (200 W).
- Real endurance in 4S1P: 46 to 53 min at 55 km/h, 79 to 91 min at 40 km/h.
- 4S1P mass: 797.2 g with the weight-saving plan, i.e. 2.8 g margin under 800 g (target structure 320 g).
- Tracked risks: mass (V1-MAS-01/02), Pi + camera power (V1-PL-01), availability of the F405 WING MINI and LittleBee-S.

Full report: `03_predimensionnement/resultats/phase3_resultats.md` (in French).

## Repository structure

```
Drone/
├── README.md
├── V1 requirements document
└── 03_predimensionnement/
    ├── params_v1.m            # input parameters
    ├── dimensionnement.m      # MATLAB calculations
    └── resultats/
        ├── phase3_resultats.md
        ├── tableaux_auto.md   # rewritten on each run
        └── figures/
```

## Reproducing the calculations

Requirement: MATLAB (developed with R2026b).

```matlab
cd 03_predimensionnement
dimensionnement
```

Tables and figures are regenerated in `resultats/`.

## Tools

xflr5, CATIA V5R21, MATLAB, KiCad 10, ArduPilot (SITL on Docker/VMware), Mission Planner, VS Code.

## Legal framework (France)

V1 under 800 g: no drone registration or electronic signalling, but operator registration on AlphaTango and A1/A3 training are required. Open category A3: visual line of sight, 120 m max, 150 m from built-up areas, written landowner agreement and third-party liability insurance. No beyond-visual-line-of-sight flight without the specific category.

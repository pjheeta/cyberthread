# cyberthread

**WiFi-controlled fibre-optic hair for Burning Man.** Eight side-glow fibres woven
into braided hair, each lit by its own addressable LED. The electronics live in a
small box on the chest; only passive glowing fibre goes in the hair. Colour, patterns,
and a mic-reactive "glitch" mode are driven from an ESP32 and controlled from a phone.

The name is the concept: the *thread* is both the fibre woven through the hair and the
data thread driving it.

> **Status: pre-build / design complete.** The hard part (the fibre-to-LED coupler) is
> solved and printable. Remaining work is gated on one set of physical measurements
> taken with the strip in hand — see [Open items](#open-items).

---

## How it works

```
  phone ──WiFi──▶ ESP32 ──DAT/CLK──▶ SK9822 pixels ──▶ COUPLER ──▶ fibre ──▶ hair
                    ▲                 (8, in the box)   (the      (side-    (8 passive
                 I2S mic                                 custom     glow)     strands)
               (glitch mode)                             part)
```

A fibre makes no light of its own — it's a light pipe. Shine an LED into one end and
the whole strand glows that colour. So the design keeps every electronic part in a box
and sends only light up into the hair:

1. **ESP32-WROOM-32** runs the show — WiFi access point, phone web UI, render loop.
2. **8× SK9822 pixels** (APA102-family, clock + data) sit *in the box* as the light
   engine. One pixel per fibre = per-strand colour control.
3. The **coupler** presses each fibre end against its pixel. This is the only custom-
   fabricated part and the thing the whole build hinges on.
4. **Side-glow fibre** carries the light up and glows along its length.
5. An **INMP441 I²S mic** feeds amplitude to the ESP32 for the sound-reactive mode.

Firmware is either **WLED** (free, has an AudioReactive usermod that supports the
INMP441 natively — no code) or hand-rolled FastLED (SK9822 is already familiar from a
prior POV-wheel project).

### Why fibre and not LED strip in the hair

A strip *can* go in the hair and gives real per-pixel "rain" down each strand — but a
flat flex-PCB doesn't drape; it reads as hardware braided into hair. Fibre drapes like
hair and looks like the hair itself is glowing. The trade is that fibre has no spatial
resolution along its length (a single fibre is one colour end-to-end), so per-strand
addressability is the ceiling, not per-*pixel* rain down a strand. That trade was made
deliberately: the look won.

---

## The coupler

A small block with a **groove** on the underside and a **row of holes** through the top.

- The SK9822 strip drops into the groove. The groove is sized to the strip width so it
  can only sit one way — which **auto-aligns every LED under its hole.** No aligning by
  eye.
- Each hole holds one fibre pointed straight down at one LED. The fibre bottoms out
  **dry against the LED face** — nothing in the optical gap.
- A dab of glue on the fibre shaft *above* the block retains it. **Never glue in the
  hole or on the LED** — it fogs the light path and can't be undone.

It's parametric ([`hardware/coupler/cyberthread_coupler.scad`](hardware/coupler)): the
same file makes the block for any strip density by changing `pitch` and `strip_w`.

| Strip | Pitch (c-c) | Strip width | Block length | Print |
|---|---|---|---|---|
| 30 LED/m  | ~28–33 mm* | 10 mm | ~212 mm | full, or 2× halves |
| 100 LED/m | ~10 mm | 10 mm | ~78 mm | single piece |
| 144 LED/m | ~6.94 mm | 12 mm | ~65 mm | single piece |

\* *Pitch to be confirmed by measurement — see Open items. The LED itself is a fixed
5×5 mm (5050) package at every density; only spacing changes.*

**Print notes:** black **PETG** (not PLA — softens in a warm box; not CF — rough holes,
needs a hardened nozzle). Orient channel-opening **up** → holes print clean, no
supports, no bridging. FDM shrinks holes slightly, so **test-fit a fibre and tune
`hole_comp`** before printing the final part.

---

## Bill of materials

| Part | Spec | Notes |
|---|---|---|
| Controller | ESP32-WROOM-32 | owned |
| Light engine | 8× SK9822 pixels | cut from strip stock; owned |
| Fibre | 2 mm side-glow PMMA, ~10 m | **not** end-glow. Long-lead item — order first |
| Coupler | black PETG print | the one fabricated part; STLs in repo |
| Mic | INMP441 (I²S) | optional; enables glitch mode. 3.3 V, not 5 V |
| Box | plastic project box | **never metal** — kills the WiFi AP |
| Power | USB power bank | ~1 A draw → runs all night |
| Chain | 550 paracord + black heatshrink | paracord carries load; fibre carries none |
| Safety | magnetic breakaway | necklace in a crowd must pop apart when snagged |
| Coat | acrylic conformal coating | playa dust is alkaline/conductive |

Realistic out-of-pocket, owning the ESP32/SK9822/consumables: **~$50–75.**

---

## Repo layout

```
cyberthread/
├── README.md
├── hardware/
│   └── coupler/
│       ├── cyberthread_coupler.scad     ← parametric source (edit this)
│       ├── coupler_30ledm_FULL.stl
│       ├── coupler_30ledm_LEFT_half.stl
│       ├── coupler_30ledm_RIGHT_half.stl
│       ├── coupler_144ledm_FULL.stl
│       └── PRINT.md                      ← print + fit-test instructions
├── firmware/                             ← WLED config / FastLED sketch (TBD)
└── docs/
    └── build-guide.html                  ← illustrated build guide
```

---

## Build sequence

1. **Dark-room test first.** One pixel, one polished fibre, lights off. Confirms the
   whole idea reads before anything is fabricated.
2. Cut an 8-pixel SK9822 run; solder `5V/GND/DAT/CLK` to the **input** end (arrows point
   away from it). Avoid the 0.5 m factory solder-joints — pitch is irregular there.
3. Flash the ESP32 (WLED or FastLED); get pixels + phone control working on the bench.
4. Print the coupler; **test-fit a fibre**, tune `hole_comp`, reprint if needed.
5. Prep fibres (razor-cut, sand, flame-polish), seat dry, retain from behind, wrap the
   junction reflective.
6. Bench-test all 8 strands. Dull strand = re-seat that fibre. Then soak-test on
   battery for runtime + heat.
7. Chain: paracord core + heatshrink jacket + magnetic breakaway.
8. Braid in, dress-rehearse in the dark on battery before the playa.

---

## Open items

Everything below is gated on measuring the **actual strip** (blocked until home ~Aug 10):

- [ ] **Centre-to-centre pitch** — ruler on centre of LED #1, read centre of LED #11,
      ÷10. Ends the 28-vs-33 mm ambiguity for the 30/m strip.
- [ ] **Which density** is actually being used (30 / 100 / 144) → picks the block.
- [ ] **Fibre outer diameter** → sizes the holes (`fiber_d`, currently assumed 2 mm).
- [ ] Confirm side-glow fibre is **ordered / en route** (the long pole).
- [ ] Firmware decision: WLED vs. hand-rolled FastLED.

Once measured, regenerating the correct STL is a two-line edit to the `.scad`.

---

## Lessons / decisions log

- Fibre must be **side-glow**, not end-glow, or it only lights at the tip.
- Coupling is the whole game: a scissor-crushed or unpolished fibre end scatters light;
  an air gap or glued gap kills brightness. Razor-cut, sand, flame-polish, seat dry.
- **The LED is a constant 5050 (5×5 mm) at every density** — only pitch/width change,
  which is why one parametric file covers all strips.
- Nominal pitch (`1000 ÷ density`) is *not* reliable — factory spacing and 0.5 m splices
  drift it. Measure, don't assume; a per-hole error accumulates to a total miss by hole 8.
- Power bank on the belt beats a LiPo on the neck (heat/puncture); a night-only piece
  never bakes, so hot glue and simple sealing are fine.

---

*Personal build. Shared in case it's useful to anyone chasing the same look.*

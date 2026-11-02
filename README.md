# CMTA (Cascade Metropolitan Transit Authority)
### Authentic NYC Subway Announcements for Abiotic Factor

**CMTA** brings the grit, chime, and unmistakable operational cadence of the New York City Subway into the subterranean transit network of the Gate Cascade Research Facility. 

Instead of silent tram cars, passengers hear line-specific route announcements, transfer advisories, and the iconic *Bing-Bong* chime echoing through the facility's tunnels.

---

## 1. Vision & Core Intentions

The Gate Cascade Facility is a massive underground research complex linked together by heavy electric rail trams. In the base game, trams operate with simple mechanical hums and brake squeaks.

**CMTA** treats the facility's tram network as a living, breathing rapid transit system:
- **Authentic MTA Phrasing & Cadence**: Every departure and arrival follows real-world New York City Subway announcement timing and phrasing.
- **Directional & Destination Aware**: Announcements dynamically adapt based on origin, destination, and direction of travel (e.g., *"This is a Containment-bound Cascade Labs tram"* vs. *"This is an Office Plaza-bound Cascade Labs tram"*).
- **Multi-Line Transfer Hubs**: Central hubs like the Office Sector Plaza identify available transfers to other lines (Manufacturing, Mines, Hydroplant, Residences).
- **100% Mod.io UGC / Dedicated Server Compatible**: Built strictly within the official modding SDK (`NoCode: true`) without external DLL injectors, functioning seamlessly across Singleplayer, Co-op Host/Client, and Dedicated Servers.

---

## 2. Sound Design & Cadence Philosophy

### A. The Departure Sequence
In real MTA subway operations, the conductor does not wait for the door chime to fade before speaking—the announcement overlaps the second chime tone. CMTA replicates this exact timing:

```text
Time (s):   0.0s               0.8s                                 3.35s   3.6s                                                  9.9s
            |------------------|------------------------------------|-------|-----------------------------------------------------|
Audio:      [*Bing-Bong*]      ["Stand clear of the closing doors..."]      ["This is a Containment-bound Cascade Labs tram..."]
                                                                    (Pause)
```

1. **`0.00s` — The Chime (`S_MTA_BingBong`)**: Two-tone electronic chime (*Ding... Dong...*).
2. **`0.80s` — Conductor Overlap (`S_MTA_StandClear`)**: As the second chime echoes, the voice begins: *"Stand clear of the closing doors, please."*
3. **`3.35s` — Breath Pause**: A natural 0.25-second human pause.
4. **`3.60s` — Line & Destination (`S_MTA_Dep_*`)**: *"This is a [Destination]-bound [Line] tram. The next stop is... [Next Station]."*

### B. The Arrival Sequence
1. The tram docks into the station platform.
2. The base-game mechanical arrival ding plays.
3. **0.8 seconds later**, the station identification plays:
   - Intermediate Station: *"This is Wildlife Pens."*
   - Terminal / Transfer Hub: *"This is Office Sector Plaza. Transfer is available to the Manufacturing, Mines, and Hydroplant trams."*

---

## 3. Technical Principles & Non-Negotiables

### 1. Zero Hardcoded Distance Checks (Door State Docking)
Many tram mods attempt to detect station arrivals using distance thresholds (`GetDistanceTo(Station) < 800`). This is inherently brittle because platform lengths, track radii, and actor pivot points vary across the facility.

* **How CMTA Solves This**:
  - Intermediate blast doors, bridges, and track switches pause the tram with **`TramDoorState == Closed`**.
  - Station platforms dock the tram and open passenger doors (**`TramDoorState != Closed`**).
  - Checking `TramDoorState != Closed` guarantees **zero false arrival announcements** at intermediate blast doors, with zero magic numbers.

### 2. Stream-Proof Voice Virtualization
Abiotic Factor streams sectors in and out dynamically (`Facility_Offices`, `Facility_Containment`, etc.). 
* In Unreal Engine, Sound Waves default to `EVirtualizationMode::Restart` or `Disabled`. Level-streaming hitches or sector portal transitions can kill or restart playing voices.
* **CMTA Principle**: Every voice asset is configured with **`VirtualizationMode = PlayWhenSilent`** and **`bStopWhenAttachedToDestroyed = false`**, guaranteeing announcements finish smoothly even if the player or tram crosses streaming sublevel boundaries.

### 3. Pure 3-Track Mixer Sound Cues (No Concatenator Bugs)
Nesting a `SoundNodeMixer` inside a `SoundNodeConcatenator` triggers an engine-level duration calculation bug in Unreal Engine, truncating subsequent audio tracks.
* **CMTA Principle**: All composite announcements use a **pure 3-track `SoundNodeMixer` as the root node**, using dedicated `SoundNodeDelay` nodes for timing. The engine evaluates duration as `Max()` across all tracks, preventing truncation.

### 4. Server-Authoritative State Watcher with Client Audio
To prevent client-server desync and audio doubling:
* **Server**: A single replicated actor (`BP_MTA_TramAudioManager`) polls all 9 `Tram_Default` actors at a lightweight `0.2s` interval.
* **Network**: On state change, the server calls a `Reliable Multicast` RPC (`Multicast_PlayTramSound`).
* **Client**: Headless dedicated servers bypass audio rendering (`NOT IsDedicatedServer`); player clients spawn the audio attached to the tram cabin.
* **Overlap Protection**: An active announcement map (`TMap<Tram_Default, AudioComponent>`) terminates any previous sound before starting a new one if buttons are spammed.

---

## 4. Routing & Station Taxonomy

### A. Cascade Labs Line (Blue)

| Origin Station | Target Station | Trigger Event | Sound Key | Audio Asset |
| :--- | :--- | :--- | :--- | :--- |
| **Office Plaza** (`C_11`) | **Wildlife Pens** (`C_14`) | Departure | `TramSystem_Station_C_11->TramSystem_Station_C_14` | `SC_Dep_Office_To_Pens` |
| **Wildlife Pens** (`C_14`) | **Containment** (`C_12`) | Departure | `TramSystem_Station_C_14->TramSystem_Station_C_12` | `SC_Dep_Pens_To_Containment` |
| **Containment** (`C_12`) | **Wildlife Pens** (`C_14`) | Departure | `TramSystem_Station_C_12->TramSystem_Station_C_14` | `SC_Dep_Containment_To_Pens` |
| **Wildlife Pens** (`C_14`) | **Office Plaza** (`C_11`) | Departure | `TramSystem_Station_C_14->TramSystem_Station_C_11` | `SC_Dep_Pens_To_Office` |
| — | **Office Plaza** (`C_11`) | Arrival | `TramSystem_Station_C_11` | `S_MTA_Arr_OfficePlaza_Containment` |
| — | **Wildlife Pens** (`C_14`) | Arrival | `TramSystem_Station_C_14` | `S_MTA_Arr_WildlifePens` |
| — | **Containment** (`C_12`) | Arrival | `TramSystem_Station_C_12` | `S_MTA_Arr_Containment` |

### B. Remaining Office Plaza Hub Trams

| Line / Destination | Origin Station | Target Station | Trigger Event | Sound Key | Audio Asset |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Manufacturing West** | **Office Plaza** (`C_1`) | **MF West** (`C_5`) | Departure (Outbound) | `TramSystem_Station_C_1->TramSystem_Station_C_5` | `SC_Dep_Office_To_MFWest` |
| **Manufacturing West** | — | **MF West** (`C_5`) | Arrival | `TramSystem_Station_C_5` | `S_MTA_Arr_MFWest` |
| **Manufacturing West** | **MF West** (`C_5`) | **Office Plaza** (`C_1`) | Departure (Inbound) | `TramSystem_Station_C_5->TramSystem_Station_C_1` | `SC_Dep_MFWest_To_Office` |
| **Manufacturing West** | — | **Office Plaza** (`C_1`) | Arrival (Transfer) | `TramSystem_Station_C_1` | `S_MTA_Arr_OfficePlaza_MFWest` |
| **The Mines** | **Office Plaza** (`C_3`) | **The Mines** (`C_2`) | Departure (Outbound) | `TramSystem_Station_C_3->TramSystem_Station_C_2` | `SC_Dep_Office_To_Mines` |
| **The Mines** | — | **The Mines** (`C_2`) | Arrival | `TramSystem_Station_C_2` | `S_MTA_Arr_Mines` |
| **The Mines** | **The Mines** (`C_2`) | **Office Plaza** (`C_3`) | Departure (Inbound) | `TramSystem_Station_C_2->TramSystem_Station_C_3` | `SC_Dep_Mines_To_Office` |
| **The Mines** | — | **Office Plaza** (`C_3`) | Arrival (Transfer) | `TramSystem_Station_C_3` | `S_MTA_Arr_OfficePlaza_Mines` |
| **Hydroplant (Dam)** | **Office Plaza** (`C_20`) | **Hydroplant** (`C_13`) | Departure (Outbound) | `TramSystem_Station_C_20->TramSystem_Station_C_13` | `SC_Dep_Office_To_Hydroplant` |
| **Hydroplant (Dam)** | — | **Hydroplant** (`C_13`) | Arrival | `TramSystem_Station_C_13` | `S_MTA_Arr_Hydroplant` |
| **Hydroplant (Dam)** | **Hydroplant** (`C_13`) | **Office Plaza** (`C_20`) | Departure (Inbound) | `TramSystem_Station_C_13->TramSystem_Station_C_20` | `SC_Dep_Hydroplant_To_Office` |
| **Hydroplant (Dam)** | — | **Office Plaza** (`C_20`) | Arrival (Transfer) | `TramSystem_Station_C_20` | `S_MTA_Arr_OfficePlaza_Hydroplant` |

---

## 5. Facility Expansion Roadmap

All placed station actors across the facility have been mapped by runtime ID in `scratch/facility_tram_stations.md`:

- [x] **Cascade Labs Line**: Office Plaza (`C_11`) $\leftrightarrow$ Wildlife Pens (`C_14`) $\leftrightarrow$ Containment (`C_12`)
- [ ] **Manufacturing West Line**: Office Plaza (`C_1`) $\leftrightarrow$ Manufacturing West (`C_5`)
- [ ] **Mines Line**: Office Plaza (`C_3`) $\leftrightarrow$ Mines Terminal (`C_2`)
- [ ] **Hydroplant / Dam Line**: Office Plaza (`C_20`) $\leftrightarrow$ Dam Station (`C_13`)
- [ ] **Residences Line**: Office Plaza (`C_15`) $\leftrightarrow$ Check-in Waystop (`C_17`) $\leftrightarrow$ Residences Left/Right (`C_19`/`C_10`)
- [ ] **Reactors Line**: Reactor Cloud / Station 4 (`C_21`), Gale (`C_22`), Dusk (`C_26`), Bramble/Mist (`C_28`)

---

## 6. How to Add a New Line (Template Workflow)

1. **Record or Generate Audio Waves**:
   - `S_MTA_Dep_[Origin]_To_[Dest].wav`
   - `S_MTA_Arr_[Station].wav`
   - Import into `Content/Audio/` and set `Virtualization Mode` to **`Play When Silent`**.
2. **Create the Sound Cue (`SC_Dep_*`)**:
   - Create a new Sound Cue.
   - Add a `Mixer` node connected to `Output`.
   - Add 3 inputs:
     - Input 1: `S_MTA_BingBong`
     - Input 2: `S_MTA_StandClear` with `Delay(0.8s)`
     - Input 3: `S_MTA_Dep_*` with `Delay(3.6s)`
3. **Register in `BP_MTA_TramAudioManager`**:
   - Open `BP_MTA_TramAudioManager` $\rightarrow$ Class Defaults.
   - In **`Departure Sounds`**, add key `Origin_Station_ID->Target_Station_ID` and assign the Sound Cue.
   - In **`Arrival Sounds`**, add key `Target_Station_ID` and assign the Arrival Sound Wave.
4. **Test in PIE**:
   - Verify departure cadence and platform arrival.

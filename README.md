# Round-based-Multiplayer-Game (Roblox Implementation)

A Roblox Studio implementation of the **Mingle** round (inspired by *Squid Game Season 2*). Focused on event-driven multiplayer mechanics: timed music/grouping, random room selection, door animations, revives, teleportation and player-state management. This repository includes the **main server-side scripts only** for code demonstration.

---

## **Game Concept**
- At the start, all players in the lobby are teleported to a **central spinning platform** surrounded by a **synchronized lighting system** for immersive visual feedback.  
- Music plays while the platform spins, allowing players to move freely and strategize.  
- When the music stops, players must **form groups** and enter **randomly selected rooms** before time runs out.  
- Players who fail to enter a room in time are **eliminated** from the round.  
- Eliminated players can use **revives**, which are limited but can be earned through gameplay, with all revive counts tracked and persisted across sessions.  


---

## **Key Features**
- **Round & Flow Management**
  - Controlled, repeatable rounds with platform/room selection and end-of-round checks.  
- **Door System**
  - Random door selection per round with smooth open/close animations via **TweenService**, and doors can also be **manually controlled**.  
- **Leaderboard & Rewards**
  - Tracks player wins with a **top 100 leaderboard**, displaying the **top 3 players with their own avatar objects** as top winners.  
  - **Revives** are awarded automatically when players reach specific win milestones.  
- **Player Teleportation**
  - Randomized platform spawn positions while avoiding restricted zones to ensure fairness.  
- **Player State Tracking**
  - Maintains lists of active players, players currently on the platform, and eliminated players.  
- **Ragdoll System**
  - The ragdoll system is based on an open-source model, which was extensively modified and customized to work seamlessly with this game’s mechanics, allowing players to push others out of rooms or the platform.  
  

---

## **Main Scripts Included**  

This repository contains the **five primary scripts** that drive the core gameplay of the game:  

- **CharacterAddedRevive.lua** – Handles player character respawn, revival logic, and associated effects.  
- **CoreScript.lua** – Manages the main game flow, player state tracking, badges, and leaderboard interactions.  
- **DataStore.lua** – Responsible for persistent player data including wins and revives using **DataStoreService**.  
- **DoorsSystem.lua** – Controls room door selection, smooth opening/closing animations, and manual door interactions.  
- **ReviveSystem.lua** – Implements the revive system, teleportation back to the platform, and win-based revive rewards.  

> ⚠️ Note: Other auxiliary scripts, assets, and configurations are not included as they are either repetitive or not critical for understanding the main gameplay mechanics.

---
## **Performance Improvements & Player Retention**

- **Platform Barrier Implementation:** Added a barrier around the spinning platform to prevent players from accidentally leaving, reducing unintended quits.  
- **Automatic Teleportation:** Ensured players are always teleported back to the platform when required, maintaining smooth gameplay flow.  
- **Bug Fixes & Feedback Integration:** Collected player feedback on early versions, identified glitches and bugs, and resolved them for a more stable experience.  
- **Difficulty Optimization:** Adjusted game difficulty based on player feedback to prevent early eliminations and reduce frustration, leading to higher retention.  
- **Revive System:** Introduced revives that players can use to return after elimination; additional revives are rewarded after winning a set number of rounds, further increasing session duration.  
- **Cross-Device Testing:** Conducted extensive testing on multiple devices to ensure consistent performance, eliminate loopholes, and provide a smooth gameplay experience.  


## **Development & Tech Stack**

- **Game Engine & Scripting**: Built from scratch in **Roblox Studio** using **Luau scripting**, with modular architecture through **ModuleScripts** and **RemoteEvents**.  

- **Data & Persistence**: Player stats and revives stored using **DataStoreService**.  

- **3D Modeling**: Custom assets (rooms, platform, environment) created in **Blender**; central spinning carousel adapted and enhanced from an open-source model with synchronized lighting.  

- **Animations & Tools**: Custom player and tool animations implemented via **AnimationController** and **Humanoid**.  

- **Gameplay Systems**:  
  - Round flow and random door mechanics (manual & automatic control).  
  - Leaderboard showing **Top 100 players**, with **3D avatar displays for Top 3**.  
  - Revive mechanics with persistent revive counts.  
  - Customized **ragdoll system** (heavily modified from open-source) for push interactions.  

- **UI & UX**: Interactive leaderboards, round timers, notifications, and revival prompts built with **ScreenGui**.  

- **Audio & Effects**: Immersive gameplay with synchronized music, sound effects, and particle systems.  

- All **core systems** were developed, optimized, and tested for smooth multiplayer performance across devices.  



**Note:** This repository contains only representative server-side scripts to demonstrate architecture and coding ability. The full game includes additional client-side scripts, GUIs, audio controllers and maps which are not included here.

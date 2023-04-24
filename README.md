# Programmer-Airplane-Simulator-Application

A demonstration/description of refactoring code from a sample tycoon game.
Standards desired by an employer would of course take precedence, this is just my first attempt at it!

## Organization

- client/
  - runtime/
     - Initialize the client
  - storage/
     - Client modules
- server/
  - runtime/
     - Initialize the server
  - storage/
     - Server modules
- shared/
   - Helpful libraries for client & server
- start/
   - Initial loading, aka ReplicatedFirst

## Description of Refactor

### Codebase Structure Explanation

The structure for this refactor will be an efficient yet simple/common structure known as "Knit".
Server modules will be referred to as Services and Client modules will be referred to as Controllers.
Services and Controllers will be placed in /ServerScriptService/serversync/services and StarterPlayer/StarterPlayerScripts/clientsync/controllers respectively.
More information about this framework can be found https://sleitnick.github.io/Knit/docs/intro

### Helpful Technologies Used in New Codebase

Using, or being inspired by, written technologies can be a huge time saver. Reinventing the wheel is a slippery slope that is best avoided in writing code.
That being said, I will put very helpful libraries pulled from GitHub and fairly well-known among the professional Roblox scripting community.

1. Knit Framework (https://github.com/Sleitnick/Knit)
 - Adding to the default Knit framework, I have made methods such as "Incoming" and "Removing", allowing for a module to handle a player joining or leaving
2. ProfileService (https://github.com/MadStudioRoblox/ProfileService)
 - The 3 most important values for this game are Tycoon Progression, Paycheck Value and Money Value. These are all saved/retrieved using the ProfileService

### Features Added to the Game!

 1. Loading Intro
 2. Incoming money UI effects, as well as particle effects
 3. Several new buttons and models to the Tycoon
 4. Notification on pads if "not enough money" or "dependency not met"
 5. Monetization structure / Time Travel feature
 6. Music / SFX Sounds (SFX of course based on interactions with the tycoon)
 7. Pad automating functionality (for easier expansion of a tycoon)
 8. Reset data functionality UI button (in case desired during testing!)
 9. Paycheck updating animation (along with number abbreviations)

## Regards

Please know that I am very willing to adapt the way I code. I have no problems picking up and using new standards or practices if this is desired!

Thank you for your consideration,

Adrian Holgate